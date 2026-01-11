import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/app_logger.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  bool get isConnected => _isConnected;
  Stream<Map<String, dynamic>>? get messages => _messageController?.stream;

  Future<void> connect() async {
    if (_isConnected && _channel != null) {
      AppLogger.d('WebSocket already connected');
      return;
    }

    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyAuthToken);

      if (token == null) {
        AppLogger.w('No auth token available for WebSocket connection');
        return;
      }

      // Create WebSocket URL from API base URL
      final wsUrl = _getWebSocketUrl();
      AppLogger.i('Connecting to WebSocket');

      _messageController ??= StreamController<Map<String, dynamic>>.broadcast();

      // Connect to WebSocket
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl?token=$token'),
      );

      _isConnected = true;
      _reconnectAttempts = 0;

      // Listen to messages
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // Send authentication
      _send({
        'type': 'auth',
        'token': token,
      });

      // Start ping timer to keep connection alive
      _startPingTimer();

      AppLogger.i('WebSocket connected successfully');
    } catch (e) {
      AppLogger.e('Error connecting to WebSocket', e);
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  String _getWebSocketUrl() {
    // Convert HTTP URL to WebSocket URL
    final apiUrl = AppConstants.apiBaseUrl;
    if (apiUrl.startsWith('https://')) {
      return apiUrl.replaceFirst('https://', 'wss://') + '/ws';
    } else if (apiUrl.startsWith('http://')) {
      return apiUrl.replaceFirst('http://', 'ws://') + '/ws';
    }
    return 'ws://localhost:8000/ws';
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      AppLogger.d('WebSocket message received: ${data['type']}');

      // Handle different message types
      switch (data['type']) {
        case 'pong':
          // Heartbeat response
          break;
        case 'notification':
          _messageController?.add({
            'type': 'notification',
            'data': data['data'],
          });
          break;
        case 'dashboard_update':
          _messageController?.add({
            'type': 'dashboard_update',
            'data': data['data'],
          });
          break;
        case 'attendance_update':
          _messageController?.add({
            'type': 'attendance_update',
            'data': data['data'],
          });
          break;
        case 'payment_update':
          _messageController?.add({
            'type': 'payment_update',
            'data': data['data'],
          });
          break;
        case 'grade_update':
          _messageController?.add({
            'type': 'grade_update',
            'data': data['data'],
          });
          break;
        default:
          _messageController?.add(data);
      }
    } catch (e) {
      AppLogger.e('Error parsing WebSocket message', e);
    }
  }

  void _onError(error) {
    AppLogger.e('WebSocket error', error);
    _isConnected = false;
    _scheduleReconnect();
  }

  void _onDone() {
    AppLogger.i('WebSocket connection closed');
    _isConnected = false;
    _pingTimer?.cancel();
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.w('Max reconnect attempts reached. Giving up.');
      return;
    }

    _reconnectTimer?.cancel();

    // Exponential backoff: 1s, 2s, 4s, 8s, 16s
    final delay = Duration(seconds: 1 << _reconnectAttempts);
    _reconnectAttempts++;

    AppLogger.i('Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s');

    _reconnectTimer = Timer(delay, () {
      connect();
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _send({'type': 'ping'});
      }
    });
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode(data));
      } catch (e) {
        AppLogger.e('Error sending WebSocket message', e);
      }
    }
  }

  // Subscribe to specific student updates
  void subscribeToStudent(int studentId) {
    _send({
      'type': 'subscribe',
      'channel': 'student.$studentId',
    });
  }

  // Unsubscribe from student updates
  void unsubscribeFromStudent(int studentId) {
    _send({
      'type': 'unsubscribe',
      'channel': 'student.$studentId',
    });
  }

  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _isConnected = false;
    AppLogger.i('WebSocket disconnected');
  }

  void dispose() {
    disconnect();
    _messageController?.close();
  }
}

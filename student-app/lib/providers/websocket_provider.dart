import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';

// WebSocket Service Provider
final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

// WebSocket Connection Status Provider
final websocketConnectionProvider = StateProvider<bool>((ref) {
  final service = ref.watch(websocketServiceProvider);
  return service.isConnected;
});

// WebSocket Messages Stream Provider
final websocketMessagesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(websocketServiceProvider);
  service.connect();
  return service.messages ?? const Stream.empty();
});

// Notification Updates Provider
final realtimeNotificationProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final messagesAsync = ref.watch(websocketMessagesProvider);

  return messagesAsync.when(
    data: (messages) => messages
        .where((message) => message['type'] == 'notification')
        .map((message) => message['data'] as Map<String, dynamic>),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Dashboard Updates Provider
final realtimeDashboardProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final messagesAsync = ref.watch(websocketMessagesProvider);

  return messagesAsync.when(
    data: (messages) => messages
        .where((message) => message['type'] == 'dashboard_update')
        .map((message) => message['data'] as Map<String, dynamic>),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Attendance Updates Provider
final realtimeAttendanceProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final messagesAsync = ref.watch(websocketMessagesProvider);

  return messagesAsync.when(
    data: (messages) => messages
        .where((message) => message['type'] == 'attendance_update')
        .map((message) => message['data'] as Map<String, dynamic>),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Payment Updates Provider
final realtimePaymentProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final messagesAsync = ref.watch(websocketMessagesProvider);

  return messagesAsync.when(
    data: (messages) => messages
        .where((message) => message['type'] == 'payment_update')
        .map((message) => message['data'] as Map<String, dynamic>),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Grade Updates Provider
final realtimeGradeProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final messagesAsync = ref.watch(websocketMessagesProvider);

  return messagesAsync.when(
    data: (messages) => messages
        .where((message) => message['type'] == 'grade_update')
        .map((message) => message['data'] as Map<String, dynamic>),
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

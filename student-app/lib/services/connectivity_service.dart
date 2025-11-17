import 'dart:async';
import 'dart:io';

class ConnectivityService {
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  bool _isOnline = true;
  Timer? _timer;

  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool get isOnline => _isOnline;

  ConnectivityService() {
    _startMonitoring();
  }

  void _startMonitoring() {
    // Check connectivity every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => checkConnectivity());
    // Initial check
    checkConnectivity();
  }

  Future<bool> checkConnectivity() async {
    bool previousStatus = _isOnline;

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _isOnline = false;
    } on TimeoutException catch (_) {
      _isOnline = false;
    } catch (_) {
      _isOnline = false;
    }

    // Notify listeners if status changed
    if (previousStatus != _isOnline) {
      _connectivityController.add(_isOnline);
    }

    return _isOnline;
  }

  void dispose() {
    _timer?.cancel();
    _connectivityController.close();
  }
}

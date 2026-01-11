import 'dart:async';
import 'dart:convert';
import '../utils/app_logger.dart';

/// Service to handle notification navigation events
/// Uses a stream to communicate navigation requests from background to UI
class NotificationNavigationService {
  static final NotificationNavigationService _instance =
      NotificationNavigationService._internal();
  factory NotificationNavigationService() => _instance;
  NotificationNavigationService._internal();

  final StreamController<NotificationNavigation> _navigationController =
      StreamController<NotificationNavigation>.broadcast();

  Stream<NotificationNavigation> get navigationStream =>
      _navigationController.stream;

  void navigateFromNotification(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;
      final notificationData = data['data'];

      AppLogger.i('Processing notification navigation: type=$type');

      final navigation = _resolveNavigation(type, notificationData);
      _navigationController.add(navigation);
    } catch (e) {
      AppLogger.e('Error processing notification navigation', e);
      // Default to notifications screen on error
      _navigationController.add(
        NotificationNavigation(destination: NavigationDestination.notifications),
      );
    }
  }

  void navigateFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      _navigationController.add(
        NotificationNavigation(destination: NavigationDestination.notifications),
      );
      return;
    }

    try {
      // Try to parse as JSON
      final data = jsonDecode(payload) as Map<String, dynamic>;
      navigateFromNotification(data);
    } catch (e) {
      // If not JSON, treat as plain text - go to notifications
      AppLogger.d('Payload is not JSON, navigating to notifications');
      _navigationController.add(
        NotificationNavigation(destination: NavigationDestination.notifications),
      );
    }
  }

  NotificationNavigation _resolveNavigation(String? type, dynamic data) {
    switch (type) {
      case 'payment_reminder':
      case 'payment_update':
        return NotificationNavigation(
          destination: NavigationDestination.payments,
          data: data,
        );

      case 'grade_update':
        return NotificationNavigation(
          destination: NavigationDestination.grades,
          data: data,
        );

      case 'attendance_update':
        return NotificationNavigation(
          destination: NavigationDestination.attendance,
          data: data,
        );

      case 'announcement':
      case 'notification':
      default:
        return NotificationNavigation(
          destination: NavigationDestination.notifications,
          data: data,
        );
    }
  }

  void dispose() {
    _navigationController.close();
  }
}

enum NavigationDestination {
  home,
  attendance,
  payments,
  grades,
  notifications,
}

class NotificationNavigation {
  final NavigationDestination destination;
  final dynamic data;

  NotificationNavigation({
    required this.destination,
    this.data,
  });
}

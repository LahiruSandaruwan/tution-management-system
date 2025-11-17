import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  service.initialize();
  return service;
});

// FCM Token Provider
final fcmTokenProvider = Provider<String?>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.fcmToken;
});

// Notification Permission Status Provider
final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  // Check if notifications are enabled
  // This is a simplified version - actual implementation would check system settings
  return service.fcmToken != null;
});

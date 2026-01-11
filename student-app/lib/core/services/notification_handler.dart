import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_logger.dart';

/// Handles notification navigation based on notification type and data
class NotificationHandler {
  static void handleNotificationTap(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final type = data['type'] as String?;
    final notificationData = data['data'] as Map<String, dynamic>?;

    AppLogger.i('Handling notification tap: type=$type');

    if (type == null) {
      // No specific type, go to notifications screen
      context.push('/notifications');
      return;
    }

    switch (type) {
      case 'payment_reminder':
      case 'payment_update':
        // Navigate to payments tab in main layout
        // MainLayout will handle tab switching via index
        _navigateToTab(context, 2); // Payments tab index
        break;

      case 'grade_update':
        // Navigate to grades screen
        context.push('/grades');
        break;

      case 'attendance_update':
        // Navigate to attendance tab
        _navigateToTab(context, 1); // Attendance tab index
        break;

      case 'announcement':
      case 'notification':
      default:
        // Navigate to notifications screen
        context.push('/notifications');
        break;
    }
  }

  static void _navigateToTab(BuildContext context, int tabIndex) {
    // Navigate to home and let MainLayout handle the tab index
    // We'll pass the tab index as a query parameter
    context.go('/?tab=$tabIndex');
  }

  /// Parse notification payload from string to Map
  static Map<String, dynamic>? parsePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    try {
      // If payload is already a JSON string, parse it
      if (payload.startsWith('{')) {
        // This would need proper JSON parsing in real implementation
        // For now, return a simple map
        return {'raw': payload};
      }
      return {'raw': payload};
    } catch (e) {
      AppLogger.e('Error parsing notification payload', e);
      return null;
    }
  }
}

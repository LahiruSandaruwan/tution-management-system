import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/api_provider.dart';

class DashboardStats {
  final int totalClasses;
  final double attendancePercentage;
  final String paymentStatus;
  final double pendingAmount;
  final int upcomingClasses;
  final int unreadNotifications;

  DashboardStats({
    required this.totalClasses,
    required this.attendancePercentage,
    required this.paymentStatus,
    required this.pendingAmount,
    required this.upcomingClasses,
    required this.unreadNotifications,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalClasses: json['total_classes'] ?? 0,
      attendancePercentage: (json['attendance_percentage'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? 'unknown',
      pendingAmount: (json['pending_amount'] ?? 0).toDouble(),
      upcomingClasses: json['upcoming_classes'] ?? 0,
      unreadNotifications: json['unread_notifications'] ?? 0,
    );
  }
}

class RecentActivity {
  final String title;
  final String subtitle;
  final String time;
  final String type;

  RecentActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? 'info',
    );
  }
}

// Dashboard Stats Provider
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final apiService = ref.watch(apiProvider);

  try {
    final response = await apiService.getDashboardStats();
    return DashboardStats.fromJson(response['data'] ?? {});
  } catch (e) {
    // Let Riverpod handle error state naturally - UI will show error
    rethrow;
  }
});

// Recent Activities Provider
final recentActivitiesProvider = FutureProvider<List<RecentActivity>>((ref) async {
  final apiService = ref.watch(apiProvider);

  try {
    final response = await apiService.getRecentActivities();
    final List activities = response['data'] ?? [];
    return activities.map((json) => RecentActivity.fromJson(json)).toList();
  } catch (e) {
    // Let Riverpod handle error state naturally - UI will show error
    rethrow;
  }
});

// Refresh trigger
final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

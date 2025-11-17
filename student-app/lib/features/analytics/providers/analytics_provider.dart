import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/api_provider.dart';

// Analytics Data Provider
final analyticsDataProvider = FutureProvider.family<Map<String, dynamic>, (DateTime, DateTime)>(
  (ref, dates) async {
    final (startDate, endDate) = dates;
    final apiService = ref.watch(apiProvider);

    try {
      // This would call a backend endpoint: /analytics?start={startDate}&end={endDate}
      // For now, returning mock data
      return _getMockAnalyticsData(startDate, endDate);
    } catch (e) {
      return _getMockAnalyticsData(startDate, endDate);
    }
  },
);

// Mock data generator (replace with actual API call)
Map<String, dynamic> _getMockAnalyticsData(DateTime startDate, DateTime endDate) {
  return {
    'summary': {
      'avg_attendance': 87.5,
      'avg_grade': 'B+',
      'total_classes': 45,
      'classes_attended': 40,
    },
    'attendance_trend': [
      {'label': 'Week 1', 'value': 85.0},
      {'label': 'Week 2', 'value': 90.0},
      {'label': 'Week 3', 'value': 82.5},
      {'label': 'Week 4', 'value': 92.5},
    ],
    'performance_by_subject': [
      {'subject': 'Math', 'score': 85.0},
      {'subject': 'Science', 'score': 78.0},
      {'subject': 'English', 'score': 92.0},
      {'subject': 'History', 'score': 80.0},
    ],
    'payment_status': {
      'paid': 45000.0,
      'pending': 5000.0,
    },
    'insights': [
      {
        'type': 'success',
        'title': 'Excellent Attendance',
        'message': 'Your attendance rate is above 85%. Keep it up!',
      },
      {
        'type': 'warning',
        'title': 'Pending Payment',
        'message': 'You have a pending payment of Rs. 5,000.',
      },
      {
        'type': 'info',
        'title': 'Upcoming Exam',
        'message': 'Term exam starts in 2 weeks. Prepare well!',
      },
    ],
  };
}

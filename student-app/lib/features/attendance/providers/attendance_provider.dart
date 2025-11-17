import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/attendance.dart';
import '../../../providers/api_provider.dart';

// Attendance Summary Provider
final attendanceSummaryProvider = FutureProvider.family<AttendanceSummary, AttendanceFilter>((ref, filter) async {
  final apiService = ref.watch(apiProvider);

  try {
    return await apiService.getAttendanceSummary(
      month: filter.month,
      year: filter.year,
    );
  } catch (e) {
    // Return empty summary on error
    return AttendanceSummary(
      totalDays: 0,
      present: 0,
      absent: 0,
      late: 0,
      attendancePercentage: 0.0,
    );
  }
});

// Attendance History Provider
final attendanceHistoryProvider = FutureProvider.family<List<Attendance>, AttendanceFilter>((ref, filter) async {
  final apiService = ref.watch(apiProvider);

  try {
    return await apiService.getAttendanceHistory(
      month: filter.month,
      year: filter.year,
    );
  } catch (e) {
    return [];
  }
});

// Current filter state
final attendanceFilterProvider = StateProvider<AttendanceFilter>((ref) {
  final now = DateTime.now();
  return AttendanceFilter(
    month: now.month.toString().padLeft(2, '0'),
    year: now.year,
  );
});

// Helper class for filters
class AttendanceFilter {
  final String? month;
  final int? year;

  AttendanceFilter({this.month, this.year});

  AttendanceFilter copyWith({String? month, int? year}) {
    return AttendanceFilter(
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}

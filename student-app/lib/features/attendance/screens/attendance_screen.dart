import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/attendance_provider.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(attendanceFilterProvider);
    final summaryAsync = ref.watch(attendanceSummaryProvider(filter));
    final historyAsync = ref.watch(attendanceHistoryProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(attendanceSummaryProvider);
          ref.invalidate(attendanceHistoryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Summary Card
            summaryAsync.when(
              data: (summary) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Summary',
                        style: AppTheme.headingSmall,
                      ),
                      const SizedBox(height: 20),

                      // Attendance Percentage
                      Center(
                        child: SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                if (summary.present > 0)
                                  PieChartSectionData(
                                    value: summary.present.toDouble(),
                                    title: '${((summary.present / summary.totalDays) * 100).toStringAsFixed(0)}%',
                                    color: AppTheme.successColor,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (summary.absent > 0)
                                  PieChartSectionData(
                                    value: summary.absent.toDouble(),
                                    title: '${((summary.absent / summary.totalDays) * 100).toStringAsFixed(0)}%',
                                    color: AppTheme.errorColor,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (summary.late > 0)
                                  PieChartSectionData(
                                    value: summary.late.toDouble(),
                                    title: '${((summary.late / summary.totalDays) * 100).toStringAsFixed(0)}%',
                                    color: AppTheme.warningColor,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem(
                            'Present',
                            AppTheme.successColor,
                            '${((summary.present / (summary.totalDays > 0 ? summary.totalDays : 1)) * 100).toStringAsFixed(0)}%',
                          ),
                          _buildLegendItem(
                            'Absent',
                            AppTheme.errorColor,
                            '${((summary.absent / (summary.totalDays > 0 ? summary.totalDays : 1)) * 100).toStringAsFixed(0)}%',
                          ),
                          _buildLegendItem(
                            'Late',
                            AppTheme.warningColor,
                            '${((summary.late / (summary.totalDays > 0 ? summary.totalDays : 1)) * 100).toStringAsFixed(0)}%',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Total Days', summary.totalDays.toString()),
                          _buildStatItem('Present', summary.present.toString()),
                          _buildStatItem('Absent', summary.absent.toString()),
                          _buildStatItem('Late', summary.late.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load attendance summary',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(
                    DateTime(filter.year ?? DateTime.now().year,
                             int.parse(filter.month ?? DateTime.now().month.toString()), 1),
                  ),
                  style: AppTheme.headingSmall,
                ),
                TextButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final initialDate = DateTime(
                      filter.year ?? now.year,
                      int.parse(filter.month ?? now.month.toString()),
                      1,
                    );

                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDatePickerMode: DatePickerMode.year,
                    );

                    if (selectedDate != null) {
                      ref.read(attendanceFilterProvider.notifier).state = AttendanceFilter(
                        month: selectedDate.month.toString().padLeft(2, '0'),
                        year: selectedDate.year,
                      );
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Attendance History
            historyAsync.when(
              data: (attendances) {
                if (attendances.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 64,
                              color: AppTheme.textSecondaryColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No attendance records',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Card(
                  child: Column(
                    children: attendances.asMap().entries.map((entry) {
                      final index = entry.key;
                      final attendance = entry.value;

                      Color statusColor;
                      String statusText;

                      if (attendance.isPresent) {
                        statusColor = AppTheme.successColor;
                        statusText = 'Present';
                      } else if (attendance.isLate) {
                        statusColor = AppTheme.warningColor;
                        statusText = 'Late';
                      } else {
                        statusColor = AppTheme.errorColor;
                        statusText = 'Absent';
                      }

                      final date = DateTime.parse(attendance.date);
                      final formattedDate = DateFormat('MMM dd, yyyy').format(date);
                      final time = attendance.checkInTime ?? '-';

                      return Column(
                        children: [
                          if (index > 0) const Divider(height: 1),
                          _buildAttendanceItem(
                            date: formattedDate,
                            className: 'Class ${attendance.classId}', // TODO: Get class name from backend
                            status: statusText,
                            statusColor: statusColor,
                            time: time,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => Card(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load attendance history',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String percentage) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.bodySmall),
            Text(
              percentage,
              style: AppTheme.labelLarge.copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.headingMedium.copyWith(
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildAttendanceItem({
    required String date,
    required String className,
    required String status,
    required Color statusColor,
    required String time,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          status == 'Present'
              ? Icons.check_circle
              : status == 'Late'
                  ? Icons.access_time
                  : Icons.cancel,
          color: statusColor,
          size: 24,
        ),
      ),
      title: Text(className, style: AppTheme.titleMedium),
      subtitle: Text(date, style: AppTheme.bodySmall),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(time, style: AppTheme.bodySmall),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
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
                              PieChartSectionData(
                                value: 85,
                                title: '85%',
                                color: AppTheme.successColor,
                                radius: 80,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PieChartSectionData(
                                value: 10,
                                title: '10%',
                                color: AppTheme.errorColor,
                                radius: 80,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PieChartSectionData(
                                value: 5,
                                title: '5%',
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
                        _buildLegendItem('Present', AppTheme.successColor, '85%'),
                        _buildLegendItem('Absent', AppTheme.errorColor, '10%'),
                        _buildLegendItem('Late', AppTheme.warningColor, '5%'),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Total Days', '20'),
                        _buildStatItem('Present', '17'),
                        _buildStatItem('Absent', '2'),
                        _buildStatItem('Late', '1'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'November 2024',
                  style: AppTheme.headingSmall,
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Show month picker
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Attendance History
            Card(
              child: Column(
                children: [
                  _buildAttendanceItem(
                    date: 'Nov 15, 2024',
                    className: 'Mathematics',
                    status: 'Present',
                    statusColor: AppTheme.successColor,
                    time: '10:00 AM',
                  ),
                  const Divider(height: 1),
                  _buildAttendanceItem(
                    date: 'Nov 14, 2024',
                    className: 'Physics',
                    status: 'Late',
                    statusColor: AppTheme.warningColor,
                    time: '10:15 AM',
                  ),
                  const Divider(height: 1),
                  _buildAttendanceItem(
                    date: 'Nov 13, 2024',
                    className: 'Mathematics',
                    status: 'Present',
                    statusColor: AppTheme.successColor,
                    time: '10:00 AM',
                  ),
                  const Divider(height: 1),
                  _buildAttendanceItem(
                    date: 'Nov 12, 2024',
                    className: 'Physics',
                    status: 'Absent',
                    statusColor: AppTheme.errorColor,
                    time: '-',
                  ),
                  const Divider(height: 1),
                  _buildAttendanceItem(
                    date: 'Nov 11, 2024',
                    className: 'Mathematics',
                    status: 'Present',
                    statusColor: AppTheme.successColor,
                    time: '10:00 AM',
                  ),
                ],
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

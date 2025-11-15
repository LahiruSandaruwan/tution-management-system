import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class GradesScreen extends ConsumerWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grades'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Performance Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Performance',
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: 20),

                    // Performance Chart
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const subjects = ['Math', 'Physics', 'Chemistry', 'English'];
                                  if (value.toInt() >= 0 && value.toInt() < subjects.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        subjects[value.toInt()],
                                        style: AppTheme.bodySmall,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()}%', style: AppTheme.bodySmall);
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 25,
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 85, color: AppTheme.primaryColor, width: 20)]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 78, color: AppTheme.primaryColor, width: 20)]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 92, color: AppTheme.primaryColor, width: 20)]),
                            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 88, color: AppTheme.primaryColor, width: 20)]),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Overall Average', '85.75%', AppTheme.primaryColor),
                        _buildStatItem('Highest', '92%', AppTheme.successColor),
                        _buildStatItem('Lowest', '78%', AppTheme.warningColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Subject Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Exams',
                  style: AppTheme.headingSmall,
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Show subject filter
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Grades List by Subject
            _buildSubjectGrades(
              subject: 'Mathematics',
              className: 'Grade 10 - Mathematics',
              exams: [
                {
                  'name': 'Mid-term Exam',
                  'date': 'Nov 10, 2024',
                  'marks': 85,
                  'maxMarks': 100,
                  'grade': 'A',
                },
                {
                  'name': 'Monthly Test',
                  'date': 'Oct 25, 2024',
                  'marks': 78,
                  'maxMarks': 100,
                  'grade': 'B',
                },
              ],
            ),

            const SizedBox(height: 16),

            _buildSubjectGrades(
              subject: 'Physics',
              className: 'Grade 10 - Physics',
              exams: [
                {
                  'name': 'Mid-term Exam',
                  'date': 'Nov 12, 2024',
                  'marks': 92,
                  'maxMarks': 100,
                  'grade': 'A',
                },
                {
                  'name': 'Practical Exam',
                  'date': 'Nov 5, 2024',
                  'marks': 88,
                  'maxMarks': 100,
                  'grade': 'A',
                },
              ],
            ),

            const SizedBox(height: 16),

            _buildSubjectGrades(
              subject: 'Chemistry',
              className: 'Grade 10 - Chemistry',
              exams: [
                {
                  'name': 'Mid-term Exam',
                  'date': 'Nov 8, 2024',
                  'marks': 80,
                  'maxMarks': 100,
                  'grade': 'A',
                },
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.headingMedium.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSubjectGrades({
    required String subject,
    required String className,
    required List<Map<String, dynamic>> exams,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: AppTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  className,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...exams.asMap().entries.map((entry) {
            final index = entry.key;
            final exam = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(height: 1),
                _buildGradeItem(
                  examName: exam['name'] as String,
                  date: exam['date'] as String,
                  marks: exam['marks'] as int,
                  maxMarks: exam['maxMarks'] as int,
                  grade: exam['grade'] as String,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGradeItem({
    required String examName,
    required String date,
    required int marks,
    required int maxMarks,
    required String grade,
  }) {
    final percentage = (marks / maxMarks) * 100;
    final Color gradeColor = percentage >= 75
        ? AppTheme.successColor
        : percentage >= 60
            ? AppTheme.primaryColor
            : percentage >= 40
                ? AppTheme.warningColor
                : AppTheme.errorColor;

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: gradeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            grade,
            style: TextStyle(
              color: gradeColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(examName, style: AppTheme.titleMedium),
      subtitle: Text(date, style: AppTheme.bodySmall),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$marks / $maxMarks',
            style: AppTheme.titleMedium.copyWith(color: gradeColor),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: AppTheme.bodySmall.copyWith(color: gradeColor),
          ),
        ],
      ),
    );
  }
}

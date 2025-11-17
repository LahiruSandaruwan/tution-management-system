import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/grade_provider.dart';

class GradesScreen extends ConsumerWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradesAsync = ref.watch(gradeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grades'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(gradeProvider);
        },
        child: gradesAsync.when(
          data: (data) => _buildGradesContent(data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text(
                  'Failed to load grades',
                  style: AppTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(gradeProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradesContent(Map<String, dynamic> data) {
    final overallStats = data['overall_stats'] as Map<String, dynamic>? ?? {};
    final subjectSummaries = data['subject_summaries'] as List? ?? [];

    if (subjectSummaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No grades available yet',
              style: AppTheme.titleMedium.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
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
                                if (value.toInt() >= 0 && value.toInt() < subjectSummaries.length) {
                                  final subject = subjectSummaries[value.toInt()];
                                  final subjectName = subject['subject_name'] as String;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      subjectName.length > 8 ? '${subjectName.substring(0, 8)}...' : subjectName,
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
                        barGroups: subjectSummaries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final subject = entry.value as Map<String, dynamic>;
                          final average = (subject['average'] as num?)?.toDouble() ?? 0.0;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: average,
                                color: AppTheme.primaryColor,
                                width: 20,
                              )
                            ],
                          );
                        }).toList(),
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
                      _buildStatItem(
                        'Overall Average',
                        '${(overallStats['overall_average'] as num?)?.toStringAsFixed(1) ?? '0.0'}%',
                        AppTheme.primaryColor,
                      ),
                      _buildStatItem(
                        'Highest',
                        '${(overallStats['highest'] as num?)?.toStringAsFixed(0) ?? '0'}%',
                        AppTheme.successColor,
                      ),
                      _buildStatItem(
                        'Lowest',
                        '${(overallStats['lowest'] as num?)?.toStringAsFixed(0) ?? '0'}%',
                        AppTheme.warningColor,
                      ),
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
              Text(
                '${overallStats['total_exams'] ?? 0} Total Exams',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Grades List by Subject
          ...subjectSummaries.map((subject) {
            final subjectData = subject as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSubjectGrades(
                subject: subjectData['subject_name'] as String? ?? 'Unknown',
                className: subjectData['class_name'] as String? ?? 'N/A',
                exams: (subjectData['grades'] as List?)?.cast<Map<String, dynamic>>() ?? [],
              ),
            );
          }),
        ],
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
                _buildGradeItem(exam: exam),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGradeItem({
    required Map<String, dynamic> exam,
  }) {
    final examName = exam['exam_name'] as String? ?? 'Exam';
    final date = exam['exam_date'] as String? ?? '';
    final marks = (exam['marks'] as num?)?.toInt() ?? 0;
    final maxMarks = (exam['max_marks'] as num?)?.toInt() ?? 100;
    final grade = exam['grade'] as String? ?? 'N/A';
    final percentage = (exam['percentage'] as num?)?.toDouble() ?? 0.0;

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

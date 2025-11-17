import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedPeriod = 'month'; // month, quarter, year
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsDataProvider(_startDate, _endDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onTap: _showDateRangePicker,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                _exportData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (analytics) => _buildAnalyticsContent(analytics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text('Failed to load analytics', style: AppTheme.titleMedium),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(analyticsDataProvider(_startDate, _endDate));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(Map<String, dynamic> analytics) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(analyticsDataProvider(_startDate, _endDate));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(),
            const SizedBox(height: 16),

            // Date Range Display
            _buildDateRangeDisplay(),
            const SizedBox(height: 24),

            // Summary Cards
            _buildSummaryCards(analytics),
            const SizedBox(height: 24),

            // Attendance Trend Chart
            Text('Attendance Trend', style: AppTheme.headingSmall),
            const SizedBox(height: 12),
            _buildAttendanceTrendChart(analytics),
            const SizedBox(height: 24),

            // Performance by Subject
            Text('Performance by Subject', style: AppTheme.headingSmall),
            const SizedBox(height: 12),
            _buildPerformanceChart(analytics),
            const SizedBox(height: 24),

            // Payment Status
            Text('Payment Overview', style: AppTheme.headingSmall),
            const SizedBox(height: 12),
            _buildPaymentChart(analytics),
            const SizedBox(height: 24),

            // Weekly Activity Heatmap
            Text('Weekly Activity', style: AppTheme.headingSmall),
            const SizedBox(height: 12),
            _buildActivityHeatmap(analytics),
            const SizedBox(height: 24),

            // Insights
            Text('Insights', style: AppTheme.headingSmall),
            const SizedBox(height: 12),
            _buildInsights(analytics),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _buildPeriodChip('Week', 'week'),
            const SizedBox(width: 8),
            _buildPeriodChip('Month', 'month'),
            const SizedBox(width: 8),
            _buildPeriodChip('Quarter', 'quarter'),
            const SizedBox(width: 8),
            _buildPeriodChip('Year', 'year'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedPeriod = value;
              _updateDateRange(value);
            });
          }
        },
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
        ),
      ),
    );
  }

  void _updateDateRange(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'week':
        _startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'quarter':
        _startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'year':
        _startDate = DateTime(now.year - 1, now.month, now.day);
        break;
    }
    _endDate = now;
  }

  Widget _buildDateRangeDisplay() {
    final format = DateFormat('MMM dd, yyyy');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
        title: Text(
          '${format.format(_startDate)} - ${format.format(_endDate)}',
          style: AppTheme.titleMedium,
        ),
        trailing: const Icon(Icons.edit, size: 20),
        onTap: _showDateRangePicker,
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> analytics) {
    final summary = analytics['summary'] as Map<String, dynamic>? ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Avg Attendance',
            '${summary['avg_attendance'] ?? 0}%',
            Icons.check_circle,
            AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Avg Grade',
            '${summary['avg_grade'] ?? 'N/A'}',
            Icons.school,
            AppTheme.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.headingLarge.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(title, style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTrendChart(Map<String, dynamic> analytics) {
    final attendanceData = analytics['attendance_trend'] as List? ?? [];

    if (attendanceData.isEmpty) {
      return _buildEmptyChart('No attendance data available');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%', style: AppTheme.bodySmall);
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < attendanceData.length) {
                        return Text(
                          attendanceData[index]['label'] ?? '',
                          style: AppTheme.bodySmall,
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    attendanceData.length,
                    (index) => FlSpot(
                      index.toDouble(),
                      (attendanceData[index]['value'] as num?)?.toDouble() ?? 0.0,
                    ),
                  ),
                  isCurved: true,
                  color: AppTheme.primaryColor,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.primaryColor.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(Map<String, dynamic> analytics) {
    final performanceData = analytics['performance_by_subject'] as List? ?? [];

    if (performanceData.isEmpty) {
      return _buildEmptyChart('No performance data available');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}', style: AppTheme.bodySmall);
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < performanceData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            performanceData[index]['subject'] ?? '',
                            style: AppTheme.bodySmall,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(
                performanceData.length,
                (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: (performanceData[index]['score'] as num?)?.toDouble() ?? 0.0,
                      color: AppTheme.accentColor,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentChart(Map<String, dynamic> analytics) {
    final paymentData = analytics['payment_status'] as Map<String, dynamic>? ?? {};
    final paid = (paymentData['paid'] as num?)?.toDouble() ?? 0.0;
    final pending = (paymentData['pending'] as num?)?.toDouble() ?? 0.0;
    final total = paid + pending;

    if (total == 0) {
      return _buildEmptyChart('No payment data available');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 150,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: paid,
                        title: '${(paid / total * 100).toInt()}%',
                        color: AppTheme.successColor,
                        radius: 50,
                      ),
                      PieChartSectionData(
                        value: pending,
                        title: '${(pending / total * 100).toInt()}%',
                        color: Colors.orange,
                        radius: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Paid', AppTheme.successColor, 'Rs. ${paid.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                _buildLegendItem('Pending', Colors.orange, 'Rs. ${pending.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.bodySmall),
            Text(value, style: AppTheme.titleMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityHeatmap(Map<String, dynamic> analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Activity heatmap visualization would go here',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Shows daily activity patterns',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(Map<String, dynamic> analytics) {
    final insights = analytics['insights'] as List? ?? [];

    if (insights.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No insights available for this period',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryColor),
          ),
        ),
      );
    }

    return Column(
      children: insights.map((insight) {
        final type = insight['type'] as String? ?? 'info';
        Color color;
        IconData icon;

        switch (type) {
          case 'success':
            color = AppTheme.successColor;
            icon = Icons.check_circle;
            break;
          case 'warning':
            color = Colors.orange;
            icon = Icons.warning;
            break;
          case 'danger':
            color = AppTheme.errorColor;
            icon = Icons.error;
            break;
          default:
            color = AppTheme.primaryColor;
            icon = Icons.info;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(icon, color: color),
            title: Text(insight['title'] ?? '', style: AppTheme.titleMedium),
            subtitle: Text(insight['message'] ?? '', style: AppTheme.bodySmall),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Card(
      child: Container(
        height: 150,
        alignment: Alignment.center,
        child: Text(
          message,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryColor),
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'custom';
      });
    }
  }

  void _exportData() {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}

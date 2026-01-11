import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_logger.dart';
import '../providers/analytics_provider.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../grades/providers/grade_provider.dart';
import '../../payments/providers/payment_provider.dart';

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
    final analyticsAsync = ref.watch(analyticsDataProvider((_startDate, _endDate)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDateRangePicker,
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
                  ref.invalidate(analyticsDataProvider((_startDate, _endDate)));
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
        ref.invalidate(analyticsDataProvider((_startDate, _endDate)));
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

  Future<void> _exportData() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing export...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Request storage permission
      final permissionStatus = await _requestStoragePermission();
      if (!permissionStatus) {
        if (mounted) Navigator.pop(context);
        _showErrorDialog('Storage permission is required to export data');
        return;
      }

      // Gather all data
      final analyticsAsync = await ref.read(analyticsDataProvider((_startDate, _endDate)).future);

      // Get attendance data
      final attendanceFilter = AttendanceFilter(
        month: null,
        year: null,
      );
      final attendanceHistory = await ref.read(attendanceHistoryProvider(attendanceFilter).future);

      // Get grades data
      final gradesData = await ref.read(gradeProvider.future);
      final grades = (gradesData['subject_summaries'] as List?) ?? [];

      // Get payment history
      final payments = await ref.read(paymentHistoryProvider.future);

      // Generate CSV files
      final dateStr = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
      final directory = await _getExportDirectory();

      // Create analytics CSV
      final analyticsFile = await _createAnalyticsCsv(directory, dateStr, analyticsAsync);

      // Create attendance CSV
      final attendanceFile = await _createAttendanceCsv(directory, dateStr, attendanceHistory);

      // Create grades CSV
      final gradesFile = await _createGradesCsv(directory, dateStr, grades);

      // Create payments CSV
      final paymentsFile = await _createPaymentsCsv(directory, dateStr, payments);

      if (mounted) Navigator.pop(context);

      // Show success dialog with file paths
      _showSuccessDialog([analyticsFile, attendanceFile, gradesFile, paymentsFile]);

      AppLogger.i('Data exported successfully to ${directory.path}');
    } catch (e) {
      AppLogger.e('Error exporting data', e);
      if (mounted) Navigator.pop(context);
      _showErrorDialog('Failed to export data: ${e.toString()}');
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();

      // Android 13+ doesn't need storage permission for app-specific directory
      if (androidVersion >= 13) {
        return true;
      }

      // Android 12 and below
      final status = await Permission.storage.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit storage permission for app documents
      return true;
    }
    return true;
  }

  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // This is a simplified version - in production you'd use device_info_plus
      return 13; // Assume latest for now
    }
    return 0;
  }

  Future<Directory> _getExportDirectory() async {
    if (Platform.isAndroid) {
      // Use app-specific external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final exportDir = Directory('${directory.path}/exports');
        if (!await exportDir.exists()) {
          await exportDir.create(recursive: true);
        }
        return exportDir;
      }
    }

    // Fallback to documents directory
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  Future<String> _createAnalyticsCsv(Directory directory, String dateStr, Map<String, dynamic> analytics) async {
    final rows = <List<dynamic>>[];

    // Header
    rows.add(['Analytics Report', 'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}']);
    rows.add(['Date Range', '${DateFormat('yyyy-MM-dd').format(_startDate)} to ${DateFormat('yyyy-MM-dd').format(_endDate)}']);
    rows.add([]);

    // Summary
    final summary = analytics['summary'] as Map<String, dynamic>? ?? {};
    rows.add(['Summary']);
    rows.add(['Metric', 'Value']);
    rows.add(['Average Attendance', '${summary['avg_attendance'] ?? 0}%']);
    rows.add(['Average Grade', summary['avg_grade'] ?? 'N/A']);
    rows.add(['Total Classes', summary['total_classes'] ?? 0]);
    rows.add(['Classes Attended', summary['classes_attended'] ?? 0]);
    rows.add([]);

    // Attendance Trend
    rows.add(['Attendance Trend']);
    rows.add(['Period', 'Percentage']);
    final attendanceTrend = analytics['attendance_trend'] as List? ?? [];
    for (var item in attendanceTrend) {
      rows.add([item['label'], '${item['value']}%']);
    }
    rows.add([]);

    // Performance by Subject
    rows.add(['Performance by Subject']);
    rows.add(['Subject', 'Score']);
    final performance = analytics['performance_by_subject'] as List? ?? [];
    for (var item in performance) {
      rows.add([item['subject'], item['score']]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final file = File('${directory.path}/analytics_$dateStr.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> _createAttendanceCsv(Directory directory, String dateStr, List<dynamic> attendance) async {
    final rows = <List<dynamic>>[];

    // Header
    rows.add(['Attendance History']);
    rows.add(['Date', 'Status', 'Class ID', 'Check-in Time', 'Notes']);

    // Data rows
    for (var record in attendance) {
      rows.add([
        record.date,
        record.status,
        record.classId,
        record.checkInTime ?? '',
        record.notes ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final file = File('${directory.path}/attendance_$dateStr.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> _createGradesCsv(Directory directory, String dateStr, List<dynamic> grades) async {
    final rows = <List<dynamic>>[];

    // Header
    rows.add(['Grades Report']);
    rows.add(['Subject', 'Average', 'Highest', 'Lowest', 'Exam Count']);

    // Data rows (grades is a list of subject summaries from the API)
    for (var subject in grades) {
      if (subject is Map<String, dynamic>) {
        rows.add([
          subject['subject'] ?? '',
          subject['average'] ?? '',
          subject['highest'] ?? '',
          subject['lowest'] ?? '',
          subject['exam_count'] ?? '',
        ]);
      }
    }

    final csv = const ListToCsvConverter().convert(rows);
    final file = File('${directory.path}/grades_$dateStr.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> _createPaymentsCsv(Directory directory, String dateStr, List<dynamic> payments) async {
    final rows = <List<dynamic>>[];

    // Header
    rows.add(['Payment History']);
    rows.add(['Month', 'Year', 'Amount', 'Status', 'Due Date', 'Payment Date', 'Receipt Number', 'Payment Method']);

    // Data rows
    for (var payment in payments) {
      final String statusText = payment.isPaid
          ? 'Paid'
          : (payment.isOverdue ? 'Overdue' : 'Pending');

      rows.add([
        payment.month,
        payment.year,
        payment.amount,
        statusText,
        payment.dueDate ?? '',
        payment.paymentDate ?? '',
        payment.receiptNumber ?? '',
        payment.paymentMethod ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final file = File('${directory.path}/payments_$dateStr.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  void _showSuccessDialog(List<String> filePaths) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor),
            SizedBox(width: 8),
            Text('Export Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data has been exported to:'),
            const SizedBox(height: 12),
            ...filePaths.map((path) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                path.split('/').last,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            )),
            const SizedBox(height: 12),
            Text(
              'Location: ${filePaths.first.substring(0, filePaths.first.lastIndexOf('/'))}',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Export Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

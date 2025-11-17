import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/api_provider.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedReportType = 'attendance';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel - Report Options
            SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Report Type', style: AppTheme.headingSmall),
                  const SizedBox(height: 16),
                  _buildReportTypeCard(
                    'attendance',
                    'Attendance Report',
                    FontAwesomeIcons.clipboardCheck,
                    'Track student attendance patterns',
                  ),
                  const SizedBox(height: 12),
                  _buildReportTypeCard(
                    'payment',
                    'Payment Report',
                    FontAwesomeIcons.moneyBillWave,
                    'Analyze payment collections',
                  ),
                  const SizedBox(height: 12),
                  _buildReportTypeCard(
                    'gate',
                    'Gate Logs Report',
                    FontAwesomeIcons.doorOpen,
                    'Review gate entry/exit logs',
                  ),
                  const SizedBox(height: 24),

                  // Date Range
                  Text('Date Range', style: AppTheme.headingSmall),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_startDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_endDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateReport,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.analytics),
                      label: const Text('Generate Report'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right Panel - Report Display
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _reportData == null
                      ? _buildEmptyState()
                      : _buildReportDisplay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeCard(
    String type,
    String title,
    IconData icon,
    String description,
  ) {
    final isSelected = _selectedReportType == type;

    return InkWell(
      onTap: () => setState(() => _selectedReportType = type),
      child: Card(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              FaIcon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppTheme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Generate a Report',
              style: AppTheme.headingMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select report type and date range, then click "Generate Report"',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDisplay() {
    if (_reportData == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getReportTitle(),
                      style: AppTheme.headingMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export feature coming soon')),
                    );
                  },
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export PDF'),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: _buildReportContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    if (_reportData == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_reportData!['statistics'] != null)
          _buildStatisticsCards(_reportData!['statistics']),

        const SizedBox(height: 24),

        if (_reportData!['data'] != null && _reportData!['data'].isNotEmpty)
          Text('Report Details', style: AppTheme.headingSmall),
        const SizedBox(height: 16),
        if (_reportData!['data'] != null)
          _buildDataInfo(_reportData!['data']),
      ],
    );
  }

  Widget _buildStatisticsCards(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: stats.entries.map((entry) {
        return Card(
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${entry.value}',
                  style: AppTheme.headingLarge.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatStatLabel(entry.key),
                  style: AppTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDataInfo(dynamic data) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Report generated successfully with ${data is List ? data.length : 1} records',
          style: AppTheme.bodyMedium,
        ),
      ),
    );
  }

  String _getReportTitle() {
    switch (_selectedReportType) {
      case 'attendance':
        return 'Attendance Report';
      case 'payment':
        return 'Payment Report';
      case 'gate':
        return 'Gate Logs Report';
      default:
        return 'Report';
    }
  }

  String _formatStatLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ref.read(apiProvider);
      Map<String, dynamic> data;

      switch (_selectedReportType) {
        case 'attendance':
          data = await apiService.getAttendanceReport(
            startDate: DateFormat('yyyy-MM-dd').format(_startDate),
            endDate: DateFormat('yyyy-MM-dd').format(_endDate),
          );
          break;
        case 'payment':
          data = await apiService.getPaymentReport(
            startDate: DateFormat('yyyy-MM-dd').format(_startDate),
            endDate: DateFormat('yyyy-MM-dd').format(_endDate),
          );
          break;
        case 'gate':
          data = await apiService.getGateLogsReport(
            startDate: DateFormat('yyyy-MM-dd').format(_startDate),
            endDate: DateFormat('yyyy-MM-dd').format(_endDate),
          );
          break;
        default:
          data = {};
      }

      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    }
  }
}

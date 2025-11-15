import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/payment.dart';
import 'package:intl/intl.dart';

class PaymentChart extends StatelessWidget {
  final PaymentStatistics stats;

  const PaymentChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Statistics',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: stats.totalCollected,
                      title: 'Paid\n${currencyFormatter.format(stats.totalCollected)}',
                      color: AppTheme.successColor,
                      radius: 100,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: stats.totalPending,
                      title: 'Pending\n${currencyFormatter.format(stats.totalPending)}',
                      color: AppTheme.warningColor,
                      radius: 100,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: stats.totalOverdue,
                      title: 'Overdue\n${currencyFormatter.format(stats.totalOverdue)}',
                      color: AppTheme.errorColor,
                      radius: 100,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LegendItem(
          color: AppTheme.successColor,
          label: 'Paid',
          count: stats.paidCount,
        ),
        _LegendItem(
          color: AppTheme.warningColor,
          label: 'Pending',
          count: stats.pendingCount,
        ),
        _LegendItem(
          color: AppTheme.errorColor,
          label: 'Overdue',
          count: stats.overdueCount,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
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
        Text(
          '$label ($count)',
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }
}

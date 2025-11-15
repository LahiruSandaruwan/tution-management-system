import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Summary',
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            label: 'Total Paid',
                            value: currencyFormatter.format(18000),
                            color: AppTheme.successColor,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppTheme.dividerColor,
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            label: 'Pending',
                            value: currencyFormatter.format(6000),
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            label: 'Overdue',
                            value: currencyFormatter.format(0),
                            color: AppTheme.errorColor,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppTheme.dividerColor,
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            label: 'Total',
                            value: currencyFormatter.format(24000),
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Payment History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment History',
                  style: AppTheme.headingSmall,
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Filter by year
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('2024'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment List
            Card(
              child: Column(
                children: [
                  _buildPaymentItem(
                    month: 'November 2024',
                    amount: currencyFormatter.format(6000),
                    status: 'Pending',
                    statusColor: AppTheme.warningColor,
                    dueDate: 'Due: Nov 10, 2024',
                    receiptNumber: null,
                  ),
                  const Divider(height: 1),
                  _buildPaymentItem(
                    month: 'October 2024',
                    amount: currencyFormatter.format(6000),
                    status: 'Paid',
                    statusColor: AppTheme.successColor,
                    dueDate: 'Paid: Oct 8, 2024',
                    receiptNumber: 'RCP-ABC-20241008-1234',
                  ),
                  const Divider(height: 1),
                  _buildPaymentItem(
                    month: 'September 2024',
                    amount: currencyFormatter.format(6000),
                    status: 'Paid',
                    statusColor: AppTheme.successColor,
                    dueDate: 'Paid: Sep 5, 2024',
                    receiptNumber: 'RCP-XYZ-20240905-5678',
                  ),
                  const Divider(height: 1),
                  _buildPaymentItem(
                    month: 'August 2024',
                    amount: currencyFormatter.format(6000),
                    status: 'Paid',
                    statusColor: AppTheme.successColor,
                    dueDate: 'Paid: Aug 7, 2024',
                    receiptNumber: 'RCP-DEF-20240807-9012',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Payment due date is 10th of every month. Late payments may result in access restrictions.',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
  }) {
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPaymentItem({
    required String month,
    required String amount,
    required String status,
    required Color statusColor,
    required String dueDate,
    String? receiptNumber,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          status == 'Paid' ? Icons.check_circle : Icons.schedule,
          color: statusColor,
        ),
      ),
      title: Text(month, style: AppTheme.titleMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(dueDate, style: AppTheme.bodySmall),
          if (receiptNumber != null) ...[
            const SizedBox(height: 2),
            Text(
              receiptNumber,
              style: AppTheme.bodySmall.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amount,
            style: AppTheme.titleLarge.copyWith(color: statusColor),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

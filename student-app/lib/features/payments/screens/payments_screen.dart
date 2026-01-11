import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/payment_provider.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  String _selectedYear = 'all';

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    final summaryAsync = ref.watch(paymentSummaryProvider);
    final historyAsync = ref.watch(paymentHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(paymentSummaryProvider);
          ref.invalidate(paymentHistoryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Payment Summary Card
            summaryAsync.when(
              data: (summary) {
                final total = summary.totalPaid + summary.totalPending + summary.totalOverdue;
                return Card(
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
                                value: currencyFormatter.format(summary.totalPaid),
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
                                value: currencyFormatter.format(summary.totalPending),
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
                                value: currencyFormatter.format(summary.totalOverdue),
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
                                value: currencyFormatter.format(total),
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                          'Failed to load payment summary',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ],
                    ),
                  ),
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
                PopupMenuButton<String>(
                  initialValue: _selectedYear,
                  onSelected: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'all',
                      child: Text('All Years'),
                    ),
                    PopupMenuItem(
                      value: DateTime.now().year.toString(),
                      child: Text(DateTime.now().year.toString()),
                    ),
                    PopupMenuItem(
                      value: (DateTime.now().year - 1).toString(),
                      child: Text((DateTime.now().year - 1).toString()),
                    ),
                    PopupMenuItem(
                      value: (DateTime.now().year - 2).toString(),
                      child: Text((DateTime.now().year - 2).toString()),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_list, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        _selectedYear == 'all' ? 'All Years' : _selectedYear,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment List
            historyAsync.when(
              data: (payments) {
                // Filter payments by selected year
                final filteredPayments = _selectedYear == 'all'
                    ? payments
                    : payments.where((p) => p.year == int.parse(_selectedYear)).toList();

                if (filteredPayments.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: AppTheme.textSecondaryColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No payment history',
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
                    children: filteredPayments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final payment = entry.value;

                      Color statusColor;
                      String statusText;

                      if (payment.isPaid) {
                        statusColor = AppTheme.successColor;
                        statusText = 'Paid';
                      } else if (payment.isOverdue) {
                        statusColor = AppTheme.errorColor;
                        statusText = 'Overdue';
                      } else {
                        statusColor = AppTheme.warningColor;
                        statusText = 'Pending';
                      }

                      final monthName = DateFormat('MMMM yyyy').format(
                        DateTime(payment.year, int.parse(payment.month.split('-')[1]), 1),
                      );

                      String dateText;
                      if (payment.isPaid && payment.paymentDate != null) {
                        final date = DateTime.parse(payment.paymentDate!);
                        dateText = 'Paid: ${DateFormat('MMM d, yyyy').format(date)}';
                      } else if (payment.dueDate != null) {
                        final date = DateTime.parse(payment.dueDate!);
                        dateText = 'Due: ${DateFormat('MMM d, yyyy').format(date)}';
                      } else {
                        dateText = '-';
                      }

                      return Column(
                        children: [
                          if (index > 0) const Divider(height: 1),
                          _buildPaymentItem(
                            month: monthName,
                            amount: currencyFormatter.format(payment.amount),
                            status: statusText,
                            statusColor: statusColor,
                            dueDate: dateText,
                            receiptNumber: payment.receiptNumber,
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
                          'Failed to load payment history',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ],
                    ),
                  ),
                ),
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

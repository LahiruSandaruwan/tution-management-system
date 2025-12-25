import 'package:flutter/material.dart';
import '../../../models/payment.dart';
import 'package:intl/intl.dart';

class PaymentTable extends StatelessWidget {
  final List<Payment> payments;

  const PaymentTable({
    super.key,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 24,
            headingRowColor: MaterialStateProperty.all(
              Colors.blue.withOpacity(0.1),
            ),
            columns: const [
              DataColumn(label: Text('Receipt #', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Student', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Month', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Year', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Payment Date', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Method', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: payments.map((payment) {
              return DataRow(
                cells: [
                  DataCell(Text(payment.receiptNumber ?? 'N/A')),
                  DataCell(
                    Text(payment.student?.displayName ?? 'N/A'),
                  ),
                  DataCell(Text(payment.month)),
                  DataCell(Text('${payment.year}')),
                  DataCell(
                    Text(
                      'Rs. ${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    Text(
                      payment.dueDate != null
                          ? DateFormat('yyyy-MM-dd').format(payment.dueDate!)
                          : 'N/A',
                    ),
                  ),
                  DataCell(
                    Text(
                      payment.paymentDate != null
                          ? DateFormat('yyyy-MM-dd').format(payment.paymentDate!)
                          : 'Not paid',
                    ),
                  ),
                  DataCell(
                    Text(payment.paymentMethod ?? 'N/A'),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(payment.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        payment.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(payment.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

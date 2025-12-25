import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/payment.dart';
import '../../dashboard/widgets/stat_card.dart';
import 'package:intl/intl.dart';

class PaymentStatsCards extends StatelessWidget {
  final PaymentStatistics statistics;

  const PaymentStatsCards({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ');

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2,
      children: [
        StatCard(
          title: 'Total Collected',
          value: currencyFormat.format(statistics.totalCollected),
          subtitle: '${statistics.paidCount} payments',
          icon: FontAwesomeIcons.checkCircle,
          color: Colors.green,
        ),
        StatCard(
          title: 'Total Pending',
          value: currencyFormat.format(statistics.totalPending),
          subtitle: '${statistics.pendingCount} payments',
          icon: FontAwesomeIcons.clock,
          color: Colors.orange,
        ),
        StatCard(
          title: 'Total Overdue',
          value: currencyFormat.format(statistics.totalOverdue),
          subtitle: '${statistics.overdueCount} payments',
          icon: FontAwesomeIcons.exclamationTriangle,
          color: Colors.red,
        ),
      ],
    );
  }
}

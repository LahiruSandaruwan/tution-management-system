import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildReportCard(
              context,
              title: 'Attendance Report',
              icon: Icons.calendar_today,
              color: AppTheme.primaryColor,
            ),
            _buildReportCard(
              context,
              title: 'Payment Report',
              icon: Icons.payments,
              color: AppTheme.successColor,
            ),
            _buildReportCard(
              context,
              title: 'Gate Logs Report',
              icon: Icons.door_front_door,
              color: AppTheme.secondaryColor,
            ),
            _buildReportCard(
              context,
              title: 'Academic Report',
              icon: Icons.school,
              color: AppTheme.warningColor,
            ),
            _buildReportCard(
              context,
              title: 'Student Performance',
              icon: Icons.trending_up,
              color: Colors.purple,
            ),
            _buildReportCard(
              context,
              title: 'Financial Summary',
              icon: Icons.account_balance,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to report
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

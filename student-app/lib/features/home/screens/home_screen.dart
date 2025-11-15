import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final student = authState.student;
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: AppTheme.bodySmall.copyWith(color: Colors.white70),
            ),
            Text(
              user?.name ?? 'Student',
              style: AppTheme.titleLarge.copyWith(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.push('/notifications');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh data
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'S',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student?.studentIdNumber ?? 'N/A',
                              style: AppTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              student?.grade ?? 'N/A',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: student?.isActive == true
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          student?.isActive == true ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: student?.isActive == true
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Stats
              Text(
                'Overview',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    title: 'Attendance',
                    value: '--%',
                    icon: FontAwesomeIcons.clipboardCheck,
                    color: AppTheme.primaryColor,
                    onTap: () {},
                  ),
                  _buildStatCard(
                    title: 'Payments',
                    value: 'Rs. --',
                    icon: FontAwesomeIcons.moneyBill,
                    color: AppTheme.successColor,
                    onTap: () {},
                  ),
                  _buildStatCard(
                    title: 'Classes',
                    value: '--',
                    icon: FontAwesomeIcons.bookOpen,
                    color: AppTheme.accentColor,
                    onTap: () {},
                  ),
                  _buildStatCard(
                    title: 'Grades',
                    value: '--',
                    icon: FontAwesomeIcons.chartLine,
                    color: Colors.purple,
                    onTap: () {
                      context.push('/grades');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: AppTheme.headingSmall,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Activity List
              Card(
                child: Column(
                  children: [
                    _buildActivityItem(
                      icon: Icons.check_circle,
                      iconColor: AppTheme.successColor,
                      title: 'Attendance Marked',
                      subtitle: 'Mathematics - Present',
                      time: '2 hours ago',
                    ),
                    const Divider(height: 1),
                    _buildActivityItem(
                      icon: Icons.payment,
                      iconColor: AppTheme.primaryColor,
                      title: 'Payment Recorded',
                      subtitle: 'Rs. 6000 - November',
                      time: '1 day ago',
                    ),
                    const Divider(height: 1),
                    _buildActivityItem(
                      icon: Icons.school,
                      iconColor: AppTheme.accentColor,
                      title: 'New Grade Added',
                      subtitle: 'Physics - 85/100',
                      time: '3 days ago',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  FaIcon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: AppTheme.headingMedium.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: AppTheme.titleMedium),
      subtitle: Text(subtitle, style: AppTheme.bodySmall),
      trailing: Text(time, style: AppTheme.bodySmall),
    );
  }
}

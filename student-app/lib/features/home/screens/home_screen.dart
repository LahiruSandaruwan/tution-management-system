import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/offline_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final student = authState.student;
    final user = authState.user;
    final dashboardAsync = ref.watch(dashboardStatsProvider);
    final activitiesAsync = ref.watch(recentActivitiesProvider);

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
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentActivitiesProvider);
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
              dashboardAsync.when(
                data: (stats) => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatCard(
                      title: 'Attendance',
                      value: '${stats.attendancePercentage.toStringAsFixed(1)}%',
                      icon: FontAwesomeIcons.clipboardCheck,
                      color: AppTheme.primaryColor,
                      onTap: () {},
                    ),
                    _buildStatCard(
                      title: 'Pending',
                      value: 'Rs. ${stats.pendingAmount.toStringAsFixed(0)}',
                      icon: FontAwesomeIcons.moneyBill,
                      color: stats.pendingAmount > 0 ? AppTheme.errorColor : AppTheme.successColor,
                      onTap: () {},
                    ),
                    _buildStatCard(
                      title: 'Classes',
                      value: '${stats.totalClasses}',
                      icon: FontAwesomeIcons.bookOpen,
                      color: AppTheme.accentColor,
                      onTap: () {},
                    ),
                    _buildStatCard(
                      title: 'Status',
                      value: stats.paymentStatus,
                      icon: FontAwesomeIcons.chartLine,
                      color: stats.paymentStatus == 'paid' ? AppTheme.successColor : Colors.orange,
                      onTap: () {
                        context.push('/grades');
                      },
                    ),
                  ],
                ),
                loading: () => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: List.generate(4, (index) => Card(
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error loading stats: ${error.toString()}',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                ),
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
              activitiesAsync.when(
                data: (activities) {
                  if (activities.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No recent activities',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Card(
                    child: Column(
                      children: activities.asMap().entries.map((entry) {
                        final index = entry.key;
                        final activity = entry.value;

                        IconData icon;
                        Color iconColor;

                        switch (activity.type) {
                          case 'attendance':
                            icon = Icons.check_circle;
                            iconColor = AppTheme.successColor;
                            break;
                          case 'payment':
                            icon = Icons.payment;
                            iconColor = AppTheme.primaryColor;
                            break;
                          case 'grade':
                            icon = Icons.school;
                            iconColor = AppTheme.accentColor;
                            break;
                          default:
                            icon = Icons.info;
                            iconColor = Colors.grey;
                        }

                        return Column(
                          children: [
                            if (index > 0) const Divider(height: 1),
                            _buildActivityItem(
                              icon: icon,
                              iconColor: iconColor,
                              title: activity.title,
                              subtitle: activity.description,
                              time: activity.timeAgo,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
                loading: () => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error loading activities',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
            ),
          ),
        ],
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

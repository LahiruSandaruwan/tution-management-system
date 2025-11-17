import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/offline_indicator.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final teacher = authState.teacher;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
            Text(
              user?.name ?? 'Teacher',
              style: AppTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
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
                // TODO: Refresh dashboard data
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teacher Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'T',
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
                              teacher?.employeeId ?? 'N/A',
                              style: AppTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              teacher?.specialization ?? 'N/A',
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
                          color: teacher?.isActive == true
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          teacher?.isActive == true ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: teacher?.isActive == true
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
                    title: 'My Classes',
                    value: '--',
                    icon: FontAwesomeIcons.chalkboardTeacher,
                    color: AppTheme.primaryColor,
                    onTap: () {},
                  ),
                  _buildStatCard(
                    title: 'Total Students',
                    value: '--',
                    icon: FontAwesomeIcons.userGraduate,
                    color: AppTheme.successColor,
                    onTap: () {},
                  ),
                  _buildStatCard(
                    title: 'Today\'s Classes',
                    value: '--',
                    icon: FontAwesomeIcons.calendar,
                    color: AppTheme.accentColor,
                    onTap: () {},
                  ),
                  _buildStatCard(
                    title: 'Pending Tasks',
                    value: '--',
                    icon: FontAwesomeIcons.tasks,
                    color: AppTheme.warningColor,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Today's Schedule
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Schedule',
                    style: AppTheme.headingSmall,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Card(
                child: Column(
                  children: [
                    _buildScheduleItem(
                      className: 'Grade 10 - Mathematics',
                      time: '10:00 AM - 12:00 PM',
                      room: 'Room 101',
                      studentCount: 25,
                      color: Colors.blue,
                    ),
                    const Divider(height: 1),
                    _buildScheduleItem(
                      className: 'Grade 11 - Physics',
                      time: '2:00 PM - 4:00 PM',
                      room: 'Room 203',
                      studentCount: 20,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 12),

              Card(
                child: Column(
                  children: [
                    _buildActionItem(
                      icon: FontAwesomeIcons.clipboardCheck,
                      title: 'Mark Attendance',
                      subtitle: 'Take attendance for your classes',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _buildActionItem(
                      icon: FontAwesomeIcons.chartBar,
                      title: 'Add Grades',
                      subtitle: 'Record exam results',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _buildActionItem(
                      icon: FontAwesomeIcons.users,
                      title: 'View Students',
                      subtitle: 'Manage your class students',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildScheduleItem({
    required String className,
    required String time,
    required String room,
    required int studentCount,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 4,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      title: Text(className, style: AppTheme.titleMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(time, style: AppTheme.bodySmall),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(room, style: AppTheme.bodySmall),
            ],
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$studentCount Students',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FaIcon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(title, style: AppTheme.titleMedium),
      subtitle: Text(subtitle, style: AppTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor),
      onTap: onTap,
    );
  }
}

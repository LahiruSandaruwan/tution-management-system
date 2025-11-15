import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/dashboard_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/payment_chart.dart';
import '../widgets/attendance_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardProvider.notifier).loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${dashboardState.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(dashboardProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : dashboardState.stats == null
                  ? const Center(child: Text('No data available'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.read(dashboardProvider.notifier).refresh();
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Overview Stats
                            Text(
                              'Overview',
                              style: AppTheme.headingSmall,
                            ),
                            const SizedBox(height: 16),
                            _buildOverviewStats(dashboardState.stats!),

                            const SizedBox(height: 32),

                            // Charts Section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: PaymentChart(
                                    stats: dashboardState.stats!.payments,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AttendanceChart(
                                    stats: dashboardState.stats!.attendance,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Gate Activity
                            Text(
                              'Gate Activity (Today)',
                              style: AppTheme.headingSmall,
                            ),
                            const SizedBox(height: 16),
                            _buildGateStats(dashboardState.stats!),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildOverviewStats(stats) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Total Students',
          value: stats.students.total.toString(),
          subtitle: '${stats.students.active} Active',
          icon: FontAwesomeIcons.userGraduate,
          color: AppTheme.primaryColor,
        ),
        StatCard(
          title: 'Total Teachers',
          value: stats.teachers.total.toString(),
          subtitle: '${stats.teachers.active} Active',
          icon: FontAwesomeIcons.chalkboardTeacher,
          color: AppTheme.successColor,
        ),
        StatCard(
          title: 'Total Classes',
          value: stats.classes.total.toString(),
          subtitle: 'Active classes',
          icon: FontAwesomeIcons.bookOpen,
          color: AppTheme.secondaryColor,
        ),
        StatCard(
          title: 'Payment Defaulters',
          value: stats.defaultersCount.toString(),
          subtitle: 'Overdue payments',
          icon: FontAwesomeIcons.exclamationTriangle,
          color: AppTheme.errorColor,
        ),
      ],
    );
  }

  Widget _buildGateStats(stats) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Entries Today',
          value: stats.gate.todayEntries.toString(),
          subtitle: 'Students entered',
          icon: FontAwesomeIcons.arrowRightToBracket,
          color: AppTheme.successColor,
        ),
        StatCard(
          title: 'Exits Today',
          value: stats.gate.todayExits.toString(),
          subtitle: 'Students exited',
          icon: FontAwesomeIcons.arrowRightFromBracket,
          color: AppTheme.primaryColor,
        ),
        StatCard(
          title: 'Currently Inside',
          value: stats.gate.currentlyInside.toString(),
          subtitle: 'Students on premises',
          icon: FontAwesomeIcons.userCheck,
          color: AppTheme.secondaryColor,
        ),
        StatCard(
          title: 'Denied Today',
          value: stats.gate.todayDenied.toString(),
          subtitle: 'Access denied',
          icon: FontAwesomeIcons.ban,
          color: AppTheme.errorColor,
        ),
      ],
    );
  }
}

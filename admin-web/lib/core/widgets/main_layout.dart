import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../theme/app_theme.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: AppTheme.primaryColor,
            child: Column(
              children: [
                // Logo/Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tuition Admin',
                        style: AppTheme.titleLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),

                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _NavItem(
                        icon: FontAwesomeIcons.gauge,
                        label: 'Dashboard',
                        route: '/',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.userGraduate,
                        label: 'Students',
                        route: '/students',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.chalkboardTeacher,
                        label: 'Teachers',
                        route: '/teachers',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.bookOpen,
                        label: 'Classes',
                        route: '/classes',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.moneyBillWave,
                        label: 'Payments',
                        route: '/payments',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.clipboardCheck,
                        label: 'Attendance',
                        route: '/attendance',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.chartLine,
                        label: 'Reports',
                        route: '/reports',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.doorOpen,
                        label: 'Gate Monitoring',
                        route: '/gate',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.bell,
                        label: 'Notifications',
                        route: '/notifications',
                      ),
                    ],
                  ),
                ),

                // User Info & Logout
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white24),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'A',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user?.name ?? 'Admin',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          user?.role ?? 'Administrator',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(authProvider.notifier).logout();
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: FaIcon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        title: Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => context.go(route),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.blue,
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
                      const Text(
                        'Tuition Admin',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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
                      const Divider(
                        color: Colors.white24,
                        height: 16,
                        indent: 8,
                        endIndent: 8,
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.gear,
                        label: 'Settings',
                        route: '/settings',
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
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user?.name ?? 'Admin',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          user?.role ?? 'Administrator',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white70,
                        ),
                        onTap: () {
                          context.go('/profile');
                        },
                      ),
                      const SizedBox(height: 8),
                      // Theme Toggle
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isDarkMode
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isDarkMode ? 'Dark Mode' : 'Light Mode',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: isDarkMode,
                              onChanged: (_) {
                                ref
                                    .read(themeModeProvider.notifier)
                                    .toggleTheme();
                              },
                              activeColor: Colors.white,
                              activeTrackColor: Colors.white.withOpacity(0.5),
                              inactiveThumbColor: Colors.white70,
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                            ),
                          ],
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
              color: Colors.grey[100],
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => context.go(route),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/schedule/screens/schedule_screen.dart';
import '../../features/attendance/screens/attendance_screen.dart';
import '../../features/payments/screens/payments_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ScheduleScreen(),
    AttendanceScreen(),
    PaymentsScreen(),
    ProfileScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_today_outlined),
      selectedIcon: Icon(Icons.calendar_today),
      label: 'Schedule',
    ),
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.clipboardCheck, size: 20),
      selectedIcon: FaIcon(FontAwesomeIcons.clipboardCheck, size: 20),
      label: 'Attendance',
    ),
    NavigationDestination(
      icon: Icon(Icons.payment_outlined),
      selectedIcon: Icon(Icons.payment),
      label: 'Payments',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
        backgroundColor: AppTheme.cardColor,
        indicatorColor: AppTheme.primaryColor.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

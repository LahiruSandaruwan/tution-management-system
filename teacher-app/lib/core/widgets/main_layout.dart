import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/classes/screens/classes_screen.dart';
import '../../features/attendance/screens/mark_attendance_screen.dart';
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
    ClassesScreen(),
    MarkAttendanceScreen(),
    ProfileScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.chalkboardTeacher, size: 20),
      selectedIcon: FaIcon(FontAwesomeIcons.chalkboardTeacher, size: 20),
      label: 'Classes',
    ),
    NavigationDestination(
      icon: FaIcon(FontAwesomeIcons.clipboardCheck, size: 20),
      selectedIcon: FaIcon(FontAwesomeIcons.clipboardCheck, size: 20),
      label: 'Attendance',
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

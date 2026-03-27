import 'package:flutter/material.dart';
import '../Screens/dashboard_screen.dart';
import '../Screens/hub_home_screen.dart';
import '../Screens/map_screen.dart';
import '../Screens/profile_screen.dart';
import '../features/reporting/report_screen.dart';
import '../features/sos/sos_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Bottom Navigation Bar Tabs
  final List<Widget> _screens = [
    const DashboardScreen(),   // Index 0 - Home
    HubHomeScreen(),           // Index 1 - Learn
    const ReportScreen(),      // Index 2 - Report
    MapScreen(),               // Index 3 - Buddy
    const ProfileScreen(),     // Index 4 - Profile
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1D9E75),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_gmailerrorred),
            activeIcon: Icon(Icons.report),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Buddy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Helper class to trigger the SOS Screen safely across the app
class SosHelper {
  static void showSosScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SosScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}

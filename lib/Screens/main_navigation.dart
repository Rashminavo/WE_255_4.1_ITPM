import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/auth/app_role.dart';
import '../core/auth/role_home_resolver.dart';
import 'dashboard_screen.dart';
import 'counselor_screen.dart';
import 'quiz_screen.dart';
import 'hub_home_screen.dart';
import '../features/reporting/report_screen.dart';
import 'buddy_hub_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Define the screens list
  final List<Widget> _screens = [
    const DashboardScreen(), // Home
    const HubHomeScreen(), // Learn Screen (Member 1) - Awareness Hub
    const ReportScreen(), // Report Screen (Member 2)
    const BuddyHubScreen(), // Buddy Module (Member 3)
    const CounselorScreen(), // Support/Counselor
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Add haptic feedback for better UX
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppRole>(
      future: _resolveCurrentRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentRole = snapshot.data ?? AppRole.student;

        if (currentRole != AppRole.student) {
          return RoleHomeResolver.resolveHome(currentRole);
        }

        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1D9E75),
            unselectedItemColor: Colors.grey,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.book_outlined),
                  activeIcon: Icon(Icons.book),
                  label: 'Learn'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.report_gmailerrorred),
                  activeIcon: Icon(Icons.report),
                  label: 'Report'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Buddy'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.psychology_outlined),
                  activeIcon: Icon(Icons.psychology),
                  label: 'Support'),
            ],
          ),
        );
      },
    );
  }

  Future<AppRole> _resolveCurrentRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return AppRole.student;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data();
      return AppRoleX.fromString(userData?['role'] as String?);
    } catch (_) {
      return AppRole.student;
    }
  }
}

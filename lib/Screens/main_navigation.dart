import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shake/shake.dart';
import 'dashboard_screen.dart';
import 'hub_home_screen.dart';
import 'buddy_hub_screen.dart';
import '../features/reporting/report_screen.dart';
import '../features/sos/sos_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  ShakeDetector? _shakeDetector;

  // Define the screens list
  final List<Widget> _screens = [
    const DashboardScreen(), // Home
    const HubHomeScreen(), // Learn Screen
    const ReportScreen(), // Report Screen
    const BuddyHubScreen(), // Buddy Module
    const SosScreen(), // SOS Screen (Support/Emergency)
  ];

  @override
  void initState() {
    super.initState();
    _startGlobalShakeDetection();
  }

  void _startGlobalShakeDetection() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        _showShakeEmergencyDialog();
      },
      shakeThresholdGravity: 2.7,
    );
  }

  void _showShakeEmergencyDialog() {
    if (!mounted) return;

    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Emergency Detected!',
          style:
              TextStyle(color: Color(0xFFE24B4A), fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFE24B4A), size: 48),
            SizedBox(height: 16),
            Text(
              'A shake was detected. Do you need help?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('False Alarm', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
            ),
            child:
                const Text('Help Me!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToSOS() {
    setState(() {
      _currentIndex = 4; // Navigate to SOS screen
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Add haptic feedback for better UX
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
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
              icon: Icon(Icons.sos_sharp),
              activeIcon: Icon(Icons.sos_sharp),
              label: 'SOS'),
        ],
      ),
    );
  }
}

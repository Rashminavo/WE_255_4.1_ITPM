import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';
import 'counselor_screen.dart';

// TODO: Team members - Import your screens here
// import 'learn_screen.dart';       // Member 1
// import 'report_sos_screen.dart';  // Member 2
// import 'buddy_screen.dart';       // Member 3

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  // Define the screens list
  final List<Widget> _screens = [
    const DashboardScreen(),           // Home
    const Center(                      // Learn Screen (Member 1)
      child: Text(
        "Learn Screen\n(Member 1)",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    ),
    const Center(                      // Report & SOS (Member 2)
      child: Text(
        "Report & SOS\n(Member 2)",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    ),
    const Center(                      // Buddy Module (Member 3)
      child: Text(
        "Buddy Module\n(Member 3)",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    ),
    const CounselorScreen(),           // Support/Counselor
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
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined), 
            activeIcon: Icon(Icons.book), 
            label: 'Learn'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_gmailerrorred), 
            activeIcon: Icon(Icons.report), 
            label: 'Report'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline), 
            activeIcon: Icon(Icons.people), 
            label: 'Buddy'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined), 
            activeIcon: Icon(Icons.psychology), 
            label: 'Support'
          ),
        ],
      ),
    );
  }
}
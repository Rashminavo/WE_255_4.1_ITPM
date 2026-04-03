import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/buddy_provider.dart';
import 'buddy_search_screen.dart';
import 'buddy_requests_screen.dart';
import 'my_buddies_screen.dart';

class BuddyHubScreen extends StatefulWidget {
  const BuddyHubScreen({super.key});

  @override
  State<BuddyHubScreen> createState() => _BuddyHubScreenState();
}

class _BuddyHubScreenState extends State<BuddyHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Use addPostFrameCallback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      final userId = authProvider.user!.uid;
      
      // Fetch all users for search
      context.read<BuddyProvider>().searchBuddies(userId);
      
      // Fetch pending buddy requests
      context.read<BuddyProvider>().fetchMatches(userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text(
          "Buddy Network",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1D9E75),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color.fromARGB(255, 25, 153, 38),
          labelColor: const Color.fromARGB(255, 225, 223, 223),
          unselectedLabelColor: const Color.fromARGB(255, 225, 223, 223),
          tabs: const [
            Tab(
              icon: Icon(Icons.search),
              text: "Search",
            ),
            Tab(
              icon: Icon(Icons.notifications),
              text: "Requests",
            ),
            Tab(
              icon: Icon(Icons.people),
              text: "My Buddies",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BuddySearchScreen(),
          BuddyRequestsScreen(),
          MyBuddiesScreen(),
        ],
      ),
    );
  }
}

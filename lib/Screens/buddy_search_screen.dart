import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/buddy_provider.dart';

class BuddySearchScreen extends StatefulWidget {
  const BuddySearchScreen({super.key});

  @override
  State<BuddySearchScreen> createState() => _BuddySearchScreenState();
}

class _BuddySearchScreenState extends State<BuddySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Set<String> _sentRequestUserIds = {}; // Track sent requests

  @override
  void initState() {
    super.initState();
    // Load existing sent requests
    _loadSentRequests();
  }

  Future<void> _loadSentRequests() async {
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('buddy_matches')
            .where('user1Id', isEqualTo: currentUser.uid)
            .where('status', isEqualTo: 'pending')
            .get();

        setState(() {
          _sentRequestUserIds = snapshot.docs
              .map((doc) => doc['user2Id'] as String)
              .toSet();
        });
      } catch (e) {
        debugPrint('Error loading sent requests: $e');
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().user;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search buddies by name or faculty...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          
          const SizedBox(height: 8),

          // All Users List with Request Filtering
          FutureBuilder<Set<String>>(
            future: _getRequestedUserIds(currentUser?.uid ?? ""),
            builder: (context, requestedSnapshot) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No users found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final requestedUserIds = requestedSnapshot.data ?? {};

                  // Filter users - include all except current user and those with active connections
                  final allUsers = snapshot.data!.docs
                      .where((doc) {
                        // Exclude current user
                        if (doc['uid'] == currentUser?.uid) return false;
                        
                        // Apply search filter
                        if (_searchQuery.isEmpty) return true;
                        
                        final name = (doc['name'] ?? '').toString().toLowerCase();
                        final faculty = (doc['faculty'] ?? doc['department'] ?? '').toString().toLowerCase();
                        return name.contains(_searchQuery) || faculty.contains(_searchQuery);
                      })
                      .toList();

                  if (allUsers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No matching buddies found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allUsers.length,
                      itemBuilder: (context, index) {
                        final userDoc = allUsers[index];
                        final userId = userDoc['uid'] as String;
                        final name = userDoc['name'] as String? ?? "Unknown";
                        final faculty = userDoc['faculty'] as String? ?? userDoc['department'] as String? ?? "N/A";
                        final phone = userDoc['phone'] as String? ?? "";

                        return _buildUserCard(
                          context,
                          userId,
                          name,
                          faculty,
                          phone,
                          currentUser?.uid ?? "",
                          requestedUserIds.contains(userId),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<Set<String>> _getRequestedUserIds(String currentUserId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('buddy_matches')
          .where('user1Id', isEqualTo: currentUserId)
          .where('status', whereIn: ['pending', 'active'])
          .get();

      return snapshot.docs
          .map((doc) => doc['user2Id'] as String)
          .toSet();
    } catch (e) {
      debugPrint('Error getting requested user IDs: $e');
      return {};
    }
  }

  Widget _buildUserCard(
    BuildContext context,
    String userId,
    String name,
    String faculty,
    String phone,
    String currentUserId,
    bool isPending,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF1D9E75),
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isPending)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Pending",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        faculty,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (phone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            phone,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Send Request Button or Cancel Button
            SizedBox(
              width: double.infinity,
              child: isPending
                  ? ElevatedButton(
                      onPressed: () => _cancelBuddyRequest(
                        context,
                        currentUserId,
                        userId,
                        name,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        "Cancel Request",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _sendBuddyRequest(
                        context,
                        currentUserId,
                        userId,
                        name,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9E75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        "Send Request",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendBuddyRequest(
    BuildContext context,
    String fromUserId,
    String toUserId,
    String toUserName,
  ) {
    context.read<BuddyProvider>().sendBuddyRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
      matchScore: 75, // Default match score
    ).then((success) {
      if (success) {
        setState(() {
          _sentRequestUserIds.add(toUserId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Request sent to $toUserName!"),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        // Reload the sent requests to refresh the pending badge
        _loadSentRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send request"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _cancelBuddyRequest(
    BuildContext context,
    String fromUserId,
    String toUserId,
    String toUserName,
  ) async {
    // Find the match ID to delete
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('buddy_matches')
          .where('user1Id', isEqualTo: fromUserId)
          .where('user2Id', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final matchId = snapshot.docs.first.id;
        
        // Delete the request
        await FirebaseFirestore.instance
            .collection('buddy_matches')
            .doc(matchId)
            .delete();

        setState(() {
          _sentRequestUserIds.remove(toUserId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Request to $toUserName cancelled"),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
          // Reload the sent requests to refresh the pending badge
          _loadSentRequests();
        }
      }
    } catch (e) {
      debugPrint('Error cancelling request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to cancel request"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

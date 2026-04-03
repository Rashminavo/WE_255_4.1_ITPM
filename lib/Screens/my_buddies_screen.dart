import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import './chat_screen.dart';

class MyBuddiesScreen extends StatefulWidget {
  const MyBuddiesScreen({super.key});

  @override
  State<MyBuddiesScreen> createState() => _MyBuddiesScreenState();
}

class _MyBuddiesScreenState extends State<MyBuddiesScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().user;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('buddy_matches')
            .where('status', isEqualTo: 'active')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No active buddy connections yet",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Accept a buddy request to get started!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Filter for current user's connections
          final myConnections = snapshot.data!.docs
              .where((doc) =>
                  doc['user1Id'] == currentUser?.uid ||
                  doc['user2Id'] == currentUser?.uid)
              .toList();

          if (myConnections.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No active buddy connections yet",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myConnections.length,
            itemBuilder: (context, index) {
              final matchDoc = myConnections[index];
              final matchId = matchDoc.id;
              final user1Id = matchDoc['user1Id'] as String;
              final user2Id = matchDoc['user2Id'] as String;

              // Get the other user's ID
              final buddyId = user1Id == currentUser?.uid ? user2Id : user1Id;

              // Get buddy details
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(buddyId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final buddyName =
                      userSnapshot.data?['name'] as String? ?? "Unknown";
                  final buddyFaculty =
                      userSnapshot.data?['faculty'] as String? ?? "N/A";

                  return _buildBuddyCard(
                    context,
                    matchId,
                    buddyId,
                    buddyName,
                    buddyFaculty,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBuddyCard(
    BuildContext context,
    String matchId,
    String buddyId,
    String buddyName,
    String buddyFaculty,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF1D9E75),
                  child: Text(
                    buddyName[0].toUpperCase(),
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
                      Text(
                        buddyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        buddyFaculty,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Connected",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openChat(context, matchId, buddyName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D9E75),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.message),
                    label: const Text(
                      "Chat",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewProfile(context, buddyName),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1D9E75)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.person),
                    label: const Text("Profile"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, String matchId, String buddyName) {
    // TODO: Navigate to chat screen with matchId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          matchId: matchId,
          buddyName: buddyName,
        ),
      ),
    );
  }

  void _viewProfile(BuildContext context, String buddyName) {
    // TODO: Navigate to buddy profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Viewing $buddyName's profile"),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

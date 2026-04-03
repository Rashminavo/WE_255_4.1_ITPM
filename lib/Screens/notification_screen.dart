import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedFilter = "All";

  Color _getTypeColor(String type) {
    if (type == 'Alerts') return const Color(0xFFE24B4A);
    if (type == 'System') return const Color(0xFF888888);
    return const Color(0xFF1D9E75);
  }

  IconData _getTypeIcon(String type) {
    if (type == 'Alerts') return Icons.warning_amber_rounded;
    if (type == 'System') return Icons.info_outline;
    return Icons.notifications;
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return DateFormat('MMM dd, hh:mm a').format(date);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Notifications",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1D9E75),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final filter in ["All", "Alerts", "System", "Booking"])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (_) => _applyFilter(filter),
                        selectedColor: const Color(0xFF1D9E75),
                        checkmarkColor: Colors.white,
                        backgroundColor: Theme.of(context).cardColor,
                        labelStyle: TextStyle(
                          color: _selectedFilter == filter ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: user != null 
                  ? _firestoreService.getUserNotifications(user.uid)
                  : Stream.value([]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1D9E75)));
                }

                List<Map<String, dynamic>> notifications = snapshot.data ?? [];
                
                // Apply type filter
                if (_selectedFilter != "All") {
                  notifications = notifications.where((n) => n['type'] == _selectedFilter).toList();
                }

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final isNew = notif["isNew"] ?? false;
                    final type = notif["type"] ?? "System";
                    final color = _getTypeColor(type);
                    final icon = _getTypeIcon(type);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isNew ? const Color(0xFF1D9E75).withValues(alpha: 0.1) : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: isNew
                            ? Border.all(color: const Color(0xFF1D9E75).withValues(alpha: 0.3), width: 1.5)
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notif["title"] ?? "",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isNew
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                    )),
                                if (notif["body"] != null && (notif["body"] as String).isNotEmpty)
                                  const SizedBox(height: 4),
                                if (notif["body"] != null && (notif["body"] as String).isNotEmpty)
                                  Text(
                                    notif["body"]!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(_formatTimestamp(notif["createdAt"] ?? notif["timestamp"]),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          if (isNew)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1D9E75),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}

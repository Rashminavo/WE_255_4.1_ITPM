// lib/features/status/my_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../status/report_detail_screen.dart';
import '../status/status_tracker_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  String? _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  void _showTrackStatusDialog(BuildContext context) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Track Report Status'),
        content: TextField(
          controller: idController,
          decoration: InputDecoration(
            hintText: 'Enter Report ID (e.g., PH240402-128)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (value) {
            // Allow pasting and any text input
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (idController.text.isNotEmpty) {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatusTrackerScreen(
                      initialReportId: idController.text.trim(),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9E75),
            ),
            child: const Text('Track', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showTrackStatusDialog(context),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Track Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D9E75),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('userId', isEqualTo: _getCurrentUserId())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reports = snapshot.data?.docs ?? [];

          // Sort reports by timestamp locally if needed
          reports.sort((a, b) {
            final aTime = a['timestamp'];
            final bTime = b['timestamp'];
            if (aTime == null || bTime == null) return 0;

            DateTime aDate, bDate;
            try {
              aDate =
                  (aTime is Timestamp) ? aTime.toDate() : DateTime.parse(aTime);
              bDate =
                  (bTime is Timestamp) ? bTime.toDate() : DateTime.parse(bTime);
            } catch (e) {
              return 0;
            }
            return bDate.compareTo(aDate);
          });

          if (reports.isEmpty) {
            return const Center(child: Text('No reports submitted yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final data = reports[index].data() as Map<String, dynamic>;
              final reportId = data['reportId'] ?? reports[index].id;
              final category = data['category'] ?? 'Unknown';
              final mediaUrls = data['mediaUrls'] as List<dynamic>? ?? [];
              final dateTime = data['dateTime'] ?? '';
              final hasLocation = data['location'] != null;

              DateTime? parsedDate;
              try {
                parsedDate = DateTime.parse(dateTime);
              } catch (e) {
                parsedDate = null;
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReportDetailScreen(reportId: reportId),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        Text(
                          category,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        // Date & Time
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              parsedDate != null
                                  ? DateFormat('MMM d, yyyy hh:mm a')
                                      .format(parsedDate)
                                  : 'Unknown Date',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Bottom Row: Report ID, Image, Location Icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: reportId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Report ID copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Color(0xFF1D9E75),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D9E75)
                                      .withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF1D9E75),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      reportId,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                        color: Color(0xFF1D9E75),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.copy,
                                      size: 12,
                                      color: Color(0xFF1D9E75),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                if (mediaUrls.isNotEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(Icons.image,
                                        size: 16, color: Colors.blue),
                                  ),
                                if (hasLocation)
                                  const Icon(Icons.location_on,
                                      size: 16, color: Color(0xFF1D9E75)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

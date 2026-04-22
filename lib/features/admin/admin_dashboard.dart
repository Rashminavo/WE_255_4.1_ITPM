// lib/features/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../status/status_tracker_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final searchController = TextEditingController();
  String searchQuery = '';
  String? selectedSeverity;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, Color> categoryColors = {
    'Verbal Harassment': Colors.orange,
    'Physical Abuse': Colors.red,
    'Sexual Harassment': Colors.pink,
    'Cyber Bullying': Colors.purple,
    'Other': Colors.grey,
  };

  final Map<String, Color> severityColors = {
    'Low': const Color(0xFF4CAF50),
    'Medium': const Color(0xFFFFC107),
    'High': const Color(0xFFFF9800),
    'Critical': const Color(0xFFE53935),
  };

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D9E75),
        elevation: 0,
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by Report ID, Category, or Keyword...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1D9E75)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Severity Filter Cards
            const Text('Filter by Severity',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            _buildSeverityCards(),
            const SizedBox(height: 24),

            // Reports List
            const Text('Reports',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            _buildReportsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('reports').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
              height: 150, child: Center(child: CircularProgressIndicator()));
        }

        final allReports = snapshot.data!.docs;
        final severityCounts = <String, int>{
          'Low': 0,
          'Medium': 0,
          'High': 0,
          'Critical': 0,
        };

        for (var doc in allReports) {
          final data = doc.data() as Map<String, dynamic>;
          final severity = data['severity'] as String? ?? 'Low';
          if (severityCounts.containsKey(severity)) {
            severityCounts[severity] = severityCounts[severity]! + 1;
          }
        }

        final severities = severityCounts.keys.toList();

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(severities.length, (index) {
            final severity = severities[index];
            final count = severityCounts[severity] ?? 0;
            final color = severityColors[severity] ?? Colors.grey;
            final isSelected = selectedSeverity == severity;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSeverity = isSelected ? null : severity;
                });
              },
              child: Container(
                width: (MediaQuery.of(context).size.width - 64) / 2,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          severity,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: color,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count == 1 ? 'report' : 'reports',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildReportsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('reports').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          final error = snapshot.error.toString();
          if (error.contains('requires an index')) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info, size: 48, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'Creating Firestore Indexes...',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Firestore is creating required indexes.\\nPlease refresh in a few moments.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('No reports found',
                  style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        final allReports = snapshot.data!.docs;

        // Sort reports by timestamp locally
        allReports.sort((a, b) {
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

        // Filter reports based on search query and selected severity
        final filteredReports = allReports.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final reportId = data['reportId'] as String? ?? '';
          final category = data['category'] as String? ?? '';
          final description = data['description'] as String? ?? '';
          final severity = data['severity'] as String? ?? '';

          final matchesSearch = reportId.toLowerCase().contains(searchQuery) ||
              category.toLowerCase().contains(searchQuery) ||
              description.toLowerCase().contains(searchQuery);

          final matchesSeverity =
              selectedSeverity == null || severity == selectedSeverity;

          return matchesSearch && matchesSeverity;
        }).toList();

        if (filteredReports.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                selectedSeverity != null
                    ? 'No $selectedSeverity severity reports found'
                    : 'No matching reports',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: filteredReports.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final reportId = data['reportId'] as String? ?? 'Unknown';
            final category = data['category'] as String? ?? 'Unknown';
            final dateTime = data['dateTime'] as String? ?? '';
            final status = data['status'] as String? ?? 'Submitted';
            final severity = data['severity'] as String? ?? 'Low';
            final mediaUrls = data['mediaUrls'] as List<dynamic>? ?? [];
            final location = data['location'] as GeoPoint?;

            DateTime? parsedDate;
            try {
              parsedDate = DateTime.parse(dateTime);
            } catch (e) {
              parsedDate = null;
            }

            final statusColor = _getStatusColor(status);
            final severityColor = severityColors[severity] ?? Colors.grey;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatusTrackerScreen(
                        initialReportId: reportId, isAdmin: true),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report ID, Category, and Severity (top row)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reportId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF1D9E75),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: severityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: severityColor, width: 1),
                          ),
                          child: Text(
                            severity,
                            style: TextStyle(
                                color: severityColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Date & Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          parsedDate != null
                              ? DateFormat('MMM d, yyyy hh:mm a')
                                  .format(parsedDate)
                              : 'Unknown Date',
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Media and Location Icons
                    Row(
                      children: [
                        if (mediaUrls.isNotEmpty) ...[
                          const Icon(Icons.image, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${mediaUrls.length} files',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          const SizedBox(width: 12),
                        ],
                        if (location != null) ...[
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('Location shared',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Bottom Row: Status Only
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (newStatus) {
                            if (newStatus != status) {
                              _updateReportStatus(reportId, newStatus);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            'Submitted',
                            'Received',
                            'Under Review',
                            'Investigating',
                            'Resolved'
                          ]
                              .map((statusOption) => PopupMenuItem(
                                    value: statusOption,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color:
                                                _getStatusColor(statusOption),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(statusOption),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Submitted':
        return Colors.orange;
      case 'Received':
        return Colors.blue;
      case 'Under Review':
        return Colors.purple;
      case 'Investigating':
        return Colors.indigo;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateReportStatus(String reportId, String newStatus) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': newStatus,
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': newStatus,
            'timestamp': DateTime.now().toIso8601String(),
          }
        ])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Status Updated',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Changed to $newStatus',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1D9E75),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

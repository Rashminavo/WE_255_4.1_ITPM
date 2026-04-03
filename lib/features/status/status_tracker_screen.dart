// lib/features/status/status_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class StatusTrackerScreen extends StatefulWidget {
  final String? initialReportId;
  final bool isAdmin;
  const StatusTrackerScreen(
      {super.key, this.initialReportId, this.isAdmin = false});

  @override
  State<StatusTrackerScreen> createState() => _StatusTrackerScreenState();
}

class _StatusTrackerScreenState extends State<StatusTrackerScreen> {
  late String reportId;
  final commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedNewStatus;

  final List<String> statusOptions = [
    'Submitted',
    'Received',
    'Under Review',
    'Investigating',
    'Resolved'
  ];

  @override
  void initState() {
    super.initState();
    reportId = widget.initialReportId ?? '';
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment(String comment) async {
    if (comment.trim().isEmpty) return;

    try {
      final reportDoc = _firestore.collection('reports').doc(reportId);
      await reportDoc.update({
        'comments': FieldValue.arrayUnion([
          {
            'text': comment.trim(),
            'timestamp': DateTime.now().toIso8601String(),
            'sender': widget.isAdmin ? 'admin' : 'user',
          }
        ])
      });
      commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isAdmin
                        ? 'Message sent to user'
                        : 'Message sent to admin',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1D9E75),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      final reportDoc = _firestore.collection('reports').doc(reportId);
      await reportDoc.update({
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
                        'Status Updated Successfully',
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1D9E75),
      ),
      body: reportId.isEmpty
          ? const Center(child: Text('No report ID provided'))
          : StreamBuilder<DocumentSnapshot>(
              stream:
                  _firestore.collection('reports').doc(reportId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Report not found'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final category = data['category'] ?? 'Unknown';
                final description = data['description'] ?? '';
                final dateTime = data['dateTime'] ?? '';
                final severity = data['severity'] ?? 'Low';
                final status = data['status'] ?? 'Submitted';
                final mediaUrls = data['mediaUrls'] as List<dynamic>? ?? [];
                final location = data['location'] as GeoPoint?;
                final statusHistory =
                    data['statusHistory'] as List<dynamic>? ?? [];
                final comments = data['comments'] as List<dynamic>? ?? [];

                DateTime? parsedDate;
                try {
                  parsedDate = DateTime.parse(dateTime);
                } catch (e) {
                  parsedDate = null;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Report ID Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF1D9E75), width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Report ID',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            SelectableText(
                              reportId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'monospace',
                                color: Color(0xFF1D9E75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Report Details
                      _detailCard('Category', category),
                      _detailCard('Severity', severity),
                      _detailCard(
                        'Date & Time',
                        parsedDate != null
                            ? DateFormat('EEEE, MMMM d, yyyy hh:mm a')
                                .format(parsedDate)
                            : 'Unknown',
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const Text('Description',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(description,
                            style: const TextStyle(fontSize: 13, height: 1.5)),
                      ),
                      const SizedBox(height: 20),

                      // Media
                      if (mediaUrls.isNotEmpty) ...[
                        const Text('Evidence',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: mediaUrls.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  mediaUrls[index] as String,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Location
                      if (location != null) ...[
                        const Text('Location',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on,
                                  color: Color(0xFF1D9E75), size: 20),
                              const SizedBox(height: 8),
                              Text(
                                'Latitude: ${location.latitude.toStringAsFixed(6)}\nLongitude: ${location.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Timeline
                      const Text('Status Timeline',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 16),
                      _buildTimeline(statusHistory, status),
                      const SizedBox(height: 20),

                      // Status Update Section
                      _buildStatusUpdateSection(status),
                      const SizedBox(height: 20),

                      // Comments Section
                      _buildCommentsSection(comments),
                      const SizedBox(height: 20),

                      // Confidence Message (only for users, not admin)
                      if (!widget.isAdmin) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock,
                                  color: Colors.green, size: 24),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  '🔒 Your identity is protected. Your report is being handled confidentially.',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _detailCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text('$label: ',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontSize: 13, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<dynamic> statusHistory, String currentStatus) {
    final allStatuses = [
      'Submitted',
      'Received',
      'Under Review',
      'Investigating',
      'Resolved'
    ];
    final completedStatuses = statusHistory
        .map((e) => (e as Map<String, dynamic>)['status'] as String)
        .toList();

    return Column(
      children: List.generate(allStatuses.length, (index) {
        final isCompleted = completedStatuses.contains(allStatuses[index]);
        final isCurrent = allStatuses[index] == currentStatus;

        return GestureDetector(
          onTap: widget.isAdmin && !isCompleted
              ? () {
                  // Show confirmation dialog for status update
                  _showStatusUpdateDialog(allStatuses[index]);
                }
              : null,
          child: TimelineTile(
            isFirst: index == 0,
            isLast: index == allStatuses.length - 1,
            indicatorStyle: IndicatorStyle(
              width: 40,
              color: isCompleted || isCurrent
                  ? const Color(0xFF1D9E75)
                  : Colors.grey.shade300,
              iconStyle: IconStyle(
                iconData: isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: Colors.white,
              ),
            ),
            beforeLineStyle: LineStyle(
              color:
                  isCompleted ? const Color(0xFF1D9E75) : Colors.grey.shade300,
              thickness: 2,
            ),
            afterLineStyle: LineStyle(
              color: (index + 1 < allStatuses.length &&
                      completedStatuses.contains(allStatuses[index + 1]))
                  ? const Color(0xFF1D9E75)
                  : Colors.grey.shade300,
              thickness: 2,
            ),
            endChild: GestureDetector(
              onTap: widget.isAdmin && !isCompleted
                  ? () => _showStatusUpdateDialog(allStatuses[index])
                  : null,
              child: Container(
                margin: const EdgeInsets.only(left: 16, bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (widget.isAdmin && !isCompleted)
                      ? const Color(0xFF1D9E75).withValues(alpha: 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: (widget.isAdmin && !isCompleted)
                      ? Border.all(
                          color: const Color(0xFF1D9E75).withValues(alpha: 0.3),
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          allStatuses[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isCurrent
                                ? const Color(0xFF1D9E75)
                                : Colors.black,
                          ),
                        ),
                        if (widget.isAdmin && !isCompleted)
                          const Tooltip(
                            message: 'Click to update status',
                            child: Icon(
                              Icons.touch_app,
                              size: 14,
                              color: Color(0xFF1D9E75),
                            ),
                          ),
                      ],
                    ),
                    if (isCompleted && index < completedStatuses.length) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showStatusUpdateDialog(String newStatus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Status'),
        content: Text(
          'Update report status to "$newStatus"?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9E75),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateSection(String currentStatus) {
    // Status update for admin is now done through timeline - this section is hidden
    return SizedBox.shrink();
  }

  Widget _buildCommentsSection(List<dynamic> comments) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Messages',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              if (widget.isAdmin)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D9E75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Comments List
          if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No messages yet',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            )
          else
            Column(
              children: comments.map((c) {
                final commentData = c as Map<String, dynamic>;
                final text = commentData['text'] ?? '';
                final timestampValue = commentData['timestamp'];
                final sender = commentData['sender'] ?? 'user';
                final isAdminMessage = sender == 'admin';

                DateTime? parsedDateTime;
                try {
                  if (timestampValue is Timestamp) {
                    parsedDateTime = timestampValue.toDate();
                  } else if (timestampValue is String) {
                    parsedDateTime = DateTime.parse(timestampValue);
                  }
                } catch (e) {
                  debugPrint('Error parsing timestamp: $e');
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isAdminMessage
                                    ? const Color(0xFF1D9E75)
                                        .withValues(alpha: 0.1)
                                    : Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isAdminMessage ? 'Admin' : 'User',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isAdminMessage
                                      ? const Color(0xFF1D9E75)
                                      : Colors.blue,
                                ),
                              ),
                            ),
                            Text(
                              parsedDateTime != null
                                  ? DateFormat('MMM d, hh:mm a')
                                      .format(parsedDateTime)
                                  : 'Unknown time',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          text,
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 14),
          // Add Comment Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText:
                        widget.isAdmin ? 'Add message...' : 'Message admin...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _addComment(commentController.text),
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D9E75),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

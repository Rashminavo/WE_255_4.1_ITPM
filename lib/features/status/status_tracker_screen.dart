// lib/features/status/status_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StatusTrackerScreen extends StatefulWidget {
  final String? initialReportId;
  final bool isAdmin;
  const StatusTrackerScreen(
      {super.key, this.initialReportId, this.isAdmin = false});

  @override
  State<StatusTrackerScreen> createState() => _StatusTrackerScreenState();
}

class _StatusTrackerScreenState extends State<StatusTrackerScreen> {
  GoogleMapController? mapController;
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
    mapController?.dispose();
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReportHeaderCard(
                        reportId: reportId,
                        status: status,
                        severity: severity,
                      ),
                      const SizedBox(height: 20),

                      _buildReportInfoCard(
                        category: category,
                        parsedDate: parsedDate,
                      ),
                      const SizedBox(height: 20),

                      _buildDescriptionCard(description),
                      const SizedBox(height: 20),

                      if (mediaUrls.isNotEmpty)
                        _buildEvidenceCard(mediaUrls)
                      else
                        _buildNoEvidenceCard(),
                      const SizedBox(height: 20),

                      if (location != null)
                        _buildLocationCard(location)
                      else
                        _buildNoLocationCard(),
                      const SizedBox(height: 20),

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

  Widget _buildReportHeaderCard({
    required String reportId,
    required String status,
    required String severity,
  }) {
    final safeId = reportId.isEmpty
        ? '-'
        : (reportId.length <= 12 ? reportId : reportId.substring(0, 12));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D9E75), Color(0xFF159B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D9E75).withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report ID',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            '#${safeId.toUpperCase()}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(status),
              _buildSeverityChip(severity),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportInfoCard({
    required String category,
    required DateTime? parsedDate,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.category_outlined,
              label: 'Category',
              value: category,
              valueColor: const Color(0xFF1D9E75),
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Date & Time',
              value: parsedDate != null
                  ? DateFormat('MMM d, yyyy • hh:mm a').format(parsedDate)
                  : 'Unknown',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                description.isEmpty ? 'No description provided' : description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: description.isEmpty
                      ? Colors.grey.shade500
                      : Colors.black87,
                  fontStyle:
                      description.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceCard(List<dynamic> mediaUrls) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.image_outlined,
                    size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Evidence',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mediaUrls.length,
                itemBuilder: (context, index) {
                  final imageUrl = mediaUrls[index] as String;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == mediaUrls.length - 1 ? 0 : 10,
                    ),
                    child: GestureDetector(
                      onTap: () => _showImagePreview(context, imageUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 140,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.zoom_in,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoEvidenceCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 28, color: Colors.grey.shade500),
            const SizedBox(width: 12),
            Text(
              'No evidence uploaded',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(GeoPoint location) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Incident Location',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 220,
                child: kIsWeb
                    ? Container(
                        color: Colors.grey.shade100,
                        alignment: Alignment.center,
                        child: Text(
                          'Lat: ${location.latitude.toStringAsFixed(4)}\nLng: ${location.longitude.toStringAsFixed(4)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(location.latitude, location.longitude),
                          zoom: 15,
                        ),
                        onMapCreated: (controller) =>
                            mapController = controller,
                        zoomControlsEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId('status_tracker_location'),
                            position:
                                LatLng(location.latitude, location.longitude),
                          ),
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLocationCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.location_disabled_outlined,
                size: 28, color: Colors.grey.shade500),
            const SizedBox(width: 12),
            Text(
              'Location not available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green.shade700),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(String severity) {
    Color bgColor;
    Color textColor;
    IconData icon;
    switch (severity.toLowerCase()) {
      case 'critical':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        icon = Icons.dangerous_outlined;
        break;
      case 'high':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        icon = Icons.warning_amber_rounded;
        break;
      case 'medium':
        bgColor = Colors.yellow.shade100;
        textColor = Colors.yellow.shade800;
        icon = Icons.info_outline;
        break;
      default:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            severity,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child:
                      Icon(Icons.broken_image, size: 48, color: Colors.white70),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
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

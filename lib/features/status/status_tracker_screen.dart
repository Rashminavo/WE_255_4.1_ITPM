import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusTrackerScreen extends StatefulWidget {
  final String? initialReportId;

  const StatusTrackerScreen({super.key, this.initialReportId});

  @override
  State<StatusTrackerScreen> createState() => _StatusTrackerScreenState();
}

class _StatusTrackerScreenState extends State<StatusTrackerScreen> {
  final TextEditingController _reportIdController = TextEditingController();
  bool isLoading = false;
  DocumentSnapshot? reportData;

  @override
  void initState() {
    super.initState();
    // If a Report ID was passed (from "Track Status Now"), pre-fill and search
    if (widget.initialReportId != null && widget.initialReportId!.isNotEmpty) {
      _reportIdController.text = widget.initialReportId!;
      // Run after first frame so context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkStatus());
    }
  }

  Future<void> _checkStatus() async {
    final reportId = _reportIdController.text.trim();

    if (reportId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a Report ID')),
        );
      }
      return;
    }

    setState(() => isLoading = true);
    reportData = null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('reports')
          .doc(reportId)
          .get();

      if (doc.exists) {
        setState(() => reportData = doc);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report ID not found. Please check and try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return Colors.blue;
      case 'investigating':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Report Status'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Report ID',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reportIdController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., abc123xyz...',
                labelText: 'Report ID',
              ),
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _checkStatus,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Check Status',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),

            // Report Status Display
            if (reportData != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report Details',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      _buildDetailRow('Report ID', reportData!.id),
                      _buildDetailRow('Type', reportData!['type'] ?? 'N/A'),
                      _buildDetailRow(
                        'Status',
                        reportData!['status'] ?? 'Unknown',
                        color: _getStatusColor(reportData!['status'] ?? ''),
                      ),
                      _buildDetailRow(
                        'Submitted On',
                        reportData!['timestamp'] != null
                            ? (reportData!['timestamp'] as Timestamp)
                                .toDate()
                                .toString()
                                .substring(0, 16)
                            : 'N/A',
                      ),
                      if (reportData!['mediaUrl'] != null) ...[
                        const SizedBox(height: 10),
                        const Text('Evidence:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(
                          reportData!['mediaUrl'],
                          style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ] else if (!isLoading && _reportIdController.text.isNotEmpty) ...[
              const Center(
                child: Text(
                  'No report found with this ID',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reportIdController.dispose();
    super.dispose();
  }
}

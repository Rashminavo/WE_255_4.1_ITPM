import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/cloudinary_service.dart';
import '../status/status_tracker_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? selectedType;
  final descriptionController = TextEditingController();
  bool shareLocation = false;
  XFile? selectedMedia;
  bool isSubmitting = false;

  final List<String> raggingTypes = [
    'Verbal',
    'Physical',
    'Sexual',
    'Cyber',
    'Other'
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _submitReport() async {
    if (selectedType == null || descriptionController.text.trim().length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select type and write at least 20 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      String? mediaUrl;

      // Upload to Cloudinary if media selected
      if (selectedMedia != null) {
        mediaUrl = await CloudinaryService().uploadFile(selectedMedia!);
      }

      final User? user = FirebaseAuth.instance.currentUser;

      // Save report to Global 'reports' collection
      final docRef = await _firestore.collection('reports').add({
        'type': selectedType,
        'description': descriptionController.text.trim(),
        'mediaUrl': mediaUrl,
        'shareLocation': shareLocation,
        'status': 'Received',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user?.uid, // Keep track to identify who sent it if needed
      });

      // Save to Student's private "my_reports" Subcollection
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('my_reports')
            .doc(docRef.id)
            .set({
          'reportId': docRef.id,
          'type': selectedType,
          'status': 'Received',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Show Successful Report ID & Direct Navigation to Tracker
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('✅ Report Submitted!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Report ID is:'),
                const SizedBox(height: 10),
                // Copyable Report ID chip
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: docRef.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Report ID copied to clipboard!'),
                          ],
                        ),
                        backgroundColor: Color(0xFF1D9E75),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1D9E75)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            docRef.id,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF0F6E56),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.copy,
                            size: 18, color: Color(0xFF1D9E75)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tap the ID above to copy it. Use it to track your report status.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    selectedType = null;
                    descriptionController.clear();
                    shareLocation = false;
                    selectedMedia = null;
                  });
                  // Navigate and pass the reportId to auto-fill search bar
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StatusTrackerScreen(initialReportId: docRef.id),
                    ),
                  );
                },
                child: const Text('Track Status Now'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => selectedMedia = pickedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anonymous Reporting'),
        backgroundColor: const Color(0xFF1D9E75),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Ragging Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              hint: const Text('Choose type of ragging'),
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: raggingTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => selectedType = value),
            ),
            const SizedBox(height: 20),

            const Text(
              'Description of the Incident',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Please describe what happened...',
              ),
            ),
            const SizedBox(height: 20),

            // Media Upload Option
            const Text(
              'Add Evidence (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickMedia,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Add Photo / Video'),
                ),
                if (selectedMedia != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      selectedMedia!.name.length > 20
                          ? '${selectedMedia!.name.substring(0, 18)}...'
                          : selectedMedia!.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Target Location Control
            SwitchListTile(
              title: const Text('Share Current Location'),
              subtitle: const Text('This helps authorities respond faster'),
              value: shareLocation,
              onChanged: (value) => setState(() => shareLocation = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 40),

            // Submission Button Block
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D9E75),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Report Anonymously',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 60), // Space to prevent hiding behind FAB
          ],
        ),
      ),
    );
  }
}

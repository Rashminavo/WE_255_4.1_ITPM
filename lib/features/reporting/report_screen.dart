// lib/features/reporting/report_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:math';
import '../../services/cloudinary_service.dart';
import '../status/my_reports_screen.dart';
import '../admin/admin_dashboard.dart';

class ReportScreen extends StatefulWidget {
  final XFile? initialMedia;
  const ReportScreen({super.key, this.initialMedia});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form State
  String? selectedCategory;
  String selectedSeverity = 'Low';
  final descriptionController = TextEditingController();

  // DateTime State
  DateTime incidentDateTime = DateTime.now();

  // Location State
  bool shareLocation = false;
  LatLng? currentLatLng;
  GoogleMapController? mapController;

  XFile? selectedMedia;
  bool isSubmitting = false;

  final List<String> raggingTypes = [
    'Verbal Abuse',
    'Physical Abuse',
    'Sexual Harassment',
    'Cyberbullying',
    'Other'
  ];

  final List<String> severityLevels = ['Low', 'Medium', 'High', 'Critical'];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Pre-fill media if passed from SOS actions
    if (widget.initialMedia != null) {
      selectedMedia = widget.initialMedia;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          currentLatLng = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    descriptionController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  String _getCategoryPrefix(String category) {
    switch (category) {
      case 'Verbal Abuse':
        return 'VE';
      case 'Physical Abuse':
        return 'PH';
      case 'Sexual Harassment':
        return 'SH';
      case 'Cyberbullying':
        return 'CY';
      case 'Other':
        return 'OT';
      default:
        return 'OT';
    }
  }

  String _generateReportId(String category) {
    final prefix = _getCategoryPrefix(category);
    final now = DateTime.now();
    final yy = DateFormat('yy').format(now); // 24 for 2024, 26 for 2026
    final mmdd = DateFormat('MMdd').format(now); // 0402 for April 2
    final randomSuffix = (Random().nextInt(900) + 100).toString(); // 3 digits
    return '$prefix$yy$mmdd-$randomSuffix';
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: incidentDateTime,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(incidentDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          incidentDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String _formatDateTimeForDisplay(DateTime dateTime) {
    return DateFormat('d MMMM yyyy, hh:mm a').format(dateTime);
  }

  Future<void> _submitReport() async {
    if (selectedCategory == null) {
      _showSnackBar('Please select a category.', Colors.red);
      return;
    }
    if (descriptionController.text.trim().length < 10) {
      _showSnackBar(
          'Provide at least 10 characters in description.', Colors.red);
      return;
    }

    setState(() => isSubmitting = true);

    try {
      List<String> mediaUrls = [];
      if (selectedMedia != null) {
        final url = await CloudinaryService().uploadFile(selectedMedia!);
        if (url != null) {
          mediaUrls.add(url);
        }
      }

      final String reportId = _generateReportId(selectedCategory!);

      final reportData = {
        'reportId': reportId,
        'category': selectedCategory,
        'description': descriptionController.text.trim(),
        'severity': selectedSeverity,
        'dateTime': incidentDateTime.toIso8601String(),
        'mediaUrls': mediaUrls,
        'location': (shareLocation && currentLatLng != null)
            ? GeoPoint(currentLatLng!.latitude, currentLatLng!.longitude)
            : null,
        'status': 'Submitted',
        'statusHistory': [
          {
            'status': 'Submitted',
            'timestamp': DateTime.now().toIso8601String(),
          }
        ],
        'comments': [],
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('reports').doc(reportId).set(reportData);

      if (mounted) {
        _showSuccessDialog(reportId);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error submitting report: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showSuccessDialog(String reportId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('✅ Report Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your Report ID:'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1D9E75)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      reportId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1D9E75),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy,
                        size: 20, color: Color(0xFF1D9E75)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: reportId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report ID copied!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please save this ID to track your report.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                selectedCategory = null;
                descriptionController.clear();
                selectedMedia = null;
                shareLocation = false;
                incidentDateTime = DateTime.now();
              });
            },
            child: const Text('Submit Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                selectedCategory = null;
                descriptionController.clear();
                selectedMedia = null;
                shareLocation = false;
                incidentDateTime = DateTime.now();
              });
              _tabController.animateTo(1);
            },
            child: const Text('View My Reports'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporting Center',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1D9E75),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "New", icon: Icon(Icons.add_alert)),
            Tab(text: "My Reports", icon: Icon(Icons.history)),
            Tab(text: "Admin", icon: Icon(Icons.admin_panel_settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportForm(),
          const MyReportsScreen(),
          _buildAdminView(),
        ],
      ),
    );
  }

  Widget _buildReportForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Time Picker - at the top
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              leading:
                  const Icon(Icons.calendar_today, color: Color(0xFF1D9E75)),
              title: const Text('Incident Date & Time'),
              subtitle: Text(_formatDateTimeForDisplay(incidentDateTime)),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: _pickDateTime,
            ),
          ),
          const SizedBox(height: 20),

          _sectionTitle('Category'),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            decoration: _inputDecoration('Select a category'),
            items: raggingTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => selectedCategory = v),
          ),
          const SizedBox(height: 20),

          _sectionTitle('Severity Level'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: severityLevels.map((lvl) {
              final isSelected = selectedSeverity == lvl;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      lvl,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: _getSeverityColor(lvl),
                    onSelected: (selected) {
                      if (selected) setState(() => selectedSeverity = lvl);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          _sectionTitle('Description'),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: _inputDecoration(
              'Describe the incident safely and anonymously...',
            ),
          ),
          const SizedBox(height: 20),

          _sectionTitle('Evidence'),
          InkWell(
            onTap: () async {
              final picker = ImagePicker();
              final file = await picker.pickImage(source: ImageSource.gallery);
              if (file != null) setState(() => selectedMedia = file);
            },
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: selectedMedia != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        selectedMedia!.path,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.file_present),
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, color: Colors.grey),
                        Text('Upload Evidence',
                            style: TextStyle(color: Colors.grey))
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),

          _sectionTitle('Share Location'),
          SwitchListTile(
            title: const Text('Share Your Location'),
            subtitle: const Text('Increases emergency response speed'),
            value: shareLocation,
            activeThumbColor: const Color(0xFF1D9E75),
            onChanged: (v) {
              setState(() => shareLocation = v);
              if (v) {
                _getCurrentLocation();
              }
            },
          ),

          if (shareLocation && currentLatLng != null) ...[
            const SizedBox(height: 12),
            if (!kIsWeb)
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                clipBehavior: Clip.antiAlias,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentLatLng!,
                    zoom: 15,
                  ),
                  onMapCreated: (c) => mapController = c,
                  markers: {
                    Marker(
                      markerId: const MarkerId('current'),
                      position: currentLatLng!,
                      infoWindow: const InfoWindow(title: 'Your Location'),
                    )
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              )
            else
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade100,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          size: 40, color: Color(0xFF1D9E75)),
                      const SizedBox(height: 10),
                      const Text(
                        'Location Enabled',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Lat: ${currentLatLng!.latitude.toStringAsFixed(4)}\nLng: ${currentLatLng!.longitude.toStringAsFixed(4)}',
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D9E75),
                foregroundColor: Colors.white,
              ),
              onPressed: isSubmitting ? null : _submitReport,
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'SUBMIT REPORT',
                      style: TextStyle(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  Color _getSeverityColor(String lvl) {
    switch (lvl) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Critical':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAdminView() {
    return const AdminDashboard();
  }
}

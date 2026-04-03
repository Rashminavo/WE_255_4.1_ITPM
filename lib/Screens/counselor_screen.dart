import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/booking_service.dart';
import '../providers/user_provider.dart';

// Booking model
class BookingModel {
  final String id;
  final String studentName;
  final String counselorName;
  final String date;
  final String time;
  final String reason;
  final String status;
  final DateTime bookingDate;

  BookingModel({
    required this.id,
    required this.studentName,
    required this.counselorName,
    required this.date,
    required this.time,
    required this.reason,
    this.status = 'Pending',
    required this.bookingDate,
  });
}

class BookingStorage {
  static List<BookingModel> bookings = [];

  // Add sample bookings for testing
  static void addSampleBookings() {
    if (bookings.isEmpty) {
      bookings.add(BookingModel(
        id: '1',
        studentName: 'Current User',
        counselorName: 'Dr. Priya Mendis',
        date: DateFormat('yyyy-MM-dd')
            .format(DateTime.now().add(const Duration(days: 2))),
        time: '10:00 AM',
        reason: 'Anxiety / Stress',
        status: 'Confirmed',
        bookingDate: DateTime.now().subtract(const Duration(days: 1)),
      ));
      bookings.add(BookingModel(
        id: '2',
        studentName: 'Current User',
        counselorName: 'Mr. Kasun Fernando',
        date: DateFormat('yyyy-MM-dd')
            .format(DateTime.now().add(const Duration(days: 5))),
        time: '02:00 PM',
        reason: 'Academic Pressure',
        status: 'Pending',
        bookingDate: DateTime.now(),
      ));
      bookings.add(BookingModel(
        id: '3',
        studentName: 'Current User',
        counselorName: 'Dr. Roshan Silva',
        date: DateFormat('yyyy-MM-dd')
            .format(DateTime.now().add(const Duration(days: 1))),
        time: '11:00 AM',
        reason: 'Mental Health Support',
        status: 'Confirmed',
        bookingDate: DateTime.now(),
      ));
    }
  }
}

class CounselorScreen extends StatefulWidget {
  const CounselorScreen({super.key});

  @override
  State<CounselorScreen> createState() => _CounselorScreenState();
}

class _CounselorScreenState extends State<CounselorScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late List<AnimationController> _cardControllers;

  bool _isAnonymousMode = false;

  final List<Map<String, dynamic>> _counselors = const [
    {
      "name": "Dr. Priya Mendis",
      "role": "Senior Counselor",
      "available": true,
      "specialty": "Ragging & Harassment",
      "rating": 4.9,
      "sessions": 1247,
      "email": "priya.mendis@university.lk",
      "experience": "12 years",
      "languages": ["English", "Sinhala"],
    },
    {
      "name": "Mr. Kasun Fernando",
      "role": "Student Welfare Officer",
      "available": true,
      "specialty": "Mental Health Support",
      "rating": 4.8,
      "sessions": 892,
      "email": "kasun.fernando@university.lk",
      "experience": "8 years",
      "languages": ["English", "Sinhala", "Tamil"],
    },
    {
      "name": "Ms. Dilini Perera",
      "role": "Peer Support Counselor",
      "available": false,
      "specialty": "Anxiety & Stress",
      "rating": 4.7,
      "sessions": 654,
      "email": "dilini.perera@university.lk",
      "experience": "5 years",
      "languages": ["English", "Sinhala"],
    },
    {
      "name": "Dr. Roshan Silva",
      "role": "Psychologist",
      "available": false,
      "specialty": "Trauma Counseling",
      "rating": 4.9,
      "sessions": 1523,
      "email": "roshan.silva@university.lk",
      "experience": "15 years",
      "languages": ["English", "Sinhala", "Tamil"],
    },
  ];

  final List<String> _timeSlots = [
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM"
  ];

  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  String? _selectedReason;

  final List<String> _reasons = [
    "Ragging / Harassment",
    "Anxiety / Stress",
    "Academic Pressure",
    "Relationship Issues",
    "Mental Health Support",
    "General Counseling",
  ];

  @override
  void initState() {
    super.initState();

    _loadAnonymousMode();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _cardControllers = List.generate(
      _counselors.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _slideController.forward();
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  Future<void> _loadAnonymousMode() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            _isAnonymousMode = doc.data()!['anonymousMode'] ?? false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading anonymous mode: $e');
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.isNotEmpty ? name[0] : '?';
  }

  void _showBookingDialog(Map<String, dynamic> counselor) {
    _selectedTimeSlot = null;
    _selectedReason = null;
    _selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Counselor Info
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFE8F8F2),
                                    const Color(0xFF1D9E75)
                                        .withValues(alpha: 0.3),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(counselor["name"]),
                                  style: const TextStyle(
                                    color: Color(0xFF1D9E75),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    counselor["name"],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    counselor["role"],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: counselor["available"]
                                          ? const Color(0xFFE8F8F2)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      counselor["available"]
                                          ? "Available"
                                          : "Currently Unavailable",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: counselor["available"]
                                            ? const Color(0xFF1D9E75)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Booking Form
                        const Text(
                          "Book a Session",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Date Selection
                        const Text(
                          "Select Date",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Color(0xFF1D9E75), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextButton(
                                  onPressed: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 30)),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                              primary: Color(0xFF1D9E75),
                                              onPrimary: Colors.white,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      setStateModal(() {
                                        _selectedDate = picked;
                                      });
                                    }
                                  },
                                  child: Text(
                                    DateFormat('EEEE, MMMM d, yyyy')
                                        .format(_selectedDate),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Time Slot Selection
                        const Text(
                          "Select Time Slot",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _timeSlots.map((slot) {
                            bool isSelected = _selectedTimeSlot == slot;
                            return GestureDetector(
                              onTap: () {
                                setStateModal(() {
                                  _selectedTimeSlot = slot;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1D9E75)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1D9E75)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  slot,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Reason Selection
                        const Text(
                          "Reason for Counseling",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedReason,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          hint: const Text("Select a reason"),
                          items: _reasons.map((reason) {
                            return DropdownMenuItem(
                              value: reason,
                              child: Text(reason),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateModal(() {
                              _selectedReason = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Anonymous Mode Info Banner
                        if (_isAnonymousMode)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFFF9800)
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: Color(0xFFFF9800), size: 14),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFE65100)),
                                      children: [
                                        TextSpan(text: 'Booking anonymously '),
                                        TextSpan(
                                          text: '(change in Profile Settings)',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_isAnonymousMode) const SizedBox(height: 16),

                        // Book Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D9E75),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: (_selectedTimeSlot != null &&
                                    _selectedReason != null)
                                ? () {
                                    Navigator.pop(context);
                                    _confirmBooking(counselor);
                                  }
                                : null,
                            child: const Text(
                              "Confirm Booking",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Note
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Color(0xFF1D9E75), size: 14),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Your booking will be confirmed within 24 hours. You'll receive a notification once confirmed.",
                                  style: TextStyle(
                                      fontSize: 11, color: Color(0xFF0F6E56)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmBooking(Map<String, dynamic> counselor) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Determine student name based on anonymous mode
    String bookingName;
    if (_isAnonymousMode) {
      // Generate anonymous username with random number
      final randomNum = (DateTime.now().millisecondsSinceEpoch % 10000)
          .toString()
          .padLeft(4, '0');
      bookingName = "Anonymous User #$randomNum";
    } else {
      bookingName = userProvider.fullName;
    }

    // Create new booking
    await BookingService().createBooking(
      studentId: userProvider.studentId,
      studentName: bookingName,
      counselorName: counselor["name"],
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      time: _selectedTimeSlot!,
      reason: _selectedReason!,
    );

    if (!mounted) return;

    // Show loading animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.1),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF1D9E75),
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Booking Confirmed!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D9E75),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your session with ${counselor["name"]}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate)} at $_selectedTimeSlot",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D9E75),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: _pulseController.value,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF1D9E75)),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 3,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        _showBookingSuccessDialog(counselor);
      }
    });
  }

  void _showBookingSuccessDialog(Map<String, dynamic> counselor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
            const SizedBox(width: 8),
            const Text("Booking Successful"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Your counseling session has been booked with ${counselor["name"]}."),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Color(0xFF1D9E75)),
                      const SizedBox(width: 6),
                      Text(
                        "Date: ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate)}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Color(0xFF1D9E75)),
                      const SizedBox(width: 6),
                      Text("Time: $_selectedTimeSlot",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: Color(0xFF1D9E75)),
                      const SizedBox(width: 6),
                      Text("Reason: $_selectedReason",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "You'll receive a confirmation email with meeting details. A counselor will contact you shortly.",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK",
                style: TextStyle(fontSize: 13, color: Color(0xFF1D9E75))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showBookingsList();
            },
            child: const Text("View My Bookings",
                style: TextStyle(fontSize: 13, color: Color(0xFF1D9E75))),
          ),
        ],
      ),
    );
  }

  void _showBookingsList() {
    if (BookingStorage.bookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No bookings found. Book your first session!'),
          backgroundColor: Color(0xFF1D9E75),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "My Bookings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: BookingStorage.bookings.length,
                  itemBuilder: (context, index) {
                    final booking =
                        BookingStorage.bookings.reversed.toList()[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D9E75)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.psychology,
                                    color: Color(0xFF1D9E75), size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.counselorName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      booking.reason,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: booking.status == "Pending"
                                      ? const Color(0xFFFFF3E0)
                                      : const Color(0xFFE8F8F2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  booking.status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: booking.status == "Pending"
                                        ? const Color(0xFFFF9800)
                                        : const Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd, yyyy')
                                    .format(DateTime.parse(booking.date)),
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time,
                                  size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                booking.time,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Booked on: ${DateFormat('MMM dd, yyyy').format(booking.bookingDate)}",
                            style:
                                TextStyle(fontSize: 9, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Counselor Support",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        backgroundColor: const Color(0xFF1D9E75),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white, size: 22),
            onPressed: _showBookingsList,
            tooltip: "My Bookings",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE8F8F2),
                    const Color(0xFFD4F0E6),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF1D9E75).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D9E75).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security,
                        color: Color(0xFF0F6E56), size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Your identity is kept anonymous. Professional counselors are here to support you.",
                      style: TextStyle(
                          color: Color(0xFF085041), fontSize: 11, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Row
            Row(
              children: [
                _buildStatCard(
                  icon: Icons.people,
                  value: "${BookingStorage.bookings.length}",
                  label: "Total",
                  color: const Color(0xFF1D9E75),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  icon: Icons.schedule,
                  value: _getUpcomingBookings(),
                  label: "Upcoming",
                  color: const Color(0xFF2196F3),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  icon: Icons.check_circle,
                  value: _getCompletedBookings(),
                  label: "Confirmed",
                  color: const Color(0xFF4CAF50),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text("Available Counselors",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            ..._counselors.asMap().entries.map(
                (entry) => _counselorCard(context, entry.value, entry.key)),
            const SizedBox(height: 20),

            // Emergency Contact
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFCEBEB),
                    const Color(0xFFF8D7D7),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFE24B4A).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE24B4A).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone,
                            color: Color(0xFFE24B4A), size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Text("Emergency Hotline",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE24B4A),
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.phone_in_talk,
                                color: Color(0xFF1D9E75), size: 14),
                            const SizedBox(width: 8),
                            const Text("UGC Ragging Hotline: 1959",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.local_phone,
                                color: Color(0xFF1D9E75), size: 14),
                            const SizedBox(width: 8),
                            const Text("University Security: 011-2345678",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black87)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE24B4A),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Calling emergency hotline...'),
                            backgroundColor: Color(0xFFE24B4A),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon:
                          const Icon(Icons.call, color: Colors.white, size: 16),
                      label: const Text("Call Now",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUpcomingBookings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = BookingStorage.bookings.where((booking) {
      try {
        final bookingDate = DateTime.parse(booking.date);
        return bookingDate.isAfter(today) ||
            bookingDate.isAtSameMomentAs(today);
      } catch (e) {
        return false;
      }
    }).length;
    return upcoming.toString();
  }

  String _getCompletedBookings() {
    final completed = BookingStorage.bookings
        .where((booking) =>
            booking.status == "Confirmed" || booking.status == "Completed")
        .length;
    return completed.toString();
  }

  Widget _counselorCard(
      BuildContext context, Map<String, dynamic> counselor, int index) {
    return AnimatedBuilder(
      animation: _cardControllers[index],
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.5, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _cardControllers[index],
          curve: Curves.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _cardControllers[index],
          curve: Curves.easeOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showCounselorDetails(counselor);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Avatar
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFE8F8F2),
                                      const Color(0xFF1D9E75)
                                          .withValues(alpha: 0.3),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: counselor["available"]
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF1D9E75)
                                                .withValues(
                                                    alpha: 0.2 +
                                                        (_pulseController
                                                                .value *
                                                            0.3)),
                                            blurRadius: 8 +
                                                (_pulseController.value * 6),
                                            spreadRadius: 1 +
                                                (_pulseController.value * 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  _getInitials(counselor["name"]),
                                  style: const TextStyle(
                                    color: Color(0xFF1D9E75),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        counselor["name"],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (counselor["rating"] != null) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.star,
                                        color: Color(0xFFFFD700),
                                        size: 12,
                                      ),
                                      Text(
                                        " ${counselor["rating"]}",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF856404),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  counselor["role"],
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F8F2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        counselor["specialty"],
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF1D9E75),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (counselor["sessions"] != null)
                                      Text(
                                        "${counselor["sessions"]} sessions",
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: counselor["available"]
                                      ? const Color(0xFFE8F8F2)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: counselor["available"]
                                            ? const Color(0xFF4CAF50)
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                        boxShadow: counselor["available"]
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF4CAF50)
                                                      .withValues(alpha: 0.5),
                                                  blurRadius: 3,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      counselor["available"]
                                          ? "Online"
                                          : "Offline",
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: counselor["available"]
                                            ? const Color(0xFF1D9E75)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (counselor["available"])
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1D9E75),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: const Size(0, 0),
                                  ),
                                  onPressed: () {
                                    _showBookingDialog(counselor);
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        "Book",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${counselor["name"]} is currently offline. Please check back later.'),
                                        backgroundColor: Colors.grey,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(0, 0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                  ),
                                  child: const Text(
                                    "Notify Me",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCounselorDetails(Map<String, dynamic> counselor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFE8F8F2),
                            const Color(0xFF1D9E75).withValues(alpha: 0.3),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(counselor["name"]),
                          style: const TextStyle(
                            color: Color(0xFF1D9E75),
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      counselor["name"],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      counselor["role"],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (counselor["rating"] != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < (counselor["rating"] as double).floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFFFD700),
                              size: 20,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            "${counselor["rating"]} / 5.0",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.psychology, "Specialty",
                              counselor["specialty"]),
                          const Divider(height: 20),
                          _buildDetailRow(Icons.people, "Sessions Completed",
                              "${counselor["sessions"] ?? 0}+"),
                          const Divider(height: 20),
                          _buildDetailRow(Icons.email, "Email",
                              counselor["email"] ?? "N/A"),
                          const Divider(height: 20),
                          _buildDetailRow(Icons.work, "Experience",
                              counselor["experience"] ?? "N/A"),
                          const Divider(height: 20),
                          _buildDetailRow(Icons.language, "Languages",
                              (counselor["languages"] as List).join(", ")),
                          const Divider(height: 20),
                          _buildDetailRow(
                            Icons.access_time,
                            "Availability",
                            counselor["available"]
                                ? "Available Now"
                                : "Currently Offline",
                            valueColor: counselor["available"]
                                ? const Color(0xFF4CAF50)
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D9E75),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: counselor["available"]
                            ? () {
                                Navigator.pop(context);
                                _showBookingDialog(counselor);
                              }
                            : null,
                        child: Text(
                          counselor["available"]
                              ? "Book a Session"
                              : "Currently Unavailable",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1D9E75), size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

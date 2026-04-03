import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

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

  final List<Map<String, dynamic>> _counselors = const [
    {
      "name": "Dr. Priya Mendis",
      "role": "Senior Counselor",
      "available": true,
      "specialty": "Ragging & Harassment",
      "rating": 4.9,
      "sessions": 1247,
    },
    {
      "name": "Mr. Kasun Fernando",
      "role": "Student Welfare Officer",
      "available": true,
      "specialty": "Mental Health Support",
      "rating": 4.8,
      "sessions": 892,
    },
    {
      "name": "Ms. Dilini Perera",
      "role": "Peer Support Counselor",
      "available": false,
      "specialty": "Anxiety & Stress",
      "rating": 4.7,
      "sessions": 654,
    },
    {
      "name": "Dr. Roshan Silva",
      "role": "Psychologist",
      "available": false,
      "specialty": "Trauma Counseling",
      "rating": 4.9,
      "sessions": 1523,
    },
  ];

  @override
  void initState() {
    super.initState();
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

    // Staggered animation for cards
    _slideController.forward();
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _cardControllers[i].forward();
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text("Counselor Support",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1D9E75),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Banner - Enhanced
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE8F8F2),
                    const Color(0xFFD4F0E6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: const Color(0xFF1D9E75).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D9E75).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock,
                        color: Color(0xFF0F6E56), size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Your identity is kept anonymous. Feel free to reach out for support.",
                      style: TextStyle(
                          color: Color(0xFF085041), fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text("Available Counselors",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 14),

            ..._counselors.asMap().entries.map(
                (entry) => _counselorCard(context, entry.value, entry.key)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showCounselorDetails(counselor);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Animated Avatar
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.all(14),
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
                                  boxShadow: counselor["available"]
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF1D9E75)
                                                .withValues(
                                              alpha: 0.2 +
                                                  (_pulseController.value *
                                                      0.3),
                                            ),
                                            blurRadius: 10 +
                                                (_pulseController.value * 10),
                                            spreadRadius: 1 +
                                                (_pulseController.value * 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  _getInitials(counselor["name"]),
                                  style: const TextStyle(
                                    color: Color(0xFF1D9E75),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name and Rating row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        counselor["name"],
                                        style: const TextStyle(
                                          fontSize: 14,
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
                                        size: 14,
                                      ),
                                      Text(
                                        " ${counselor["rating"]}",
                                        style: const TextStyle(
                                          fontSize: 12,
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
                                      fontSize: 11, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                // Specialty and Sessions
                                Wrap(
                                  spacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F8F2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        counselor["specialty"],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF1D9E75),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (counselor["sessions"] != null)
                                      Text(
                                        "${counselor["sessions"]} sessions",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status and Action Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: counselor["available"]
                                      ? const Color(0xFFE8F8F2)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      width: 8,
                                      height: 8,
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
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      counselor["available"]
                                          ? "Online"
                                          : "Offline",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: counselor["available"]
                                            ? const Color(0xFF1D9E75)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (counselor["available"])
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF1D9E75),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation:
                                            2 + (_pulseController.value * 2),
                                      ),
                                      onPressed: () {
                                        _showChatAnimation(counselor);
                                      },
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.chat_bubble_outline,
                                              color: Colors.white, size: 16),
                                          SizedBox(width: 6),
                                          Text(
                                            "Chat",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              else
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${counselor["name"]} is currently offline. Try again later.'),
                                        backgroundColor: Colors.grey,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Notify Me",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
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
                            fontSize: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      counselor["name"],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      counselor["role"],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                              size: 24,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            "${counselor["rating"]} / 5.0",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.psychology, "Specialty",
                              counselor["specialty"]),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.people, "Sessions Completed",
                              "${counselor["sessions"] ?? 0}+"),
                          const Divider(height: 24),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D9E75),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: counselor["available"]
                            ? () {
                                Navigator.pop(context);
                                _showChatAnimation(counselor);
                              }
                            : null,
                        child: Text(
                          counselor["available"]
                              ? "Start Chat"
                              : "Currently Unavailable",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1D9E75), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
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

  void _showChatAnimation(Map<String, dynamic> counselor) {
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
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
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
                            Icons.chat_bubble,
                            color: Color(0xFF1D9E75),
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Connecting...",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Starting chat with ${counselor["name"]}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    value: _pulseController.value,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF1D9E75)),
                    borderRadius: BorderRadius.circular(4),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${counselor["name"]}!'),
            backgroundColor: const Color(0xFF1D9E75),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
}

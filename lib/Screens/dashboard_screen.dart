import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_provider.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'map_screen.dart';
import '../features/sos/sos_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _unreadCount = 3;
  String _greeting = '';
  bool _isCheckedIn = false;
  String _lastCheckInLocation = "";
  String _lastCheckInTime = "";
  late AnimationController _pulseController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good morning';
    } else if (hour < 17) {
      _greeting = 'Good afternoon';
    } else {
      _greeting = 'Good evening';
    }
  }

  void _handleCheckIn() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isCheckedIn = !_isCheckedIn;
      if (_isCheckedIn) {
        _lastCheckInLocation = "University Library";
        _lastCheckInTime = _getCurrentTime();
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _isCheckedIn ? Icons.check_circle : Icons.logout,
              color: const Color(0xFF1D9E75),
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(_isCheckedIn ? "Checked In!" : "Checked Out"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_isCheckedIn
                ? "You have successfully checked in at:"
                : "You have checked out from:"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFF1D9E75), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _lastCheckInLocation,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Color(0xFF1D9E75), size: 18),
                      const SizedBox(width: 8),
                      Text(_lastCheckInTime),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_isCheckedIn)
              const Text(
                "Your location is now visible to your buddies. Stay safe!",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Color(0xFF1D9E75))),
          ),
        ],
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  Future<String> _getCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Student';
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();

      final name = (data?['name'] as String?)?.trim();
      if (name != null && name.isNotEmpty) {
        return name;
      }

      final displayName = user.displayName?.trim();
      if (displayName != null && displayName.isNotEmpty) {
        return displayName;
      }
    } catch (_) {
      // Fall back to auth profile below.
    }

    return user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : 'Student';
  }

  void _handleSOS() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS feature - under development'),
        backgroundColor: Color(0xFFE24B4A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleReport() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report feature - under development'),
        backgroundColor: Color(0xFFFF9800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
  }

  // Helper method to get image provider based on platform
  ImageProvider? _getImageProvider(UserProvider userProvider) {
    if (kIsWeb) {
      if (userProvider.webImageBytes != null) {
        return MemoryImage(userProvider.webImageBytes!);
      }
    } else {
      if (userProvider.mobileImageFile != null) {
        return FileImage(userProvider.mobileImageFile!);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1A332D) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D9E75),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("RagSafe SL",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          IconButton(
            icon: Badge(
              label: Text("$_unreadCount"),
              child: const Icon(Icons.notifications_none, color: Colors.white),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationScreen()),
              );
              setState(() => _unreadCount = 0);
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined,
                color: Colors.white, size: 30),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfileScreen())),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Header with Glassmorphism - FIXED
            Container(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1D9E75),
                    const Color(0xFF0F6E56),
                    const Color(0xFF085041),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D9E75).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Row - FIXED
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: _getImageProvider(userProvider) != null
                            ? CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white24,
                                backgroundImage:
                                    _getImageProvider(userProvider),
                              )
                            : const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.person,
                                    color: Colors.white, size: 24),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_greeting,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11)),
                            FutureBuilder<String>(
                              future: _getCurrentUserName(),
                              builder: (context, snapshot) {
                                final displayName =
                                    snapshot.data ?? userProvider.fullName;
                                return Text(
                                  displayName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Safety Status and Check-in Row - FIXED
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Safety Status Card - FIXED OVERFLOW
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.shield,
                                    color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("Safety Status",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text("You're Safe",
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified,
                                            color: Colors.white70, size: 12),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withValues(alpha: 0.9)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: Color(0xFF1D9E75), size: 12),
                                    const SizedBox(width: 2),
                                    Text("${userProvider.safetyScore}",
                                        style: const TextStyle(
                                            color: Color(0xFF1D9E75),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Check-in Button
                      GestureDetector(
                        onTap: _handleCheckIn,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 70,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _isCheckedIn
                                      ? [
                                          const Color(0xFF4CAF50),
                                          const Color(0xFF2E7D32)
                                        ]
                                      : [
                                          Colors.white,
                                          Colors.white.withValues(alpha: 0.95)
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isCheckedIn
                                            ? const Color(0xFF4CAF50)
                                            : Colors.white)
                                        .withValues(
                                            alpha: 0.4 +
                                                (_pulseController.value * 0.3)),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isCheckedIn
                                        ? Icons.fingerprint
                                        : Icons.touch_app,
                                    color: _isCheckedIn
                                        ? Colors.white
                                        : const Color(0xFF1D9E75),
                                    size: 22,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isCheckedIn ? "IN" : "CHECK",
                                    style: TextStyle(
                                      color: _isCheckedIn
                                          ? Colors.white
                                          : const Color(0xFF1D9E75),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Last check-in info
                  if (_isCheckedIn) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "Checked in at $_lastCheckInLocation â€¢ $_lastCheckInTime",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions - FIXED
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Quick actions",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flash_on,
                                color: Color(0xFF1D9E75), size: 12),
                            SizedBox(width: 4),
                            Text("Fast Access",
                                style: TextStyle(
                                    color: Color(0xFF1D9E75),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCircularQuickAction(
                          Icons.warning_amber_rounded,
                          "SOS",
                          const Color(0xFFFCEBEB),
                          const Color(0xFFE24B4A),
                          _handleSOS,
                          isEmergency: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCircularQuickAction(
                          Icons.report_outlined,
                          "Report",
                          const Color(0xFFFFF3E0),
                          const Color(0xFFFF9800),
                          _handleReport,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCircularQuickAction(
                          Icons.map_outlined,
                          "Map",
                          const Color(0xFFE8F5E9),
                          const Color(0xFF4CAF50),
                          _openMap,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Recent Alerts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Recent alerts",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text("See all",
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF1D9E75))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildAlertItem("Campus alert: Stay alert near Block D",
                            "Just now", true, textColor),
                        Divider(
                            height: 1,
                            color:
                                isDark ? Colors.white12 : Colors.grey.shade200),
                        _buildAlertItem("Buddy Kavindu accepted your request",
                            "1 hr ago", false, textColor),
                        Divider(
                            height: 1,
                            color:
                                isDark ? Colors.white12 : Colors.grey.shade200),
                        _buildAlertItem("New ragging awareness tip available",
                            "3 hr ago", false, textColor),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Safety Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Your Safety Stats",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor)),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.trending_up, size: 14),
                        label: const Text("View All",
                            style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1D9E75),
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernStatCard(
                          icon: Icons.shield,
                          value: "15",
                          label: "Safe Days",
                          color: const Color(0xFF1D9E75),
                          progress: 0.75,
                          cardColor: cardColor,
                          textColor: textColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildModernStatCard(
                          icon: Icons.people,
                          value: "8",
                          label: "Buddies",
                          color: const Color(0xFF2196F3),
                          progress: 0.6,
                          cardColor: cardColor,
                          textColor: textColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildModernStatCard(
                          icon: Icons.star,
                          value: "82",
                          label: "Points",
                          color: const Color(0xFFFF9800),
                          progress: 0.82,
                          cardColor: cardColor,
                          textColor: textColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Daily Tip
                  Container(
                    padding: const EdgeInsets.all(14),
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
                          color:
                              const Color(0xFF1D9E75).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF1D9E75).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lightbulb_outline,
                              color: Color(0xFF0F6E56), size: 16),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Daily Tip: Report any suspicious activity immediately using the Report button. You are not alone.",
                            style: TextStyle(
                                color: Color(0xFF085041),
                                fontSize: 12,
                                height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SosScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xFFE24B4A),
          tooltip: 'Emergency SOS',
          elevation: 8,
          child: const Icon(Icons.sos, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCircularQuickAction(IconData icon, String label, Color bgColor,
      Color iconColor, VoidCallback onTap,
      {bool isEmergency = false}) {
    final theme = Theme.of(context);
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black87;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor,
                  bgColor.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isEmergency ? iconColor : textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required double progress,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: textColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
      String title, String time, bool isNew, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isNew ? const Color(0xFF1D9E75) : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: textColor)),
                const SizedBox(height: 2),
                Text(time, style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          if (isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text("NEW",
                  style: TextStyle(
                      color: Color(0xFF1D9E75),
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

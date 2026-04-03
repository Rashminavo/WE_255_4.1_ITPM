import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/booking_service.dart';
import 'counselor_screen.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final BookingService _bookingService = BookingService();

  String _searchQuery = '';
  bool _isLoading = true;
  int _selectedTab = 0; // 0: Bookings, 1: Analytics, 2: Counselors
  String _selectedStatusFilter = 'All';

  final List<String> _tabs = ['Bookings', 'Analytics', 'Counselors'];
  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled'
  ];

  // Mock counselors data
  final List<Map<String, dynamic>> _counselors = const [
    {
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Clinical Psychology',
      'experience': '12 years',
      'rating': 4.9,
      'sessions': 1247,
      'available': true,
      'image': 'SJ',
    },
    {
      'name': 'Dr. Priya Mendis',
      'specialty': 'Ragging & Harassment',
      'experience': '8 years',
      'rating': 4.8,
      'sessions': 892,
      'available': true,
      'image': 'PM',
    },
    {
      'name': 'Ms. Emily Chen',
      'specialty': 'Student Counseling',
      'experience': '6 years',
      'rating': 4.7,
      'sessions': 654,
      'available': false,
      'image': 'EC',
    },
    {
      'name': 'Dr. Michael Smith',
      'specialty': 'Trauma Therapy',
      'experience': '15 years',
      'rating': 4.9,
      'sessions': 1523,
      'available': true,
      'image': 'MS',
    },
  ];

  // Get bookings from storage
  List<Map<String, dynamic>> get _bookings {
    if (BookingStorage.bookings.isEmpty) {
      BookingStorage.bookings = [
        BookingModel(
          id: 'BK001',
          studentName: 'Sachini Bandara',
          counselorName: 'Dr. Sarah Johnson',
          date: '2026-03-28',
          time: '10:00 AM',
          reason: 'Feeling anxious about upcoming exams',
          status: 'Pending',
          bookingDate: DateTime(2026, 3, 25),
        ),
        BookingModel(
          id: 'BK002',
          studentName: 'Kasun Perera',
          counselorName: 'Ms. Emily Chen',
          date: '2026-03-27',
          time: '2:00 PM',
          reason: 'Need guidance on career choices',
          status: 'Confirmed',
          bookingDate: DateTime(2026, 3, 25),
        ),
        BookingModel(
          id: 'BK003',
          studentName: 'Nimali Fernando',
          counselorName: 'Dr. Michael Smith',
          date: '2026-03-26',
          time: '11:30 AM',
          reason: 'Stress management issues',
          status: 'Completed',
          bookingDate: DateTime(2026, 3, 25),
        ),
        BookingModel(
          id: 'BK004',
          studentName: 'Tharindu Silva',
          counselorName: 'Dr. Sarah Johnson',
          date: '2026-03-29',
          time: '3:00 PM',
          reason: 'Relationship problems affecting studies',
          status: 'Pending',
          bookingDate: DateTime(2026, 3, 25),
        ),
        BookingModel(
          id: 'BK005',
          studentName: 'Dilhani Wickrama',
          counselorName: 'Ms. Lisa Wong',
          date: '2026-03-25',
          time: '9:00 AM',
          reason: 'Depression and mood swings',
          status: 'Cancelled',
          bookingDate: DateTime(2026, 3, 25),
        ),
      ];
    }

    return BookingStorage.bookings
        .map((booking) => {
              'id': booking.id,
              'studentName': booking.studentName,
              'studentId': 'STU${booking.id.substring(2)}',
              'counselor': booking.counselorName,
              'date': booking.date,
              'time': booking.time,
              'reason': booking.reason,
              'status': booking.status,
              'email':
                  '${booking.studentName.toLowerCase().replaceAll(' ', '.')}@uni.ac.lk',
              'phone':
                  '+94 77 ${1000000 + BookingStorage.bookings.indexOf(booking)}',
            })
        .toList();
  }

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _slideController.forward();
        _fadeController.forward();
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> getFilteredBookings() {
    var filtered = _bookings;

    if (_selectedStatusFilter != 'All') {
      filtered = filtered.where((booking) {
        return booking['status'] == _selectedStatusFilter;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((booking) {
        return booking['studentName']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            booking['studentId'].contains(_searchQuery) ||
            booking['id'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = getFilteredBookings();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0D1F1A) : const Color(0xFFF0F4F3),
        body: _isLoading
            ? _buildLoadingScreen()
            : SafeArea(
                child: Column(
                  children: [
                    _buildAnimatedAppBar(),
                    _buildModernTabBar(),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedTab,
                        children: [
                          _buildBookingsContent(filteredBookings),
                          _buildAnalyticsContent(),
                          _buildCounselorsContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1D9E75),
            const Color(0xFF0F6E56),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale =
                    (1.0 + (_pulseController.value * 0.2)).clamp(0.0, 2.0);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 45,
                      color: Color(0xFF1D9E75),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Loading Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(_slideController),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1D9E75),
                const Color(0xFF0F6E56),
                const Color(0xFF085041),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D9E75).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage Counselor Bookings',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButton(Icons.refresh, 'Refresh', () {
                    setState(() {});
                    HapticFeedback.lightImpact();
                  }),
                  const SizedBox(width: 8),
                  _buildActionButton(Icons.logout, 'Logout', _logout),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
        tooltip: tooltip,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  Widget _buildModernTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A332D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = index);
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF1D9E75) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.grey.shade600),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBookingsContent(List<Map<String, dynamic>> filteredBookings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingCount =
        _bookings.where((b) => b['status'] == 'Pending').length;
    final confirmedCount =
        _bookings.where((b) => b['status'] == 'Confirmed').length;
    final completedCount =
        _bookings.where((b) => b['status'] == 'Completed').length;
    final cancelledCount =
        _bookings.where((b) => b['status'] == 'Cancelled').length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                      icon: Icons.calendar_today,
                      value: '${_bookings.length}',
                      label: 'Total',
                      color: const Color(0xFF1D9E75),
                      onTap: () =>
                          setState(() => _selectedStatusFilter = 'All'),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildStatCard(
                      icon: Icons.pending_actions,
                      value: '$pendingCount',
                      label: 'Pending',
                      color: Colors.orange,
                      onTap: () =>
                          setState(() => _selectedStatusFilter = 'Pending'),
                    )),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                      icon: Icons.check_circle,
                      value: '$confirmedCount',
                      label: 'Confirmed',
                      color: Colors.green,
                      onTap: () =>
                          setState(() => _selectedStatusFilter = 'Confirmed'),
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildStatCard(
                      icon: Icons.event_available,
                      value: '$completedCount',
                      label: 'Completed',
                      color: Colors.blue,
                      onTap: () =>
                          setState(() => _selectedStatusFilter = 'Completed'),
                    )),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                      icon: Icons.cancel,
                      value: '$cancelledCount',
                      label: 'Cancelled',
                      color: Colors.red,
                      onTap: () =>
                          setState(() => _selectedStatusFilter = 'Cancelled'),
                    )),
                    const SizedBox(width: 10),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),

          // Status Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((status) {
                  final isSelected = _selectedStatusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(status),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.grey.shade700),
                      ),
                      backgroundColor:
                          isDark ? const Color(0xFF1A332D) : Colors.white,
                      selectedColor: status == 'Pending'
                          ? Colors.orange
                          : status == 'Confirmed'
                              ? Colors.green
                              : status == 'Completed'
                                  ? Colors.blue
                                  : status == 'Cancelled'
                                      ? Colors.red
                                      : const Color(0xFF1D9E75),
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatusFilter = status;
                        });
                        HapticFeedback.lightImpact();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF152A24) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or ID...',
                  hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF1D9E75), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Colors.grey, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),

          // Bookings List
          if (filteredBookings.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) {
                final booking = filteredBookings[index];
                return _buildBookingCard(booking, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isActive = (_selectedStatusFilter == 'All' && label == 'Total') ||
        (_selectedStatusFilter == label);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: color, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(booking['status']);

    // Check if user is anonymous (name starts with "Anonymous User #")
    final studentName = booking['studentName'] as String;
    final isAnonymous = studentName.startsWith('Anonymous User #');
    final displayName = isAnonymous ? studentName : studentName; // Keep as is

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A332D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showBookingDetails(booking),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor,
                            statusColor.withValues(alpha: 0.7)
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isAnonymous
                            ? const Icon(Icons.person_outline,
                                color: Colors.white, size: 24)
                            : Text(
                                studentName
                                    .split(' ')
                                    .map((e) => e[0])
                                    .take(2)
                                    .join(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1F3B42),
                                  ),
                                ),
                              ),
                              if (isAnonymous)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.visibility_off,
                                      size: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${booking['studentId']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${booking['date']} â€¢ ${booking['time']}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking['status'],
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (booking['status'] == 'Pending') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _updateStatus(booking['id'], 'Approved'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Approve',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _updateStatus(booking['id'], 'Denied'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Deny',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ANALYTICS SECTION WITH ALL CHARTS AND GRAPHS
  Widget _buildAnalyticsContent() {
    final pending = _bookings.where((b) => b['status'] == 'Pending').length;
    final confirmed = _bookings.where((b) => b['status'] == 'Confirmed').length;
    final completed = _bookings.where((b) => b['status'] == 'Completed').length;
    final cancelled = _bookings.where((b) => b['status'] == 'Cancelled').length;
    final total = _bookings.length;

    // Weekly data
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dailyBookings = [
      _bookings.where((b) => b['date'].contains('28')).length + 2,
      _bookings.where((b) => b['date'].contains('27')).length + 3,
      _bookings.where((b) => b['date'].contains('26')).length + 1,
      _bookings.where((b) => b['date'].contains('29')).length + 4,
      _bookings.where((b) => b['date'].contains('25')).length + 2,
      1,
      0,
    ];
    final maxBookings = dailyBookings.reduce((a, b) => a > b ? a : b);
    final totalWeekly = dailyBookings.reduce((a, b) => a + b);
    final avgDaily = totalWeekly / 7;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Pie Chart - Booking Status Distribution
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.pie_chart,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Booking Status Distribution',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3B42),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: pending.toDouble(),
                          title: pending > 0 && total > 0
                              ? '${(pending / total * 100).toStringAsFixed(0)}%'
                              : '',
                          color: Colors.orange,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: confirmed.toDouble(),
                          title: confirmed > 0 && total > 0
                              ? '${(confirmed / total * 100).toStringAsFixed(0)}%'
                              : '',
                          color: Colors.green,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: completed.toDouble(),
                          title: completed > 0 && total > 0
                              ? '${(completed / total * 100).toStringAsFixed(0)}%'
                              : '',
                          color: Colors.blue,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: cancelled.toDouble(),
                          title: cancelled > 0 && total > 0
                              ? '${(cancelled / total * 100).toStringAsFixed(0)}%'
                              : '',
                          color: Colors.red,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildLegendItem(Colors.orange, 'Pending', pending, total),
                    _buildLegendItem(
                        Colors.green, 'Confirmed', confirmed, total),
                    _buildLegendItem(
                        Colors.blue, 'Completed', completed, total),
                    _buildLegendItem(Colors.red, 'Cancelled', cancelled, total),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bar Chart - Weekly Activity
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bar_chart,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Weekly Booking Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3B42),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (maxBookings + 1).toDouble(),
                      barGroups: List.generate(7, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: dailyBookings[index].toDouble(),
                              color: const Color(0xFF1D9E75),
                              width: 28,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  days[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total This Week', totalWeekly.toString(),
                          Icons.calendar_view_week),
                      _buildStatItem('Avg. Daily', avgDaily.toStringAsFixed(1),
                          Icons.trending_up),
                      _buildStatItem(
                          'Peak Day',
                          days[dailyBookings.indexOf(maxBookings)],
                          Icons.emoji_events),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Insights Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.trending_up,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Booking Insights',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3B42),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Confirmation Rate',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              total > 0
                                  ? '${((confirmed + completed) / total * 100).toStringAsFixed(1)}%'
                                  : '0%',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D9E75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Pending Actions',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              pending.toString(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (pending > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.tips_and_updates,
                            color: Colors.amber.shade700, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You have $pending pending ${pending == 1 ? 'booking' : 'bookings'} that need your attention.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Top Counselors
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.leaderboard,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Top Counselors',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F3B42),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._counselors.map((counselor) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAF8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              counselor['image'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                                counselor['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                counselor['specialty'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${counselor['rating']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${counselor['sessions']} sessions',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, int count, int total) {
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(1) : '0';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count ($percentage%)',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1D9E75)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3B42),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCounselorsContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _counselors.map((counselor) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      counselor['image'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        counselor['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3B42),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        counselor['specialty'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.work_outline,
                              size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            counselor['experience'],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.star,
                              size: 12, color: Colors.amber.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${counselor['rating']}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: counselor['available']
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: counselor['available']
                              ? Colors.green
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        counselor['available'] ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: counselor['available']
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 50,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No ${_selectedStatusFilter == 'All' ? '' : _selectedStatusFilter} bookings found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String bookingId, String newStatus) async {
    bool firestoreSuccess = false;

    try {
      // Try to update status in Firestore first
      await _bookingService.updateBookingStatus(bookingId, newStatus);

      // Get booking details to send notification
      final bookingDoc = await _bookingService.getBooking(bookingId);
      if (bookingDoc.exists && bookingDoc.data() != null) {
        final bookingData = bookingDoc.data() as Map<String, dynamic>;
        final userId = bookingData['userId'];
        final counselorName = bookingData['counselorName'];
        final date = bookingData['date'];
        final time = bookingData['time'];

        // Send notification based on status
        if (newStatus == 'Confirmed' || newStatus == 'Approved') {
          await _bookingService.sendBookingNotification(
            userId: userId,
            title: 'Booking Approved âœ…',
            body:
                'Your counselor session with $counselorName has been confirmed for $date at $time.',
            type: 'Booking',
          );
        } else if (newStatus == 'Cancelled' || newStatus == 'Denied') {
          await _bookingService.sendBookingNotification(
            userId: userId,
            title: 'Booking Cancelled âŒ',
            body:
                'Your counselor booking was not approved. Please contact support if you have questions.',
            type: 'Booking',
          );
        }
      }

      firestoreSuccess = true;
    } catch (e) {
      debugPrint('Firestore update failed (using local storage): $e');
      // Firestore failed, will use local storage only
    }

    // Always update local storage for UI feedback
    setState(() {
      final index =
          BookingStorage.bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final updatedBooking = BookingModel(
          id: BookingStorage.bookings[index].id,
          studentName: BookingStorage.bookings[index].studentName,
          counselorName: BookingStorage.bookings[index].counselorName,
          date: BookingStorage.bookings[index].date,
          time: BookingStorage.bookings[index].time,
          reason: BookingStorage.bookings[index].reason,
          status: newStatus,
          bookingDate: BookingStorage.bookings[index].bookingDate,
        );
        BookingStorage.bookings[index] = updatedBooking;
      }
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(firestoreSuccess ? Icons.check_circle : Icons.info,
                  color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking $newStatus successfully',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    if (!firestoreSuccess)
                      const Text(
                        '(Saved locally - connect to Firebase for sync)',
                        style: TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: firestoreSuccess
              ? (newStatus == 'Approved' ? Colors.green : Colors.red)
              : Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            booking['studentName']
                                .split(' ')
                                .map((e) => e[0])
                                .take(2)
                                .join(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        booking['studentName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3B42),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking['status'])
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          booking['status'],
                          style: TextStyle(
                            fontSize: 11,
                            color: _getStatusColor(booking['status']),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                        Icons.badge, 'Student ID', booking['studentId']),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.psychology, 'Counselor', booking['counselor']),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.calendar_today, 'Date', booking['date']),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.access_time, 'Time', booking['time']),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.subject, 'Reason', booking['reason']),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.email, 'Email', booking['email']),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.phone, 'Phone', booking['phone']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
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
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F3B42),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  // Stats data
  final Map<String, dynamic> _stats = {
    'totalReports': 156,
    'pendingReports': 23,
    'resolvedReports': 118,
    'totalUsers': 1247,
    'activeUsers': 892,
    'emergencyAlerts': 12,
    'avgResponseTime': '2.4 min',
    'safetyScore': 85,
  };

  // Recent reports
  final List<Map<String, dynamic>> _recentReports = [
    {
      'id': 'R001',
      'type': 'Ragging',
      'location': 'Block D, Ground Floor',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Pending',
      'reportedBy': 'IT23318748',
    },
    {
      'id': 'R002',
      'type': 'Harassment',
      'location': 'Library, 2nd Floor',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'Investigating',
      'reportedBy': 'IT23319234',
    },
    {
      'id': 'R003',
      'type': 'Safety Concern',
      'location': 'Parking Area',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Resolved',
      'reportedBy': 'IT23318892',
    },
    {
      'id': 'R004',
      'type': 'Ragging',
      'location': 'Cafeteria',
      'date': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'status': 'Pending',
      'reportedBy': 'IT23319123',
    },
    {
      'id': 'R005',
      'type': 'Mental Health',
      'location': 'Hostel Block A',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'In Progress',
      'reportedBy': 'IT23318756',
    },
  ];

  // Counselor bookings
  final List<Map<String, dynamic>> _recentBookings = [
    {
      'id': 'B001',
      'student': 'Tharani Bandara',
      'counselor': 'Dr. Priya Mendis',
      'date': DateTime.now().add(const Duration(days: 2)),
      'time': '10:00 AM',
      'status': 'Confirmed',
    },
    {
      'id': 'B002',
      'student': 'Kavindu Perera',
      'counselor': 'Mr. Kasun Fernando',
      'date': DateTime.now().add(const Duration(days: 3)),
      'time': '02:00 PM',
      'status': 'Pending',
    },
    {
      'id': 'B003',
      'student': 'Nimali Silva',
      'counselor': 'Dr. Roshan Silva',
      'date': DateTime.now().add(const Duration(days: 1)),
      'time': '11:00 AM',
      'status': 'Confirmed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1D9E75),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Stats Overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D9E75),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      title: 'Total Reports',
                      value: _stats['totalReports'].toString(),
                      icon: Icons.report,
                      color: const Color(0xFF1D9E75),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      title: 'Pending',
                      value: _stats['pendingReports'].toString(),
                      icon: Icons.pending_actions,
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      title: 'Resolved',
                      value: _stats['resolvedReports'].toString(),
                      icon: Icons.check_circle,
                      color: const Color(0xFF4CAF50),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard(
                      title: 'Total Users',
                      value: _stats['totalUsers'].toString(),
                      icon: Icons.people,
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      title: 'Active',
                      value: _stats['activeUsers'].toString(),
                      icon: Icons.fiber_manual_record,
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      title: 'Emergency',
                      value: _stats['emergencyAlerts'].toString(),
                      icon: Icons.warning,
                      color: const Color(0xFFE24B4A),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'Reports', Icons.report),
                _buildTabButton(1, 'Bookings', Icons.calendar_today),
                _buildTabButton(2, 'Users', Icons.people),
              ],
            ),
          ),

          // Content based on selected tab
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildReportsTab(),
                _buildBookingsTab(),
                _buildUsersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1D9E75).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF1D9E75) : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF1D9E75) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _recentReports.length,
      itemBuilder: (context, index) {
        final report = _recentReports[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 10,
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
                      color: _getStatusColor(report['status'])
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.report,
                      color: _getStatusColor(report['status']),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${report['type']} Report',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          report['location'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report['status'])
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report['status'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(report['status']),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    report['reportedBy'],
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, hh:mm a').format(report['date']),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _showReportDetails(report);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1D9E75),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('View Details'),
                  ),
                  const SizedBox(width: 8),
                  if (report['status'] == 'Pending')
                    ElevatedButton(
                      onPressed: () {
                        _assignToCounselor(report);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9E75),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Assign',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _recentBookings.length,
      itemBuilder: (context, index) {
        final booking = _recentBookings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 10,
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
                      color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF1D9E75),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['student'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'with ${booking['counselor']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: booking['status'] == 'Confirmed'
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                          : const Color(0xFFFF9800).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking['status'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: booking['status'] == 'Confirmed'
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF9800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(booking['date']),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    booking['time'],
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (booking['status'] == 'Pending')
                    ElevatedButton(
                      onPressed: () {
                        _confirmBooking(booking);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9E75),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'User Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total Users: ${_stats['totalUsers']}\nActive Users: ${_stats['activeUsers']}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showUserManagementDialog();
            },
            icon: const Icon(Icons.manage_accounts),
            label: const Text('Manage Users'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9E75),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFF9800);
      case 'Investigating':
        return const Color(0xFF2196F3);
      case 'In Progress':
        return const Color(0xFF2196F3);
      case 'Resolved':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  void _showReportDetails(Map<String, dynamic> report) {
    final status = report['status']?.toString() ?? 'Pending';
    final reportId = report['id']?.toString() ?? '-';
    final type = report['type']?.toString() ?? 'Unknown';
    final location = report['location']?.toString() ?? 'Not specified';
    final reportedBy = report['reportedBy']?.toString() ?? 'Unknown';
    final description = report['description']?.toString() ??
        'Student reported suspicious behavior near Block D. Multiple students witnessed the incident. Security has been notified.';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.report, color: _getStatusColor(status)),
                const SizedBox(width: 8),
                const Text('Report Details'),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1D9E75).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1D9E75)),
              ),
              child: SelectableText(
                'ID: $reportId',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D9E75),
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Type', type),
                    const SizedBox(height: 8),
                    _buildDetailRow('Location', location),
                    const SizedBox(height: 8),
                    _buildDetailRow('Reported By', reportedBy),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Date',
                      DateFormat('MMM dd, yyyy hh:mm a').format(report['date']),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(status).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 13, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (status == 'Pending')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _assignToCounselor(report);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D9E75),
              ),
              child: const Text('Assign to Counselor'),
            ),
        ],
      ),
    );
  }

  void _assignToCounselor(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Assign to Counselor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a counselor to assign this report:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1D9E75),
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
              title: const Text('Dr. Priya Mendis'),
              subtitle: const Text('Senior Counselor'),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1D9E75), width: 2),
                  color: const Color(0xFF1D9E75),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1D9E75),
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
              title: const Text('Mr. Kasun Fernando'),
              subtitle: const Text('Student Welfare Officer'),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1D9E75), width: 2),
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report assigned to counselor successfully'),
                  backgroundColor: Color(0xFF1D9E75),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9E75),
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Booking'),
        content: Text(
            'Confirm booking for ${booking['student']} with ${booking['counselor']} on ${DateFormat('MMM dd, yyyy').format(booking['date'])} at ${booking['time']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking confirmed successfully'),
                  backgroundColor: Color(0xFF1D9E75),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9E75),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showUserManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('User Management'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add, color: Color(0xFF1D9E75)),
                title: const Text('Add New User'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddUserDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.block, color: Color(0xFFE24B4A)),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockUserDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading:
                    const Icon(Icons.verified_user, color: Color(0xFF4CAF50)),
                title: const Text('View All Users'),
                onTap: () {
                  Navigator.pop(context);
                  _showAllUsersDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User added successfully'),
                  backgroundColor: Color(0xFF1D9E75),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9E75),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showBlockUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Block User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Student ID or Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Warning: This action will prevent the user from accessing the app.',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User blocked successfully'),
                  backgroundColor: Color(0xFFE24B4A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showAllUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('All Users'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF1D9E75),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                title: Text('Tharani Bandara'),
                subtitle: Text('IT23318748 â€¢ Active'),
              ),
              const Divider(),
              const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF1D9E75),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                title: Text('Kavindu Perera'),
                subtitle: Text('IT23319234 â€¢ Active'),
              ),
              const Divider(),
              const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF1D9E75),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                title: Text('Nimali Silva'),
                subtitle: Text('IT23318892 â€¢ Active'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to login screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

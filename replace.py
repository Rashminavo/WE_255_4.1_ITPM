import os

path = r"d:\ITPM_Rag_Safe\ITPM_Rag_Safe\WE_255_4.1_ITPM\ragsafe_sl\lib\screens\counselor_screen.dart"

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

old_list = """  void _showBookingsList() {
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
                    final booking = BookingStorage.bookings.reversed.toList()[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
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
                                  color: const Color(0xFF1D9E75).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.psychology, color: Color(0xFF1D9E75), size: 18),
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
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                              const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd, yyyy').format(DateTime.parse(booking.date)),
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                booking.time,
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Booked on: ${DateFormat('MMM dd, yyyy').format(booking.bookingDate)}",
                            style: TextStyle(fontSize: 9, color: Colors.grey[400]),
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
  }"""

new_list = """  void _showBookingsList() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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
                child: StreamBuilder<QuerySnapshot>(
                  stream: BookingService().getUserBookingsStream(userProvider.studentId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No bookings found. Book your first session!'));
                    }
                    final docs = snapshot.data!.docs.toList().reversed.toList();
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final bookingData = docs[index].data() as Map<String, dynamic>;
                        final status = bookingData['status'] ?? 'Pending';
                        final createdAt = bookingData['createdAt'] as Timestamp?;
                        final bookedOnStr = createdAt != null ? DateFormat('MMM dd, yyyy').format(createdAt.toDate()) : 'Unknown';
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
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
                                      color: const Color(0xFF1D9E75).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.psychology, color: Color(0xFF1D9E75), size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bookingData['counselorName'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          bookingData['reason'] ?? '',
                                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: status == "Pending"
                                          ? const Color(0xFFFFF3E0)
                                          : const Color(0xFFE8F8F2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: status == "Pending"
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
                                  const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(DateTime.parse(bookingData['date'])),
                                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    bookingData['time'] ?? '',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Booked on: $bookedOnStr",
                                style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }"""

content = content.replace(old_list, new_list)

old_row = """            // Stats Row
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
            ),"""
new_row = """            // Stats Row
            StreamBuilder<QuerySnapshot>(
              stream: BookingService().getUserBookingsStream(Provider.of<UserProvider>(context).studentId),
              builder: (context, snapshot) {
                int total = 0;
                int upcoming = 0;
                int confirmed = 0;
                if (snapshot.hasData) {
                  final docs = snapshot.data!.docs;
                  total = docs.length;
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  upcoming = docs.where((doc) {
                    try {
                      final bookingDate = DateTime.parse(doc['date']);
                      return bookingDate.isAfter(today) || bookingDate.isAtSameMomentAs(today);
                    } catch (e) {
                      return false;
                    }
                  }).length;
                  confirmed = docs.where((doc) => doc['status'] == "Confirmed" || doc['status'] == "Completed").length;
                }
                return Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.people,
                      value: "$total",
                      label: "Total",
                      color: const Color(0xFF1D9E75),
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.schedule,
                      value: "$upcoming",
                      label: "Upcoming",
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.check_circle,
                      value: "$confirmed",
                      label: "Confirmed",
                      color: const Color(0xFF4CAF50),
                    ),
                  ],
                );
              }
            ),"""

content = content.replace(old_row, new_row)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

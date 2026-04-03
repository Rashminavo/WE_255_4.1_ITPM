import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<Map<String, dynamic>> _notifications;
  late List<Map<String, dynamic>> _filteredNotifications;
  String _selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _notifications = [
      {"title": "Campus alert: Stay alert near Block D", "time": "2 min ago", "isNew": true, "icon": Icons.warning_amber_rounded, "color": 0xFFE24B4A, "type": "Alerts"},
      {"title": "Buddy Gayani accepted your request", "time": "1 hr ago", "isNew": true, "icon": Icons.people, "color": 0xFF1D9E75, "type": "Alerts"},
      {"title": "New ragging awareness tip available", "time": "3 hr ago", "isNew": false, "icon": Icons.info_outline, "color": 0xFF1D9E75, "type": "System"},
      {"title": "Your SOS report has been received", "time": "Yesterday", "isNew": false, "icon": Icons.check_circle_outline, "color": 0xFF1D9E75, "type": "Alerts"},
      {"title": "System: Profile updated successfully", "time": "2 days ago", "isNew": false, "icon": Icons.person_outline, "color": 0xFF888888, "type": "System"},
    ];
    _filteredNotifications = List.from(_notifications);
  }
  
  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == "All") {
        _filteredNotifications = List.from(_notifications);
      } else {
        _filteredNotifications = _notifications.where((n) => n["type"] == filter).toList();
      }
    });
  }

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n["isNew"] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Color(0xFF1D9E75),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _markAsRead(int index) {
    if (_notifications[index]["isNew"] == true) {
      setState(() {
        _notifications[index]["isNew"] = false;
      });
    }
  }

  int get _unreadCount => _notifications.where((n) => n["isNew"] == true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(_unreadCount > 0 ? "Notifications ($_unreadCount)" : "Notifications",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1D9E75),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all, color: Colors.white70, size: 18),
              label: const Text("Mark all read",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text("All"),
                    selected: _selectedFilter == "All",
                    onSelected: (_) => _applyFilter("All"),
                    selectedColor: const Color(0xFF1D9E75),
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: _selectedFilter == "All" ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("Alerts"),
                    selected: _selectedFilter == "Alerts",
                    onSelected: (_) => _applyFilter("Alerts"),
                    selectedColor: const Color(0xFF1D9E75),
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: _selectedFilter == "Alerts" ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("System"),
                    selected: _selectedFilter == "System",
                    onSelected: (_) => _applyFilter("System"),
                    selectedColor: const Color(0xFF1D9E75),
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: _selectedFilter == "System" ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _filteredNotifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notif = _filteredNotifications[index];
                return Dismissible(
                  key: Key('$index'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _markAsRead(index),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: const Color(0xFF1D9E75),
                    child: const Icon(Icons.done, color: Colors.white),
                  ),
                  child: GestureDetector(
                    onTap: () => _markAsRead(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notif["isNew"] ? const Color(0xFFE8F8F2) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: notif["isNew"]
                            ? Border.all(color: const Color(0xFF1D9E75).withValues(alpha: 0.3), width: 1.5)
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(notif["color"]).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(notif["icon"] as IconData,
                                color: Color(notif["color"] as int), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notif["title"],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: notif["isNew"]
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: Colors.black87,
                                    )),
                                const SizedBox(height: 4),
                                Text(notif["time"],
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          if (notif["isNew"])
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1D9E75),
                                shape: BoxShape.circle,
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
    );
  }
}

import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedFilter = "All";

  final List<Map<String, dynamic>> _zones = [
    {"name": "Main Building", "status": "Safe", "color": 0xFF1D9E75, "icon": Icons.school},
    {"name": "Block D", "status": "Risky", "color": 0xFFE24B4A, "icon": Icons.warning_amber_rounded},
    {"name": "Library", "status": "Safe", "color": 0xFF1D9E75, "icon": Icons.local_library},
    {"name": "Canteen Area", "status": "Caution", "color": 0xFFBA7517, "icon": Icons.restaurant},
    {"name": "Parking Lot", "status": "Risky", "color": 0xFFE24B4A, "icon": Icons.local_parking},
    {"name": "Sports Ground", "status": "Safe", "color": 0xFF1D9E75, "icon": Icons.sports_soccer},
  ];

  List<Map<String, dynamic>> get _filteredZones {
    if (_selectedFilter == "All") return _zones;
    return _zones.where((z) => z["status"] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text("Campus Safety Map",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1D9E75),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Map Placeholder
          Container(
            height: 220,
            width: double.infinity,
            color: const Color(0xFFE8F5E9),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 220),
                  painter: _GridPainter(),
                ),
                const Positioned(
                  left: 80, top: 60,
                  child: _ZoneMarker(label: "Main\nBuilding", color: Color(0xFF1D9E75)),
                ),
                const Positioned(
                  right: 80, top: 40,
                  child: _ZoneMarker(label: "Block D", color: Color(0xFFE24B4A)),
                ),
                const Positioned(
                  left: 160, top: 120,
                  child: _ZoneMarker(label: "Library", color: Color(0xFF1D9E75)),
                ),
                const Positioned(
                  right: 120, bottom: 40,
                  child: _ZoneMarker(label: "Canteen", color: Color(0xFFBA7517)),
                ),
                const Positioned(
                  left: 40, bottom: 30,
                  child: _ZoneMarker(label: "Parking", color: Color(0xFFE24B4A)),
                ),
                const Positioned(
                  left: 180, top: 90,
                  child: _CurrentLocationMarker(),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendItem(color: Color(0xFF1D9E75), label: "Safe"),
                        SizedBox(height: 4),
                        _LegendItem(color: Color(0xFFBA7517), label: "Caution"),
                        SizedBox(height: 4),
                        _LegendItem(color: Color(0xFFE24B4A), label: "Risky"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Alert Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFCEBEB),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFE24B4A), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Alert: Block D and Parking Lot marked as risky zones. Stay alert!",
                    style: TextStyle(color: Color(0xFFE24B4A), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: ["All", "Safe", "Caution", "Risky"].map((filter) {
                final isSelected = _selectedFilter == filter;
                Color chipColor = const Color(0xFF1D9E75);
                if (filter == "Risky") chipColor = const Color(0xFFE24B4A);
                if (filter == "Caution") chipColor = const Color(0xFFBA7517);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? chipColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: chipColor),
                      ),
                      child: Text(filter,
                          style: TextStyle(
                              color: isSelected ? Colors.white : chipColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Zone List Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Campus zones",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
            ),
          ),
          const SizedBox(height: 8),

          // Zone List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredZones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final zone = _filteredZones[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(zone["color"] as int).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(zone["icon"] as IconData,
                            color: Color(zone["color"] as int), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(zone["name"],
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(zone["color"] as int).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(zone["status"],
                            style: TextStyle(
                                color: Color(zone["color"] as int),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
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

class _ZoneMarker extends StatelessWidget {
  final String label;
  final Color color;
  const _ZoneMarker({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const Icon(Icons.location_on, color: Colors.white, size: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(label,
              style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

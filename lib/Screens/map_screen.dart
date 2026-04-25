import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/firestore_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedFilter = "All";
  final FirestoreService _firestoreService = FirestoreService();

  Color _getStatusColor(String status) {
    if (status == 'Safe') return const Color(0xFF1D9E75);
    if (status == 'Caution') return const Color(0xFFBA7517);
    if (status == 'Risky') return const Color(0xFFE24B4A);
    return Colors.grey;
  }

  IconData _getZoneIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('library')) return Icons.local_library;
    if (name.contains('canteen')) return Icons.restaurant;
    if (name.contains('parking')) return Icons.local_parking;
    if (name.contains('sports')) return Icons.sports_soccer;
    if (name.contains('block') || name.contains('building')) return Icons.business;
    return Icons.place;
  }

  List<Map<String, dynamic>> _filterZones(List<Map<String, dynamic>> zones) {
    if (_selectedFilter == "All") return zones;
    return zones.where((z) => z["status"] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Campus Safety Map",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1D9E75),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getCampusZones(),
        builder: (context, snapshot) {
          // Handle errors first
          if (snapshot.hasError) {
            debugPrint('Map screen error: ${snapshot.error}');
          }

          // Use data if available, otherwise use default zones
          List<Map<String, dynamic>> zones = snapshot.data ?? [];
          
          // If no data from Firestore (empty list or still loading), use defaults
          if (zones.isEmpty) {
             zones = [
               {"name": "Main Building", "status": "Safe", "lat": 6.9147, "lng": 79.9733},
               {"name": "Library", "status": "Safe", "lat": 6.9152, "lng": 79.9729},
               {"name": "Canteen Area", "status": "Caution", "lat": 6.9140, "lng": 79.9738},
               {"name": "Block D", "status": "Risky", "lat": 6.9145, "lng": 79.9720},
               {"name": "Parking Lot", "status": "Risky", "lat": 6.9135, "lng": 79.9730},
             ];
          }

          final filteredZones = _filterZones(zones);

          return Column(
            children: [
              SizedBox(
                height: 320,
                width: double.infinity,
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(6.9147, 79.9733),
                    initialZoom: 17.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'lk.sliit.ragsafe',
                      additionalOptions: const {
                        'User-Agent': 'lk.sliit.ragsafe/1.0.0',
                      },
                    ),
                    MarkerLayer(
                      markers: filteredZones.map((z) {
                        final lat = z['lat'] as double;
                        final lng = z['lng'] as double;
                        final color = _getStatusColor(z['status']);
                        return Marker(
                          point: LatLng(lat, lng),
                          width: 80,
                          height: 80,
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, color: color, size: 36),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: color, width: 1),
                                ),
                                child: Text(
                                  z['name'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: ["All", "Safe", "Caution", "Risky"].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    Color chipColor = _getStatusColor(filter);
                    if (filter == 'All') chipColor = const Color(0xFF1D9E75);
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? chipColor : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: chipColor),
                          ),
                          child: Text(filter,
                              style: TextStyle(
                                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color ?? chipColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredZones.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final zone = filteredZones[index];
                    final color = _getStatusColor(zone['status']);
                    final icon = _getZoneIcon(zone['name']);
                    
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(zone["name"],
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(zone["status"],
                                style: TextStyle(
                                    color: color,
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
          );
        }
      ),
    );
  }
}

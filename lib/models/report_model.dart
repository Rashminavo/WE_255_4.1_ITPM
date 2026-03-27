// lib/models/report_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType { verbal, physical, sexual, cyber, other }

enum ReportStatus { submitted, pending, investigating, resolved, closed }

class Report {
  final String id;
  final ReportType type;
  final String description;
  final String? mediaUrl;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final ReportStatus status;
  final String? notes;

  Report({
    required this.id,
    required this.type,
    required this.description,
    this.mediaUrl,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.status = ReportStatus.submitted,
    this.notes,
  });

  /// Convert Report to Firestore document JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'mediaUrl': mediaUrl,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status.name,
      'notes': notes,
    };
  }

  /// Create Report from Firestore document
  factory Report.fromMap(Map<String, dynamic> map, String docId) {
    return Report(
      id: docId,
      type: ReportType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReportType.other,
      ),
      description: map['description'] ?? '',
      mediaUrl: map['mediaUrl'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.submitted,
      ),
      notes: map['notes'],
    );
  }

  /// Create Report from Firestore DocumentSnapshot
  factory Report.fromSnapshot(DocumentSnapshot snapshot) {
    return Report.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  /// Generate display string for report type
  static String getReportTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.verbal:
        return 'Verbal Ragging';
      case ReportType.physical:
        return 'Physical Ragging';
      case ReportType.sexual:
        return 'Sexual Harassment';
      case ReportType.cyber:
        return 'Cyber Ragging';
      case ReportType.other:
        return 'Other';
    }
  }

  /// Generate display string for report status
  static String getStatusLabel(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.pending:
        return 'Pending Review';
      case ReportStatus.investigating:
        return 'Under Investigation';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.closed:
        return 'Closed';
    }
  }
}

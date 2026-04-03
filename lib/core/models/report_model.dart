class ReportModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> mediaUrls;
  final String severity; // 'low', 'medium', 'high'
  final bool isAnonymous;
  final String status; // 'pending', 'under_review', 'resolved', 'dismissed'
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.mediaUrls,
    required this.severity,
    required this.isAnonymous,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  ReportModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? mediaUrls,
    String? severity,
    bool? isAnonymous,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      severity: severity ?? this.severity,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'mediaUrls': mediaUrls,
      'severity': severity,
      'isAnonymous': isAnonymous,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      severity: map['severity'] ?? 'low',
      isAnonymous: map['isAnonymous'] ?? false,
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] is String
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ReportModel(id: $id, title: $title, status: $status, severity: $severity)';
  }
}

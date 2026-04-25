class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String category; // 'achievement', 'learning', 'community', 'milestone'
  final int requiredPoints;
  final DateTime createdAt;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.requiredPoints,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'category': category,
      'requiredPoints': requiredPoints,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      category: map['category'] ?? 'achievement',
      requiredPoints: map['requiredPoints'] ?? 0,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  @override
  String toString() => 'BadgeModel(id: $id, name: $name, category: $category)';
}

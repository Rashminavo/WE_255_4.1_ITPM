class ResourceModel {
  final String id;
  final String category;
  final String title;
  final String description;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  ResourceModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ResourceModel.fromMap(Map<String, dynamic> map) {
    return ResourceModel(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  @override
  String toString() => 'ResourceModel(id: $id, title: $title, category: $category)';
}

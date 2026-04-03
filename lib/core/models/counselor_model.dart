class CounselorModel {
  final String id;
  final String name;
  final String specialization;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int sessionCount;
  final String bio;
  final List<String> availability;
  final bool isAvailable;
  final String phone;
  final String email;

  CounselorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.sessionCount,
    required this.bio,
    required this.availability,
    required this.isAvailable,
    required this.phone,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'sessionCount': sessionCount,
      'bio': bio,
      'availability': availability,
      'isAvailable': isAvailable,
      'phone': phone,
      'email': email,
    };
  }

  factory CounselorModel.fromMap(Map<String, dynamic> map) {
    return CounselorModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      sessionCount: map['sessionCount'] ?? 0,
      bio: map['bio'] ?? '',
      availability: List<String>.from(map['availability'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
    );
  }

  @override
  String toString() => 'CounselorModel(id: $id, name: $name, rating: $rating)';
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String photoUrl;
  final String role; // 'user', 'admin', 'counselor'
  final DateTime createdAt;
  final DateTime lastLogin;
  final List<String> skills;
  final String faculty;
  final String hostel;
  final List<String> availability;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.photoUrl,
    required this.role,
    required this.createdAt,
    required this.lastLogin,
    required this.skills,
    required this.faculty,
    required this.hostel,
    required this.availability,
  });

  // Copy with
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
    List<String>? skills,
    String? faculty,
    String? hostel,
    List<String>? availability,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      skills: skills ?? this.skills,
      faculty: faculty ?? this.faculty,
      hostel: hostel ?? this.hostel,
      availability: availability ?? this.availability,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'skills': skills,
      'faculty': faculty,
      'hostel': hostel,
      'availability': availability,
    };
  }

  // From Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLogin: map['lastLogin'] is String
          ? DateTime.parse(map['lastLogin'])
          : DateTime.now(),
      skills: List<String>.from(map['skills'] ?? []),
      faculty: map['faculty'] ?? '',
      hostel: map['hostel'] ?? '',
      availability: List<String>.from(map['availability'] ?? []),
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, role: $role)';
  }
}

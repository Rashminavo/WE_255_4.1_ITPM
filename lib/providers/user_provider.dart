import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  // User data
  String _fullName = "Tharani Bandara";
  String _studentId = "IT23318748";
  String _email = "tharani@gmail.com";
  String _faculty = "Faculty of Computing";
  String _phone = "0771234567";
  
  // Handle both File (mobile) and Uint8List (web) for profile image
  dynamic _profileImage; // Can be File or Uint8List
  Uint8List? _webImageBytes; // For web platform
  
  int _safetyScore = 85;
  List<Map<String, dynamic>> _achievements = [
    {"icon": Icons.shield, "title": "Safety Champion", "desc": "7 days incident-free", "color": 0xFF4CAF50},
    {"icon": Icons.people, "title": "Buddy Helper", "desc": "Helped 5 students", "color": 0xFF2196F3},
    {"icon": Icons.star, "title": "Active Reporter", "desc": "Submitted 3 reports", "color": 0xFFFF9800},
  ];
  List<Map<String, dynamic>> _emergencyContacts = [
    {"name": "Father", "phone": "+94 77 987 6543", "relation": "Parent"},
    {"name": "Kavindu", "phone": "+94 76 456 7890", "relation": "Buddy"},
  ];

  // Settings
  bool _isAnonymousMode = false;

  // Getters
  String get fullName => _fullName;
  String get studentId => _studentId;
  String get email => _email;
  String get faculty => _faculty;
  String get phone => _phone;
  
  dynamic get profileImage => kIsWeb ? _webImageBytes : _profileImage;
  Uint8List? get webImageBytes => _webImageBytes;
  File? get mobileImageFile => _profileImage is File ? _profileImage as File? : null;
  
  int get safetyScore => _safetyScore;
  List<Map<String, dynamic>> get achievements => _achievements;
  List<Map<String, dynamic>> get emergencyContacts => _emergencyContacts;
  bool get isAnonymousMode => _isAnonymousMode;

  // Update methods
  void updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String studentId,
    required String faculty,
    dynamic profileImage,
  }) {
    _fullName = fullName;
    _email = email;
    _phone = phone;
    _studentId = studentId;
    _faculty = faculty;
    
    if (profileImage != null) {
      if (kIsWeb && profileImage is Uint8List) {
        _webImageBytes = profileImage;
        _profileImage = null;
      } else if (!kIsWeb && profileImage is File) {
        _profileImage = profileImage;
        _webImageBytes = null;
      }
    }
    notifyListeners();
  }

  void updateProfileImage(dynamic image) {
    if (kIsWeb && image is Uint8List) {
      _webImageBytes = image;
      _profileImage = null;
    } else if (!kIsWeb && image is File) {
      _profileImage = image;
      _webImageBytes = null;
    } else if (image == null) {
      _webImageBytes = null;
      _profileImage = null;
    }
    notifyListeners();
  }

  void toggleAnonymousMode(bool value) async {
    _isAnonymousMode = value;
    notifyListeners();
    
    // Save to Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'anonymousMode': value});
      }
    } catch (e) {
      debugPrint('Error saving anonymous mode to Firestore: $e');
    }
  }

  // Load anonymous mode from Firestore
  Future<void> loadAnonymousMode() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          _isAnonymousMode = doc.data()!['anonymousMode'] ?? false;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading anonymous mode from Firestore: $e');
    }
  }
}
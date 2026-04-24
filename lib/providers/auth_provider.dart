import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/auth/app_role.dart';
import '../core/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  AppRole get currentRole => AppRoleX.fromString(_user?.role);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // Get current user stream from auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Listen to user changes and update _user
  Future<void> initUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await fetchUserData(firebaseUser.uid);
    } else {
      _user = null;
      notifyListeners();
    }
  }

  // Fetch user data from Firestore
  Future<void> fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        _error = null;
      } else {
        _user = null;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching user: $e');
    }
    notifyListeners();
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        photoUrl: '',
        role: 'student',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        skills: [],
        faculty: '',
        hostel: '',
        availability: [],
      );

      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      _user = newUser;
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Registration error: $e');
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({
        'lastLogin': DateTime.now().toIso8601String(),
      });

      await fetchUserData(userCredential.user!.uid);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Login error: $e');
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Logout error: $e');
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
    String? faculty,
    String? hostel,
    List<String>? skills,
    List<String>? availability,
  }) async {
    if (_user == null) return false;

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (faculty != null) updates['faculty'] = faculty;
      if (hostel != null) updates['hostel'] = hostel;
      if (skills != null) updates['skills'] = skills;
      if (availability != null) updates['availability'] = availability;

      await _firestore.collection('users').doc(_user!.uid).update(updates);

      // Update local user object
      _user = _user!.copyWith(
        name: name,
        phone: phone,
        photoUrl: photoUrl,
        faculty: faculty,
        hostel: hostel,
        skills: skills,
        availability: availability,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Update profile error: $e');
      notifyListeners();
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Reset password error: $e');
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

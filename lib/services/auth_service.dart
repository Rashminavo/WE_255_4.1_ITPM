import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up
  Future<User?> signUp(String email, String password, String name, String studentId) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      // Also store user in Firestore Users collection
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'fullName': name,  // Changed from 'name' to 'fullName' for consistency
          'name': name,       // Keep both for backward compatibility
          'studentId': studentId,
          'role': 'student', // default role
          'safetyScore': 85,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Send welcome notification
        await FirestoreService().createNotification(
          'Welcome to RagSafe SL!',
          'System',
          userId: user.uid,
          body: 'Your account has been created successfully. Stay safe!',
        );
      }
      return user;
    } catch (e) {
      debugPrint('Auth Service - Sign up error: $e');
      rethrow;
    }
  }

  // Sign in
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
        
      // Force admin role in database if logging in as admin
      if (result.user != null && 
          (email.toLowerCase() == 'admin@admin.com' || 
           email.toLowerCase() == 'admin@ragsafe.com')) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'role': 'admin',
          'email': email,
        }, SetOptions(merge: true));
      }
        
      // Send login notification
      if (result.user != null) {
        await FirestoreService().createNotification(
          'Login Successful',
          'System',
          userId: result.user!.uid,
          body: 'You logged in successfully at ${DateTime.now().toString().substring(0, 16)}',
        );
      }
  
      return result.user;
    } catch (e) {
      debugPrint('Auth Service - Sign in error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Auth Service - Sign out error: $e');
    }
  }

  // Auth State Stream
  Stream<User?> get user => _auth.authStateChanges();
  
  // Current user
  User? get currentUser => _auth.currentUser;

  // Get user role from Firestore
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['role'] ?? 'student';
      }
    } catch (e) {
      debugPrint('Error getting user role: $e');
    }
    return 'student'; // Default fallback
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream Campus Zones
  Stream<List<Map<String, dynamic>>> getCampusZones() {
    return _db.collection('campus_zones').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data()
      }).toList();
    });
  }

  // Stream Notifications (all - for admin)
  Stream<List<Map<String, dynamic>>> getNotifications() {
    return _db.collection('notifications')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data()
        }).toList();
    });
  }

  // Stream notifications for specific user
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return _db.collection('notifications')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data()
        }).toList();
    });
  }

  // Create an SOS Alert
  Future<void> triggerSOS(String userId, String location) async {
    try {
      await _db.collection('sos_alerts').add({
        'userId': userId,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });
      // Also broadcast a notification
      await createNotification('Emergency SOS triggered near $location', 'Alerts');
    } catch (e) {
      debugPrint('Firestore Error triggering SOS: $e');
    }
  }

  // Create a Notification
  Future<void> createNotification(String title, String type) async {
    try {
      await _db.collection('notifications').add({
        'title': title,
        'type': type,
        'isNew': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore Error creating notification: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream Campus Zones with error handling and timeout
  Stream<List<Map<String, dynamic>>> getCampusZones() {
    return _db.collection('campus_zones').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data()
      }).toList();
    }).handleError((error) {
      debugPrint('Error fetching campus zones: $error');
      return <Map<String, dynamic>>[];
    }).timeout(
      const Duration(seconds: 5),
      onTimeout: (sink) {
        debugPrint('Campus zones stream timeout - using empty list');
        sink.add(<Map<String, dynamic>>[]);
        sink.close();
      },
    );
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

  // Stream notifications for specific user with timeout
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    
    return _db.collection('notifications')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data()
        }).toList();
    }).handleError((error) {
      debugPrint('Error fetching user notifications: $error');
      return <Map<String, dynamic>>[];
    }).timeout(
      const Duration(seconds: 5),
      onTimeout: (sink) {
        debugPrint('Notifications stream timeout - using empty list');
        sink.add(<Map<String, dynamic>>[]);
        sink.close();
      },
    );
  }

  // Stream all notifications (fallback without filtering)
  Stream<List<Map<String, dynamic>>> getAllNotifications() {
    return _db.collection('notifications')
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
  Future<void> createNotification(String title, String type, {String? userId, String? body}) async {
    try {
      await _db.collection('notifications').add({
        'title': title,
        'type': type,
        'body': body ?? '',
        'isNew': true,
        'userId': userId, // Optional: specify user ID for targeted notifications
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore Error creating notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isNew': false,
      });
    } catch (e) {
      debugPrint('Firestore Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final snapshot = await _db.collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isNew', isEqualTo: true)
          .get();
      
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isNew': false});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore Error marking all notifications as read: $e');
    }
  }
}

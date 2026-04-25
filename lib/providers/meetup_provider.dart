import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetupProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  List<Map<String, dynamic>> _scheduledMeetups = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get scheduledMeetups => _scheduledMeetups;

  Future<void> fetchUserMeetups(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meetups')
          .orderBy('scheduledDate', descending: false)
          .get();

      _scheduledMeetups = snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      debugPrint('Error fetching meetups: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> scheduleMeetup({
    required String userId,
    required String buddyId,
    required DateTime scheduledDate,
    required String location,
    required String topic,
  }) async {
    try {
      final meetupDoc = {
        'buddy1': userId,
        'buddy2': buddyId,
        'scheduledDate': scheduledDate.toIso8601String(),
        'location': location,
        'topic': topic,
        'status': 'scheduled',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final docRef = await _firestore.collection('meetups').add(meetupDoc);

      // Add to both users' meetups
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('meetups')
          .doc(docRef.id)
          .set(meetupDoc);

      await _firestore
          .collection('users')
          .doc(buddyId)
          .collection('meetups')
          .doc(docRef.id)
          .set(meetupDoc);

      return true;
    } catch (e) {
      debugPrint('Error scheduling meetup: $e');
      return false;
    }
  }

  Future<bool> completeMeetup(String meetupId, String userId) async {
    try {
      await _firestore.collection('meetups').doc(meetupId).update({
        'status': 'completed',
        'completedAt': DateTime.now().toIso8601String(),
      });

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('meetups')
          .doc(meetupId)
          .update({
        'status': 'completed',
        'completedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error completing meetup: $e');
      return false;
    }
  }

  Future<bool> cancelMeetup(String meetupId, String userId) async {
    try {
      await _firestore.collection('meetups').doc(meetupId).update({
        'status': 'cancelled',
        'cancelledAt': DateTime.now().toIso8601String(),
      });

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('meetups')
          .doc(meetupId)
          .update({
        'status': 'cancelled',
        'cancelledAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error cancelling meetup: $e');
      return false;
    }
  }
}

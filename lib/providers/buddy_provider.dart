import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/buddy_match_model.dart';

class BuddyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  List<Map<String, dynamic>> _buddyMatches = [];
  List<Map<String, dynamic>> _myBuddies = [];
  List<BuddyMatchModel> _activeMatches = [];
  List<BuddyMatchModel> _pendingMatches = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get buddyMatches => _buddyMatches;
  List<Map<String, dynamic>> get myBuddies => _myBuddies;
  List<Map<String, dynamic>> get availableBuddies => _buddyMatches; // Alias for compatibility
  List<BuddyMatchModel> get activeMatches => _activeMatches;
  List<BuddyMatchModel> get pendingMatches => _pendingMatches;
  String? get error => _error;

  Future<void> searchBuddies(String currentUserId, {
    String? faculty,
    String? hostel,
    List<String>? skills,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Query<Map<String, dynamic>> query = _firestore.collection('users').where('uid', isNotEqualTo: currentUserId);

      if (faculty != null && faculty.isNotEmpty) {
        query = query.where('faculty', isEqualTo: faculty);
      }

      final snapshot = await query.limit(20).get();
      _buddyMatches = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error searching buddies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyBuddies(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('buddies')
          .get();

      _myBuddies = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching my buddies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMatches(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('buddy_matches')
          .where('user1Id', isEqualTo: userId)
          .get();

      final snapshot2 = await _firestore
          .collection('buddy_matches')
          .where('user2Id', isEqualTo: userId)
          .get();

      final matches = [
        ...snapshot.docs.map((doc) => BuddyMatchModel.fromMap(doc.data())),
        ...snapshot2.docs.map((doc) => BuddyMatchModel.fromMap(doc.data())),
      ];

      _activeMatches = matches.where((m) => m.status == 'active').toList();
      _pendingMatches = matches.where((m) => m.status == 'pending').toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching matches: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendBuddyRequest({
    required String fromUserId,
    required String toUserId,
    required int matchScore,
  }) async {
    try {
      final matchId = _firestore.collection('buddy_matches').doc().id;
      await _firestore.collection('buddy_matches').doc(matchId).set({
        'matchId': matchId,
        'user1Id': fromUserId,
        'user2Id': toUserId,
        'matchScore': matchScore,
        'status': 'pending',
        'requestedBy': fromUserId,
        'createdAt': DateTime.now(),
        'lastMessageAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error sending buddy request: $e');
      return false;
    }
  }

  Future<bool> acceptBuddyRequest({
    required String matchId,
    required String userId,
  }) async {
    try {
      // Get the match to find the buddy ID
      final matchDoc = await _firestore.collection('buddy_matches').doc(matchId).get();
      final matchData = matchDoc.data();
      
      if (matchData == null) return false;
      
      final buddyId = matchData['user1Id'] == userId ? matchData['user2Id'] : matchData['user1Id'];

      // Update match status to active
      await _firestore.collection('buddy_matches').doc(matchId).update({
        'status': 'active',
        'lastMessageAt': DateTime.now(),
      });

      // Add to both users' buddy lists
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('buddies')
          .doc(buddyId)
          .set({'buddyId': buddyId, 'connectedAt': DateTime.now()});

      await _firestore
          .collection('users')
          .doc(buddyId)
          .collection('buddies')
          .doc(userId)
          .set({'buddyId': userId, 'connectedAt': DateTime.now()});

      // Create conversation
      await _firestore.collection('conversations').add({
        'user1Id': userId,
        'user2Id': buddyId,
        'matchId': matchId,
        'createdAt': DateTime.now(),
        'lastMessageAt': DateTime.now(),
      });

      await fetchMatches(userId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error accepting buddy request: $e');
      return false;
    }
  }

  Future<bool> declineBuddyRequest({
    required String matchId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('buddy_matches').doc(matchId).update({
        'status': 'ended',
      });
      await fetchMatches(userId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error declining buddy request: $e');
      return false;
    }
  }
}


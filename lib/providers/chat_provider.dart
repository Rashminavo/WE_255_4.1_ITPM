import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  List<Map<String, dynamic>> _conversations = [];
  List<MessageModel> _messages = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  String? get error => _error;

  Future<void> fetchConversations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .orderBy('lastMessageTime', descending: true)
          .get();

      _conversations = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching conversations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMessages(String conversationId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      _messages = snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching messages: $e');
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  Future<String> createConversation(String userId, String buddyId, String buddyName) async {
    try {
      final conversationId = [userId, buddyId]..sort();
      final docId = conversationId.join('_');

      await _firestore.collection('conversations').doc(docId).set({
        'participants': [userId, buddyId],
        'createdAt': DateTime.now(),
        'lastMessageTime': DateTime.now(),
      }, SetOptions(merge: true));

      return docId;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating conversation: $e');
      return '';
    }
  }
}

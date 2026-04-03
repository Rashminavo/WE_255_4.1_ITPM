import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_post_model.dart';

class ForumProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  List<ForumPostModel> _posts = [];
  List<Map<String, dynamic>> _comments = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<ForumPostModel> get posts => _posts;
  List<Map<String, dynamic>> get comments => _comments;
  String? get error => _error;

  Future<void> fetchForumPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('forum_posts')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _posts = snapshot.docs
          .map((doc) => ForumPostModel.fromMap({...doc.data(), 'postId': doc.id}))
          .toList();
    } catch (e) {
      _error = 'Error fetching forum posts: $e';
      debugPrint(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  Stream<List<ForumPostModel>> getForumPostsStream() {
    return _firestore
        .collection('forum_posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ForumPostModel.fromMap({...doc.data(), 'postId': doc.id}))
            .toList());
  }

  Future<void> fetchPostComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('forum_posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();

      _comments = snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Error fetching comments: $e';
      debugPrint(_error);
    }
  }

  Future<bool> createPost({
    required String userId,
    required String authorName,
    required String title,
    required String content,
    List<String> tags = const [],
    bool isAnonymous = false,
  }) async {
    try {
      final postId = _firestore.collection('forum_posts').doc().id;
      final forumPost = ForumPostModel(
        postId: postId,
        authorId: userId,
        authorName: isAnonymous ? 'Anonymous' : authorName,
        title: title,
        content: content,
        tags: tags,
        upvotes: 0,
        downvotes: 0,
        upvotedBy: [],
        downvotedBy: [],
        isAnonymous: isAnonymous,
        reportCount: 0,
        isHidden: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('forum_posts').doc(postId).set(forumPost.toMap());
      await fetchForumPosts();
      return true;
    } catch (e) {
      _error = 'Error creating post: $e';
      debugPrint(_error);
      return false;
    }
  }

  Future<bool> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    try {
      await _firestore
          .collection('forum_posts')
          .doc(postId)
          .collection('comments')
          .add({
        'userId': userId,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
        'upvotes': 0,
      });

      // Update comment count
      await _firestore.collection('forum_posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });

      await fetchPostComments(postId);
      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
  }

  Future<bool> upvotePost(String postId, String userId) async {
    try {
      final postDoc = await _firestore.collection('forum_posts').doc(postId).get();
      final postData = postDoc.data() as Map<String, dynamic>;
      final upvotedBy = List<String>.from(postData['upvotedBy'] ?? []);
      final downvotedBy = List<String>.from(postData['downvotedBy'] ?? []);

      // Check if already upvoted
      if (upvotedBy.contains(userId)) return false;

      // Remove from downvotes if user previously downvoted
      if (downvotedBy.contains(userId)) {
        downvotedBy.remove(userId);
        await _firestore.collection('forum_posts').doc(postId).update({
          'downvotes': FieldValue.increment(-1),
          'downvotedBy': downvotedBy,
        });
      }

      // Add to upvotes
      upvotedBy.add(userId);
      await _firestore.collection('forum_posts').doc(postId).update({
        'upvotes': FieldValue.increment(1),
        'upvotedBy': upvotedBy,
      });

      await fetchForumPosts();
      return true;
    } catch (e) {
      _error = 'Error upvoting: $e';
      debugPrint(_error);
      return false;
    }
  }

  Future<bool> downvotePost(String postId, String userId) async {
    try {
      final postDoc = await _firestore.collection('forum_posts').doc(postId).get();
      final postData = postDoc.data() as Map<String, dynamic>;
      final upvotedBy = List<String>.from(postData['upvotedBy'] ?? []);
      final downvotedBy = List<String>.from(postData['downvotedBy'] ?? []);

      // Check if already downvoted
      if (downvotedBy.contains(userId)) return false;

      // Remove from upvotes if user previously upvoted
      if (upvotedBy.contains(userId)) {
        upvotedBy.remove(userId);
        await _firestore.collection('forum_posts').doc(postId).update({
          'upvotes': FieldValue.increment(-1),
          'upvotedBy': upvotedBy,
        });
      }

      // Add to downvotes
      downvotedBy.add(userId);
      await _firestore.collection('forum_posts').doc(postId).update({
        'downvotes': FieldValue.increment(1),
        'downvotedBy': downvotedBy,
      });

      await fetchForumPosts();
      return true;
    } catch (e) {
      _error = 'Error downvoting: $e';
      debugPrint(_error);
      return false;
    }
  }

  Future<bool> removeVote(String postId, String userId) async {
    try {
      final postDoc = await _firestore.collection('forum_posts').doc(postId).get();
      final postData = postDoc.data() as Map<String, dynamic>;
      final upvotedBy = List<String>.from(postData['upvotedBy'] ?? []);
      final downvotedBy = List<String>.from(postData['downvotedBy'] ?? []);

      if (upvotedBy.contains(userId)) {
        upvotedBy.remove(userId);
        await _firestore.collection('forum_posts').doc(postId).update({
          'upvotes': FieldValue.increment(-1),
          'upvotedBy': upvotedBy,
        });
      } else if (downvotedBy.contains(userId)) {
        downvotedBy.remove(userId);
        await _firestore.collection('forum_posts').doc(postId).update({
          'downvotes': FieldValue.increment(-1),
          'downvotedBy': downvotedBy,
        });
      }

      await fetchForumPosts();
      return true;
    } catch (e) {
      _error = 'Error removing vote: $e';
      debugPrint(_error);
      return false;
    }
  }

  Future<bool> reportPost(String postId, String reportedBy) async {
    try {
      await _firestore.collection('forum_posts').doc(postId).update({
        'reportCount': FieldValue.increment(1),
      });

      // Store report details
      await _firestore
          .collection('forum_posts')
          .doc(postId)
          .collection('reports')
          .doc(reportedBy)
          .set({'reportedAt': DateTime.now(), 'reportedBy': reportedBy});

      await fetchForumPosts();
      return true;
    } catch (e) {
      _error = 'Error reporting post: $e';
      debugPrint(_error);
      return false;
    }
  }

  Future<ForumPostModel?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('forum_posts').doc(postId).get();
      if (doc.exists) {
        return ForumPostModel.fromMap({...doc.data()!, 'postId': doc.id});
      }
      return null;
    } catch (e) {
      _error = 'Error fetching post: $e';
      debugPrint(_error);
      return null;
    }
  }

  List<ForumPostModel> getPostsByTag(String tag) {
    return _posts.where((post) => post.tags.contains(tag)).toList();
  }

  List<ForumPostModel> searchPosts(String query) {
    final lowerQuery = query.toLowerCase();
    return _posts
        .where((post) =>
            post.title.toLowerCase().contains(lowerQuery) ||
            post.content.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _firestore.collection('forum_posts').doc(postId).delete();
      await fetchForumPosts();
      return true;
    } catch (e) {
      _error = 'Error deleting post: $e';
      debugPrint(_error);
      return false;
    }
  }
}


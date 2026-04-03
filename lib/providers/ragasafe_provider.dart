import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/report_model.dart';
import '../core/models/counselor_model.dart';
import '../core/models/resource_model.dart';
import '../core/models/quiz_model.dart';
import '../core/models/badge_model.dart';

class RagaSafeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reports
  List<ReportModel> _reports = [];
  bool _isLoadingReports = false;

  // Counselors
  List<CounselorModel> _counselors = [];
  bool _isLoadingCounselors = false;

  // Resources
  List<ResourceModel> _resources = [];
  bool _isLoadingResources = false;

  // Quiz
  List<QuizQuestion> _quizQuestions = [];
  bool _isLoadingQuiz = false;

  // Badges
  List<BadgeModel> _badges = [];
  List<UserProgress> _userProgresses = [];
  bool _isLoadingBadges = false;

  // Getters
  List<ReportModel> get reports => _reports;
  bool get isLoadingReports => _isLoadingReports;

  List<CounselorModel> get counselors => _counselors;
  bool get isLoadingCounselors => _isLoadingCounselors;

  List<ResourceModel> get resources => _resources;
  bool get isLoadingResources => _isLoadingResources;

  List<QuizQuestion> get quizQuestions => _quizQuestions;
  bool get isLoadingQuiz => _isLoadingQuiz;

  List<BadgeModel> get badges => _badges;
  List<UserProgress> get userProgresses => _userProgresses;
  bool get isLoadingBadges => _isLoadingBadges;

  // Initialize RagaSafe data (load from Firestore)
  Future<void> initializeRagaSafeData() async {
    await Future.wait([
      fetchCounselors(),
      fetchResources(),
      fetchQuizQuestions(),
      fetchBadges(),
    ]);
  }

  // ===== COUNSELORS =====
  Future<void> fetchCounselors() async {
    _isLoadingCounselors = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('counselors')
          .orderBy('name')
          .get();

      _counselors = snapshot.docs
          .map((doc) => CounselorModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching counselors: $e');
    }

    _isLoadingCounselors = false;
    notifyListeners();
  }

  // ===== RESOURCES =====
  Future<void> fetchResources() async {
    _isLoadingResources = true;
    notifyListeners();

    try {
      final snapshot =
          await _firestore.collection('resources').orderBy('category').get();

      _resources = snapshot.docs
          .map((doc) => ResourceModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching resources: $e');
    }

    _isLoadingResources = false;
    notifyListeners();
  }

  // ===== QUIZ =====
  Future<void> fetchQuizQuestions() async {
    _isLoadingQuiz = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .doc('mental_health_assessment')
          .collection('questions')
          .orderBy('order')
          .get();

      _quizQuestions = snapshot.docs
          .map((doc) => QuizQuestion.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching quiz questions: $e');
    }

    _isLoadingQuiz = false;
    notifyListeners();
  }

  // Submit quiz response and calculate score
  Future<Map<String, dynamic>> submitQuizResponse(
    String userId,
    Map<String, int> answers,
  ) async {
    try {
      int totalScore = 0;
      for (int i = 0; i < _quizQuestions.length; i++) {
        int? answer = answers[i.toString()];
        if (answer != null && answer >= 0 && answer < 4) {
          totalScore += answer;
        }
      }

      // Store response in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_responses')
          .add({
        'timestamp': DateTime.now().toIso8601String(),
        'score': totalScore,
        'maxScore': _quizQuestions.length * 3,
        'percentage': ((totalScore / (_quizQuestions.length * 3)) * 100).toStringAsFixed(1),
      });

      return {
        'score': totalScore,
        'maxScore': _quizQuestions.length * 3,
        'percentage': ((totalScore / (_quizQuestions.length * 3)) * 100),
      };
    } catch (e) {
      debugPrint('Error submitting quiz: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  // ===== BADGES =====
  Future<void> fetchBadges() async {
    _isLoadingBadges = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('badges')
          .orderBy('name')
          .get();

      _badges = snapshot.docs
          .map((doc) => BadgeModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching badges: $e');
    }

    _isLoadingBadges = false;
    notifyListeners();
  }

  // Track user progress
  Future<void> trackProgress(String userId, String badgeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(badgeId)
          .set({
        'unlockedAt': DateTime.now().toIso8601String(),
        'badgeId': badgeId,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error tracking progress: $e');
    }
  }

  // Get user progress
  Future<List<UserProgress>> fetchUserProgress(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .get();

      _userProgresses = snapshot.docs
          .map((doc) =>
              UserProgress.fromMap(doc.data()))
          .toList();

      notifyListeners();
      return _userProgresses;
    } catch (e) {
      debugPrint('Error fetching user progress: $e');
      return [];
    }
  }

  // ===== REPORTS =====
  Future<void> fetchUserReports(String userId) async {
    _isLoadingReports = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _reports = snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching reports: $e');
    }

    _isLoadingReports = false;
    notifyListeners();
  }

  Future<bool> createReport({
    required String userId,
    required String title,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required List<String> mediaUrls,
    required String severity,
    required bool isAnonymous,
  }) async {
    try {
      final report = ReportModel(
        id: _firestore.collection('reports').doc().id,
        userId: userId,
        title: title,
        description: description,
        location: location,
        latitude: latitude,
        longitude: longitude,
        mediaUrls: mediaUrls,
        severity: severity,
        isAnonymous: isAnonymous,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('reports')
          .doc(report.id)
          .set(report.toMap());

      _reports.insert(0, report);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating report: $e');
      return false;
    }
  }

  Future<bool> updateReportStatus(String reportId, String status) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index >= 0) {
        _reports[index] = _reports[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Error updating report: $e');
      return false;
    }
  }
}

class UserProgress {
  final String badgeId;
  final DateTime unlockedAt;

  UserProgress({required this.badgeId, required this.unlockedAt});

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      badgeId: map['badgeId'] ?? '',
      unlockedAt: map['unlockedAt'] is String
          ? DateTime.parse(map['unlockedAt'])
          : DateTime.now(),
    );
  }
}

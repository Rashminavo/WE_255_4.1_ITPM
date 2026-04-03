import 'package:cloud_firestore/cloud_firestore.dart';

class BuddyMatchModel {
  final String matchId;
  final String user1Id;
  final String user2Id;
  final int matchScore;
  final String status; // "pending", "active", "ended"
  final String requestedBy;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  BuddyMatchModel({
    required this.matchId,
    required this.user1Id,
    required this.user2Id,
    required this.matchScore,
    required this.status,
    required this.requestedBy,
    required this.createdAt,
    required this.lastMessageAt,
  });

  String buddyId(String currentUserId) =>
      currentUserId == user1Id ? user2Id : user1Id;

  bool isPending() => status == 'pending';
  bool isActive() => status == 'active';
  bool isEnded() => status == 'ended';

  factory BuddyMatchModel.fromMap(Map<String, dynamic> map) {
    return BuddyMatchModel(
      matchId: map['matchId'] ?? '',
      user1Id: map['user1Id'] ?? '',
      user2Id: map['user2Id'] ?? '',
      matchScore: map['matchScore'] ?? 0,
      status: map['status'] ?? 'pending',
      requestedBy: map['requestedBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageAt:
          (map['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'matchId': matchId,
        'user1Id': user1Id,
        'user2Id': user2Id,
        'matchScore': matchScore,
        'status': status,
        'requestedBy': requestedBy,
        'createdAt': createdAt,
        'lastMessageAt': lastMessageAt,
      };

  BuddyMatchModel copyWith({String? status}) => BuddyMatchModel(
        matchId: matchId,
        user1Id: user1Id,
        user2Id: user2Id,
        matchScore: matchScore,
        status: status ?? this.status,
        requestedBy: requestedBy,
        createdAt: createdAt,
        lastMessageAt: lastMessageAt,
      );
}

class ForumPostModel {
  final String postId;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final List<String> tags;
  int upvotes;
  int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final bool isAnonymous;
  final int reportCount;
  final bool isHidden;
  final DateTime createdAt;

  ForumPostModel({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.tags,
    required this.upvotes,
    required this.downvotes,
    required this.upvotedBy,
    required this.downvotedBy,
    required this.isAnonymous,
    required this.reportCount,
    required this.isHidden,
    required this.createdAt,
  });

  factory ForumPostModel.fromMap(Map<String, dynamic> map) {
    return ForumPostModel(
      postId: map['postId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Anonymous',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      upvotedBy: List<String>.from(map['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(map['downvotedBy'] ?? []),
      isAnonymous: map['isAnonymous'] ?? true,
      reportCount: map['reportCount'] ?? 0,
      isHidden: map['isHidden'] ?? false,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'tags': tags,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'isAnonymous': isAnonymous,
      'reportCount': reportCount,
      'isHidden': isHidden,
      'createdAt': createdAt,
    };
  }
}

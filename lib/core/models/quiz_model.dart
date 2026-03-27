class QuizQuestion {
  final String id;
  final int order;
  final String question;
  final List<String> options;
  final String category;
  final String? explanation;

  QuizQuestion({
    required this.id,
    required this.order,
    required this.question,
    required this.options,
    required this.category,
    this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'question': question,
      'options': options,
      'category': category,
      'explanation': explanation,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      order: map['order'] ?? 0,
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      category: map['category'] ?? '',
      explanation: map['explanation'],
    );
  }

  @override
  String toString() => 'QuizQuestion(id: $id, order: $order, category: $category)';
}

class QuizResponse {
  final String userId;
  final Map<int, int> answers; // questionIndex -> selectedOptionIndex
  final int score;
  final int maxScore;
  final DateTime completedAt;

  QuizResponse({
    required this.userId,
    required this.answers,
    required this.score,
    required this.maxScore,
    required this.completedAt,
  });

  double get percentage => (score / maxScore) * 100;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'answers': answers,
      'score': score,
      'maxScore': maxScore,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory QuizResponse.fromMap(Map<String, dynamic> map) {
    return QuizResponse(
      userId: map['userId'] ?? '',
      answers: Map<int, int>.from(map['answers'] ?? {}),
      score: map['score'] ?? 0,
      maxScore: map['maxScore'] ?? 0,
      completedAt: map['completedAt'] is String
          ? DateTime.parse(map['completedAt'])
          : DateTime.now(),
    );
  }
}

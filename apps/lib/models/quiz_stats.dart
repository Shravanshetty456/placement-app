class QuizStats {
  final int totalQuizzes;
  final int totalQuestionsAttempted;
  final int totalCorrect;
  final int totalIncorrect;
  final double averageAccuracy;
  final double bestAccuracy;
  final double averageTime;

  QuizStats({
    required this.totalQuizzes,
    required this.totalQuestionsAttempted,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.averageAccuracy,
    required this.bestAccuracy,
    required this.averageTime,
  });

  factory QuizStats.fromJson(Map<String, dynamic> json) {
    return QuizStats(
      totalQuizzes: json['total_quizzes'] ?? 0,
      totalQuestionsAttempted: json['total_questions_attempted'] ?? 0,
      totalCorrect: json['total_correct'] ?? 0,
      totalIncorrect: json['total_incorrect'] ?? 0,
      averageAccuracy: (json['average_accuracy'] ?? 0).toDouble(),
      bestAccuracy: (json['best_accuracy'] ?? 0).toDouble(),
      averageTime: (json['average_time'] ?? 0).toDouble(),
    );
  }
}

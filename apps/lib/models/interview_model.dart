class InterviewResult {
  final String question;
  final String answer;
  final int score;
  final String feedback;

  InterviewResult({
    required this.question,
    required this.answer,
    required this.score,
    required this.feedback,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    'score': score,
    'feedback': feedback,
  };

  factory InterviewResult.fromJson(Map<String, dynamic> json) => InterviewResult(
    question: json['question'],
    answer: json['answer'],
    score: json['score'],
    feedback: json['feedback'],
  );
}

class InterviewSession {
  final String topic;
  final List<String> questions;
  final List<InterviewResult> results;
  final int currentIndex;
  final int totalScore;
  final DateTime startTime;

  InterviewSession({
    required this.topic,
    required this.questions,
    required this.results,
    required this.currentIndex,
    required this.totalScore,
    required this.startTime,
  });

  InterviewSession copyWith({
    String? topic,
    List<String>? questions,
    List<InterviewResult>? results,
    int? currentIndex,
    int? totalScore,
    DateTime? startTime,
  }) {
    return InterviewSession(
      topic: topic ?? this.topic,
      questions: questions ?? this.questions,
      results: results ?? this.results,
      currentIndex: currentIndex ?? this.currentIndex,
      totalScore: totalScore ?? this.totalScore,
      startTime: startTime ?? this.startTime,
    );
  }
}
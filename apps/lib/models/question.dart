class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String difficulty;
  final String? explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    required this.difficulty,
    this.explanation,
  });

  // Factory constructor to parse from API JSON
  factory Question.fromApiJson(
    Map<String, dynamic> json, {
    required String category,
  }) {
    // Decode HTML entities
    final String decodedQuestion = _decodeHtmlEntities(json['question'] ?? '');
    final String correctAnswer = _decodeHtmlEntities(
      json['correct_answer'] ?? '',
    );

    // Get incorrect answers and shuffle with correct answer
    List<String> answers = [
      ...List<String>.from(json['incorrect_answers'] ?? []),
      correctAnswer,
    ].map((ans) => _decodeHtmlEntities(ans)).toList();

    answers.shuffle();
    final correctIndex = answers.indexOf(correctAnswer);

    return Question(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      question: decodedQuestion,
      options: answers,
      correctAnswerIndex: correctIndex,
      category: category,
      difficulty: json['difficulty']?.toString().toUpperCase() ?? 'MEDIUM',
      explanation: json['explanation'],
    );
  }

  // Factory constructor to parse from local JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      category: json['category'] ?? 'General',
      difficulty: json['difficulty']?.toString().toUpperCase() ?? 'MEDIUM',
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'category': category,
      'difficulty': difficulty,
      'explanation': explanation,
    };
  }

  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#039;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&cent;', '¢')
        .replaceAll('&pound;', '£')
        .replaceAll('&yen;', '¥')
        .replaceAll('&euro;', '€');
  }

  @override
  String toString() {
    return 'Question($id, $category, $difficulty)';
  }
}

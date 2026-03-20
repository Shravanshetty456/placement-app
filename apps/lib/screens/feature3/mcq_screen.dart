import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../models/question.dart';
import '../../services/question_service.dart';

class MCQScreen extends StatefulWidget {
  const MCQScreen({super.key});

  @override
  State<MCQScreen> createState() => _MCQScreenState();
}

class _MCQScreenState extends State<MCQScreen> {
  late QuestionService _questionService;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswer;
  bool _showResults = false;
  int _totalAnswered = 0;

  // Configuration
  bool _quizStarted = false;
  bool _isLoading = false;
  String _errorMessage = '';
  int _totalQuestions = 10;
  int _totalDuration = 300;

  // Selection options
  String _selectedCategory = 'Science: Computers';
  String _selectedDifficulty = 'any';
  List<String> _categories = ['Science: Computers', 'General Knowledge', 'Science: Nature', 'Mathematics'];
  final List<String> _difficulties = ['easy', 'medium', 'hard', 'any'];

  // Timer variables
  Timer? _globalTimer;
  int _timeRemaining = 0;

  // Text controllers
  late TextEditingController _questionsController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _questionService = QuestionService();
    _questionsController = TextEditingController(text: '10');
    _durationController = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    _questionsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  /// Fetch questions from the API, with cached API questions as offline backup.
  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final questions = await _questionService.fetchQuestions(
        count: _totalQuestions,
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
      );

      if (questions.isEmpty) {
        throw Exception('No questions available for the selected criteria');
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching questions: $e');
      setState(() {
        _errorMessage = 'Failed to load questions: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _startQuiz() async {
    setState(() {
      _totalQuestions = int.tryParse(_questionsController.text) ?? 10;
      int minutes = int.tryParse(_durationController.text) ?? 5;
      _totalDuration = minutes * 60;
      _timeRemaining = _totalDuration;
    });

    await _fetchQuestions();

    if (_questions.isNotEmpty) {
      setState(() {
        _quizStarted = true;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _endQuiz();
        }
      });
    });
  }

  void _submitAnswer(int answerIndex) {
    setState(() {
      _selectedAnswer = answerIndex;
      _answered = true;
      _totalAnswered++;
      if (answerIndex == _questions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_totalAnswered >= _totalQuestions || _currentQuestionIndex + 1 >= _questions.length) {
      _endQuiz();
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _answered = false;
      _selectedAnswer = null;
    });
  }

  void _endQuiz() {
    _globalTimer?.cancel();
    setState(() {
      _showResults = true;
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = null;
      _showResults = false;
      _totalAnswered = 0;
      _quizStarted = false;
      _questions = [];
      _errorMessage = '';
    });
  }

  void _cancelQuiz() {
    _globalTimer?.cancel();
    setState(() {
      _quizStarted = false;
      _questions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    if (_showResults) {
      return _buildResultsScreen(isDarkMode);
    }

    if (!_quizStarted) {
      return _buildSetupScreen(isDarkMode);
    }

    if (_isLoading) {
      return _buildLoadingScreen(isDarkMode);
    }

    if (_errorMessage.isNotEmpty && _questions.isEmpty) {
      return _buildErrorScreen(isDarkMode);
    }

    return _buildQuizScreen(isDarkMode);
  }

  Widget _buildLoadingScreen(bool isDarkMode) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.primaryColor.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                'Loading CSE Questions...',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                'Fetching live questions from Open Trivia DB',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(bool isDarkMode) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkBackground : Colors.grey.shade50,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Questions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _startQuiz,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _restartQuiz,
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupScreen(bool isDarkMode) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSE Quiz'),
        backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkBackground : Colors.grey.shade50,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.computer,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Computer Science Quiz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Test your CSE knowledge with live questions from Open Trivia DB',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              // Category selection
              _buildDropdownField(
                label: 'Category',
                value: _selectedCategory,
                items: _categories,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                icon: Icons.category,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),
              // Difficulty selection
              _buildDropdownField(
                label: 'Difficulty',
                value: _selectedDifficulty,
                items: _difficulties,
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
                icon: Icons.auto_awesome,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),
              // Number of questions
              _buildTextField(
                controller: _questionsController,
                label: 'Number of Questions',
                suffixText: 'questions',
                icon: Icons.numbers,
                isDarkMode: isDarkMode,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Duration
              _buildTextField(
                controller: _durationController,
                label: 'Quiz Duration',
                suffixText: 'minutes',
                icon: Icons.timer,
                isDarkMode: isDarkMode,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startQuiz,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Questions are fetched online from Open Trivia Database. If the API is unavailable, recently cached online questions are used.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String suffixText,
    required IconData icon,
    required bool isDarkMode,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixText,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResultsScreen(bool isDarkMode) {
    final percentage = _totalAnswered > 0
        ? ((_score / _totalAnswered) * 100).toStringAsFixed(1)
        : '0';
    final timeTaken = _totalDuration - _timeRemaining;
    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.primaryColor.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Score',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_score / $_totalAnswered',
                        style: const TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: double.parse(percentage) / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Accuracy: $percentage%',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Time: ${minutes}:${seconds.toString().padLeft(2, '0')} min',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _restartQuiz,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Take Another Quiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizScreen(bool isDarkMode) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final minutesLeft = _timeRemaining ~/ 60;
    final secondsLeft = _timeRemaining % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CSE Quiz'),
        backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _cancelQuiz,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkBackground : Colors.grey.shade50,
        ),
        child: Column(
          children: [
            // Header with timer and progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.darkSurface : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Q${_currentQuestionIndex + 1} / $_totalQuestions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? AppTheme.darkTextLight
                              : Colors.grey.shade600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _timeRemaining <= 60
                              ? Colors.red.withOpacity(0.2)
                              : AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 16,
                              color: _timeRemaining <= 60
                                  ? Colors.red
                                  : AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$minutesLeft:${secondsLeft.toString().padLeft(2, '0')} min',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _timeRemaining <= 60
                                    ? Colors.red
                                    : AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Score: $_score',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _currentQuestionIndex / _totalQuestions,
                      backgroundColor: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _timeRemaining <= 60 ? Colors.red : AppTheme.primaryColor,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            // Question and options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentQuestion.explanation != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Category: ${currentQuestion.category} • Difficulty: ${currentQuestion.difficulty}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      currentQuestion.question,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Options
                    ...List.generate(
                      currentQuestion.options.length,
                      (index) {
                        final isSelected = _selectedAnswer == index;
                        final isCorrect = index == currentQuestion.correctAnswerIndex;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: _answered ? null : () => _submitAnswer(index),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _answered
                                    ? (isCorrect
                                        ? Colors.green.withOpacity(0.2)
                                        : (isSelected
                                            ? Colors.red.withOpacity(0.2)
                                            : (isDarkMode
                                                ? Colors.grey.shade800
                                                : Colors.white)))
                                    : (isSelected
                                        ? AppTheme.primaryColor.withOpacity(0.2)
                                        : (isDarkMode
                                            ? Colors.grey.shade800
                                            : Colors.white)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _answered
                                      ? (isCorrect
                                          ? Colors.green
                                          : (isSelected
                                              ? Colors.red
                                              : Colors.transparent))
                                      : (isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.transparent),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _answered
                                            ? (isCorrect
                                                ? Colors.green
                                                : (isSelected
                                                    ? Colors.red
                                                    : (isDarkMode
                                                        ? Colors.grey.shade600
                                                        : Colors.grey.shade400)))
                                            : (isSelected
                                                ? AppTheme.primaryColor
                                                : (isDarkMode
                                                    ? Colors.grey.shade600
                                                    : Colors.grey.shade400)),
                                        width: 2,
                                      ),
                                      color: _answered
                                          ? (isCorrect
                                              ? Colors.green
                                              : (isSelected
                                                  ? Colors.red
                                                  : Colors.transparent))
                                          : (isSelected
                                              ? AppTheme.primaryColor
                                              : Colors.transparent),
                                    ),
                                    child: _answered && isCorrect
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : _answered && isSelected && !isCorrect
                                            ? const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      currentQuestion.options[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.grey.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (_answered && currentQuestion.explanation != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explanation',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade400,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentQuestion.explanation!,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Next button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _answered ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _totalAnswered >= _totalQuestions - 1 ? 'Finish Quiz' : 'Next Question',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

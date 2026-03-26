import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';

class QuestionService {
  static const String _apiBaseUrl = 'https://opentdb.com/api.php';
  static const String _cacheKey = 'mcq_questions_cache';
  static const String _lastCacheTimeKey = 'mcq_cache_time';
  static const int _cacheDurationHours = 24;
  static const int _questionsPerBatch = 10;

  final http.Client _httpClient;

  QuestionService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  // Category mapping for Open Trivia Database
  static const Map<String, int> categoryIds = {
    'General Knowledge': 9,
    'Science: Computers': 18,
    'Science: Nature': 17,
    'Science: Biology': 17,
    'Mathematics': 19,
  };

  /// Fetch questions from the API, and fall back to cached API results only.
  Future<List<Question>> fetchQuestions({
    required int count,
    String category = 'Science: Computers',
    String difficulty = 'any',
  }) async {
    try {
      final questions = await _fetchFromApi(
        count: count,
        category: category,
        difficulty: difficulty,
      );
      await cacheQuestions(questions);
      return questions;
    } catch (e) {
      print('Failed to fetch from API: $e. Trying cached questions.');
      final cachedQuestions = await getCachedQuestions(
        count: count,
        category: category,
        difficulty: difficulty,
      );
      if (cachedQuestions != null && cachedQuestions.isNotEmpty) {
        return cachedQuestions;
      }
      throw Exception(
        'Unable to load online questions right now. Please check your connection and try again.',
      );
    }
  }

  /// Fetch from Open Trivia Database API
  Future<List<Question>> _fetchFromApi({
    required int count,
    required String category,
    required String difficulty,
  }) async {
    final categoryId =
        categoryIds[category] ?? 18; // Default to Computers if not found

    // Fetch in batches to ensure we get enough questions
    final batchCount =
        ((count / _questionsPerBatch).ceil()) * _questionsPerBatch;

    final queryParams = {
      'amount': batchCount.toString(),
      'category': categoryId.toString(),
      'type': 'multiple',
    };

    if (difficulty.toLowerCase() != 'any') {
      queryParams['difficulty'] = difficulty.toLowerCase();
    }

    final uri = Uri.parse(_apiBaseUrl).replace(queryParameters: queryParams);

    final response = await _httpClient
        .get(uri)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('API request timed out'),
        );

    if (response.statusCode != 200) {
      throw Exception('API request failed with status ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    if (data['response_code'] != 0) {
      throw Exception('API returned response code: ${data['response_code']}');
    }

    final results = List<Map<String, dynamic>>.from(data['results'] ?? []);

    if (results.isEmpty) {
      throw Exception('No questions available for the selected criteria');
    }

    List<Question> questions = results
        .map((q) => Question.fromApiJson(q, category: category))
        .toList();

    // Return the requested count
    return questions.take(count).toList();
  }

  /// Cache questions locally
  Future<void> cacheQuestions(List<Question> questions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questionsJson = questions.map((q) => q.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(questionsJson));
      await prefs.setInt(
        _lastCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Failed to cache questions: $e');
    }
  }

  /// Get cached questions
  Future<List<Question>?> getCachedQuestions({
    int? count,
    String? category,
    String? difficulty,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTime = prefs.getInt(_lastCacheTimeKey) ?? 0;

      // Check if cache is still valid
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - cacheTime > _cacheDurationHours * 60 * 60 * 1000) {
        return null; // Cache expired
      }

      final questionsJson = prefs.getString(_cacheKey);
      if (questionsJson == null) return null;

      final decoded = List<Map<String, dynamic>>.from(
        jsonDecode(questionsJson),
      );
      var questions = decoded.map((q) => Question.fromJson(q)).toList();

      if (category != null) {
        questions = questions.where((q) => q.category == category).toList();
      }

      if (difficulty != null && difficulty.toLowerCase() != 'any') {
        questions = questions
            .where(
              (q) => q.difficulty.toLowerCase() == difficulty.toLowerCase(),
            )
            .toList();
      }

      if (count != null) {
        questions = questions.take(count).toList();
      }

      return questions;
    } catch (e) {
      print('Failed to retrieve cached questions: $e');
      return null;
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastCacheTimeKey);
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}

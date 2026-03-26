import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apps/services/auth_service.dart';
import '../config/api_config.dart';
import '../models/quiz_stats.dart';

class QuizService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Get auth token
  static String? _getToken() {
    return AuthService.authToken;
  }

  // Save quiz result
  static Future<bool> saveQuizResult({
    required int score,
    required int totalQuestions,
    required int timeTaken,
  }) async {
    try {
      final token = _getToken();

      print(
        'Saving quiz result: score=$score, total=$totalQuestions, time=$timeTaken',
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/quiz/results'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'score': score,
              'total_questions': totalQuestions,
              'time_taken': timeTaken,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Save quiz result response: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error saving quiz result: $e');
      return false;
    }
  }

  // Get quiz stats
  static Future<QuizStats?> getStats() async {
    try {
      final token = _getToken();

      print('Fetching quiz stats');

      final response = await http
          .get(
            Uri.parse('$baseUrl/quiz/stats'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print(
        'Get quiz stats response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return QuizStats.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching quiz stats: $e');
      return null;
    }
  }
}

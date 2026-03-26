import 'dart:convert';
import 'package:http/http.dart' as http;
import 'env_service.dart';

class InterviewService {
  static const String groqUrl = "https://api.groq.com/openai/v1/chat/completions";
  static const String model = "llama-3.1-8b-instant";

  static String get _groqApiKey => EnvService.groqApiKey;

  static Future<List<String>> generateQuestions(String topic) async {
    try {
      final response = await http.post(
        Uri.parse(groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': 'You are a senior technical interviewer. Generate exactly 5 interview questions for the topic: "$topic". Return ONLY a JSON array of 5 strings, no extra text, no markdown, no numbering. Example: ["Question 1?","Question 2?","Question 3?","Question 4?","Question 5?"]'
            }
          ],
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        try {
          String cleaned = content.replaceAll('```json', '').replaceAll('```', '').trim();
          List<dynamic> questionsList = jsonDecode(cleaned);
          return questionsList.cast<String>();
        } catch (e) {
          RegExp regex = RegExp(r'"([^"]+\?)"');
          Iterable<Match> matches = regex.allMatches(content);
          List<String> questions = matches.map((m) => m.group(1)!).take(5).toList();
          if (questions.isEmpty) {
            return _getFallbackQuestions(topic);
          }
          return questions;
        }
      } else {
        throw Exception('Failed to generate questions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating questions: $e');
      return _getFallbackQuestions(topic);
    }
  }

  static Future<Map<String, dynamic>> evaluateAnswer({
    required String topic,
    required String question,
    required String answer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'user',
              'content': 'You are a strict but fair technical interviewer evaluating an interview answer.\n\nTopic: $topic\nQuestion: $question\nCandidate\'s Answer: $answer\n\nEvaluate the answer and respond ONLY with valid JSON, no markdown, no extra text:\n{\n  "score": <integer 0-10>,\n  "feedback": "<2-3 sentence constructive feedback explaining the score, what was good and what was missing>"\n}'
            }
          ],
          'max_tokens': 400,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        try {
          String cleaned = content.replaceAll('```json', '').replaceAll('```', '').trim();
          Map<String, dynamic> result = jsonDecode(cleaned);
          int score = (result['score'] as num).clamp(0, 10).toInt();
          String feedback = result['feedback'] ?? 'No feedback available.';
          return {'score': score, 'feedback': feedback};
        } catch (e) {
          RegExp scoreRegex = RegExp(r'"score"\s*:\s*(\d+)');
          RegExp fbRegex = RegExp(r'"feedback"\s*:\s*"([^"]+)"');
          
          int score = 5;
          String feedback = 'Could not parse detailed feedback.';
          
          var scoreMatch = scoreRegex.firstMatch(content);
          if (scoreMatch != null) {
            score = int.parse(scoreMatch.group(1)!).clamp(0, 10);
          }
          
          var fbMatch = fbRegex.firstMatch(content);
          if (fbMatch != null) {
            feedback = fbMatch.group(1)!;
          }
          
          return {'score': score, 'feedback': feedback};
        }
      } else {
        return {'score': 5, 'feedback': 'Unable to evaluate. Please try again.'};
      }
    } catch (e) {
      print('Error evaluating answer: $e');
      return {'score': 5, 'feedback': 'Network error. Please check your connection.'};
    }
  }

  static List<String> _getFallbackQuestions(String topic) {
    return [
      'What is $topic and why is it important in modern development?',
      'Explain the core concepts and best practices in $topic.',
      'How would you optimize performance in a $topic application?',
      'What are common challenges when working with $topic and how do you overcome them?',
      'Describe a real-world scenario where you implemented $topic successfully.',
    ];
  }
}
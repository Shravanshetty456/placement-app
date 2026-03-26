import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InterviewProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _interviewHistory = [];
  int _totalInterviews = 0;
  double _averageScore = 0.0;

  List<Map<String, dynamic>> get interviewHistory => _interviewHistory;
  int get totalInterviews => _totalInterviews;
  double get averageScore => _averageScore;

  InterviewProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('interview_history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _interviewHistory = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      _updateStats();
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('interview_history', jsonEncode(_interviewHistory));
  }

  void addInterviewResult({
    required String topic,
    required int totalScore,
    required int maxScore,
    required List<Map<String, dynamic>> results,
  }) {
    final interview = {
      'topic': topic,
      'totalScore': totalScore,
      'maxScore': maxScore,
      'percentage': (totalScore / maxScore * 100),
      'results': results,
      'date': DateTime.now().toIso8601String(),
    };

    _interviewHistory.insert(0, interview);
    _updateStats();
    _saveHistory();
    notifyListeners();
  }

  void _updateStats() {
    _totalInterviews = _interviewHistory.length;
    if (_interviewHistory.isEmpty) {
      _averageScore = 0.0;
      return;
    }

    double total = 0;
    for (var interview in _interviewHistory) {
      total += interview['percentage'];
    }
    _averageScore = total / _interviewHistory.length;
  }

  Future<void> clearHistory() async {
    _interviewHistory.clear();
    _updateStats();
    await _saveHistory();
    notifyListeners();
  }

  List<Map<String, dynamic>> getInterviewsByTopic(String topic) {
    return _interviewHistory
        .where((interview) =>
            interview['topic'].toLowerCase().contains(topic.toLowerCase()))
        .toList();
  }

  List<Map<String, dynamic>> getRecentInterviews({int limit = 5}) {
    return _interviewHistory.take(limit).toList();
  }
}
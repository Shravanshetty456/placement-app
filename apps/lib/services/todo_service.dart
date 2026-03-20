import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apps/services/auth_service.dart';

class TodoTask {
  final int? id;
  final int userId;
  final String title;
  final int? startHour;
  final int? startMinute;
  final int durationMinutes;
  bool isCompleted;

  TodoTask({
    this.id,
    required this.userId,
    required this.title,
    this.startHour,
    this.startMinute,
    this.durationMinutes = 0,
    this.isCompleted = false,
  });

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'start_hour': startHour,
      'start_minute': startMinute,
      'duration_minutes': durationMinutes,
      'is_completed': isCompleted,
    };
  }

  // Create from JSON
  factory TodoTask.fromJson(Map<String, dynamic> json) {
    return TodoTask(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      startHour: json['start_hour'],
      startMinute: json['start_minute'],
      durationMinutes: json['duration_minutes'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

class TodoService {
  static const String baseUrl = 'http://172.50.7.73:3000'; // Use your actual IP

  // Get auth token
  static String? _getToken() {
    return AuthService.authToken;
  }

  // Get all todos for current user
  static Future<List<TodoTask>> getTodos() async {
    try {
      final token = _getToken();
      final userId = AuthService.currentUser?['id'];
      
      if (userId == null) {
        print('No user ID found');
        return [];
      }

      print('Fetching todos for user: $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/todos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Get todos response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> todosJson = jsonDecode(response.body);
        return todosJson.map((json) => TodoTask.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching todos: $e');
      return [];
    }
  }

  // Create a new todo
  static Future<TodoTask?> createTodo(TodoTask todo) async {
    try {
      final token = _getToken();
      
      print('Creating todo: ${todo.toJson()}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': todo.title,
          'start_hour': todo.startHour,
          'start_minute': todo.startMinute,
          'duration_minutes': todo.durationMinutes,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Create todo response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TodoTask.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error creating todo: $e');
      return null;
    }
  }

  // Update a todo (KEEP THIS METHOD - TodoScreen uses it)
  static Future<TodoTask?> updateTodo(TodoTask todo) async {
    try {
      if (todo.id == null) return null;
      
      final token = _getToken();

      print('Attempting to update todo: ${todo.id}');
      
      final response = await http.put(
        Uri.parse('$baseUrl/todos/${todo.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': todo.title,
          'start_hour': todo.startHour,
          'start_minute': todo.startMinute,
          'duration_minutes': todo.durationMinutes,
          'is_completed': todo.isCompleted,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Update todo response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TodoTask.fromJson(data);
      } else {
        // If PUT fails, try to create a new one or toggle
        print('Update failed with status: ${response.statusCode}');
        // Return null but don't throw error
        return null;
      }
    } catch (e) {
      print('Error updating todo: $e');
      return null;
    }
  }

  // Toggle todo completion
  static Future<TodoTask?> toggleTodo(int todoId) async {
    try {
      final token = _getToken();

      print('Toggling todo: $todoId');
      
      final response = await http.patch(
        Uri.parse('$baseUrl/todos/$todoId/toggle'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Toggle todo response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TodoTask.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error toggling todo: $e');
      return null;
    }
  }

  // Delete a todo
  static Future<bool> deleteTodo(int todoId) async {
    try {
      final token = _getToken();

      print('Deleting todo: $todoId');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/todos/$todoId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Delete todo response: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting todo: $e');
      return false;
    }
  }
}
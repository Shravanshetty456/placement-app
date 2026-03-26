import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;
  
  // Store current user data
  static Map<String, dynamic>? _currentUser;
  
  // Store auth token
  static String? _authToken;
  
  // Get current user
  static Map<String, dynamic>? get currentUser => _currentUser;
  
  // Get auth token
  static String? get authToken => _authToken;
  
  // Check if user is logged in
  static bool get isLoggedIn => _currentUser != null;
  
  // Get user name
  static String get userName => _currentUser?['name'] ?? 'User';
  
  // Get user email
  static String get userEmail => _currentUser?['email'] ?? '';
  
  // Get user id
  static int? get userId => _currentUser?['id'];
  
  // Get user initials
  static String get userInitials {
    if (_currentUser == null || _currentUser!['name'] == null) return 'U';
    String name = _currentUser!['name'];
    if (name.isEmpty) return 'U';
    
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return nameParts[0][0] + nameParts[1][0];
    } else {
      return name[0].toUpperCase();
    }
  }

  // SIGN UP
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting signup to: $baseUrl/signup');
      
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Signup response status: ${response.statusCode}');
      print('Signup response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Store user data
        _currentUser = data['user'];
        // Store token
        _authToken = data['token'];
        
        return {
          'success': true,
          'message': 'Signup successful',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      print('Signup error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // SIGN IN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login to: $baseUrl/signin');
      
      final response = await http.post(
        Uri.parse('$baseUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Store user data
        _currentUser = data['user'];
        // Store token
        _authToken = data['token'];
        
        return {
          'success': true,
          'message': 'Login successful',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
  
  // LOGOUT
  static void logout() {
    _currentUser = null;
    _authToken = null;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

/// 🔐 **Authentication Service**
/// 
/// Handles user authentication for the web application
class AuthService {
  static const String _tag = 'AuthService';

  /// Login user with phone number and password
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      print('$_tag: Attempting login for phone: $phone');
      print('$_tag: Using login URL: ${ApiConfig.loginUrl}');
      print('$_tag: Base URL: ${ApiConfig.baseUrl}');
      
      final client = http.Client();
      try {
        final response = await client.post(
          Uri.parse(ApiConfig.loginUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'phone_number': phone,
            'password': password,
          }),
        ).timeout(const Duration(seconds: 30));

        print('$_tag: Login response status: ${response.statusCode}');
        print('$_tag: Login response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message'] ?? 'Login successful',
            'user_id': data['user_id'],
          };
        } else {
          try {
            final errorData = jsonDecode(response.body);
            return {
              'success': false,
              'message': errorData['detail'] ?? 'Login failed',
            };
          } catch (e) {
            return {
              'success': false,
              'message': 'Login failed with status ${response.statusCode}',
            };
          }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print('$_tag: Login error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Register new user
  static Future<Map<String, dynamic>> register(String phone, String password) async {
    try {
      print('$_tag: Attempting registration for phone: $phone');
      print('$_tag: Using register URL: ${ApiConfig.registerUrl}');
      print('$_tag: Base URL: ${ApiConfig.baseUrl}');
      
      final client = http.Client();
      try {
        final response = await client.post(
          Uri.parse(ApiConfig.registerUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'phone_number': phone,
            'password': password,
          }),
        ).timeout(const Duration(seconds: 30));

        print('$_tag: Registration response status: ${response.statusCode}');
        print('$_tag: Registration response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'message': data['message'] ?? 'Registration successful',
            'user_id': data['user_id'],
          };
        } else {
          try {
            final errorData = jsonDecode(response.body);
            return {
              'success': false,
              'message': errorData['detail'] ?? 'Registration failed',
            };
          } catch (e) {
            return {
              'success': false,
              'message': 'Registration failed with status ${response.statusCode}',
            };
          }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print('$_tag: Registration error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Sign in with Google (placeholder)
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    // This is a placeholder implementation
    // In a real app, you would integrate with Google Sign-In
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': false,
      'message': 'Google Sign-In not implemented yet',
    };
  }

  /// Logout user
  static Future<void> logout() async {
    // Clear any stored tokens or user data
    // In a real app, you would clear tokens from storage
    print('$_tag: User logged out');
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    // Check if user has valid session/token
    // In a real app, you would check stored tokens
    return false;
  }

  /// Get current user info
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    // Return current user information
    // In a real app, you would get this from storage or API
    return null;
  }
}
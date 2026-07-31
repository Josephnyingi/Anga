import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../utils/app_state.dart';

/// 🤖 **AI Assistant Service**
///
/// Handles AI assistant interactions for the web application
class AIAssistantService {
  static const String _tag = 'AIAssistantService';

  /// Ask the AI assistant a question. Personalized with the farmer's
  /// registered livestock when AppState.phoneNumber is set.
  static Future<String> askAssistant({
    required String prompt,
    String useCase = 'Smart Farming Advice',
  }) async {
    try {
      print('$_tag: Asking AI assistant: $prompt');

      final response = await http.post(
        Uri.parse(ApiConfig.aiAssistantUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'query': prompt,
          'use_case': useCase,
          if (AppState.phoneNumber.isNotEmpty) 'phone_number': AppState.phoneNumber,
        }),
      ).timeout(ApiConfig.timeout);

      print('$_tag: AI response status: ${response.statusCode}');
      print('$_tag: AI response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] ?? 'No response from AI assistant';
      } else {
        final errorData = jsonDecode(response.body);
        return 'Error: ${errorData['detail'] ?? 'Failed to get AI response'}';
      }
    } catch (e) {
      print('$_tag: AI assistant error: $e');
      return 'Error: Network error - $e';
    }
  }

  /// Get available use cases for the AI assistant
  static Future<List<String>> getUseCases() async {
    try {
      print('$_tag: Getting AI use cases');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/assistant/use-cases'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);

      print('$_tag: Use cases response status: ${response.statusCode}');
      print('$_tag: Use cases response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['use_cases'] ?? []);
      } else {
        return ['Smart Farming Advice']; // Default use case
      }
    } catch (e) {
      print('$_tag: Error getting use cases: $e');
      return ['Smart Farming Advice']; // Default use case
    }
  }

  /// Get AI assistant status
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      print('$_tag: Getting AI assistant status');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/assistant/status'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);

      print('$_tag: Status response status: ${response.statusCode}');
      print('$_tag: Status response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Failed to get AI assistant status',
        };
      }
    } catch (e) {
      print('$_tag: Error getting status: $e');
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class AIAssistantService {
  /// Ask the AI assistant a question
  static Future<String> askAssistant({
    required String prompt,
    String useCase = "Smart Farming Advice",
  }) async {
    final url = Uri.parse(ApiConfig.aiAssistantUrl);
    
    ApiConfig.debugPrint("Sending AI assistant request to: $url");

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          "query": prompt,
          "use_case": useCase,
        }),
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ApiConfig.debugPrint("AI assistant response received successfully");
        return data['answer'] ?? "🤖 No response from assistant.";
      } else {
        ApiConfig.debugPrint("AI assistant API error: ${response.statusCode}");
        throw Exception(
            "❌ Failed with status ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      ApiConfig.debugPrint("AI assistant network error: $e");
      throw Exception("⚠️ Network/Server error: ${e.toString()}");
    }
  }

  /// Get available use cases for the AI assistant
  static Future<Map<String, String>> getUseCases() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/assistant/use-cases');
    
    ApiConfig.debugPrint("Fetching AI assistant use cases from: $url");

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ApiConfig.debugPrint("AI assistant use cases received successfully");
        return Map<String, String>.from(data['use_cases'] ?? {});
      } else {
        ApiConfig.debugPrint("AI assistant use cases API error: ${response.statusCode}");
        throw Exception(
            "❌ Failed to get use cases: ${response.statusCode}");
      }
    } catch (e) {
      ApiConfig.debugPrint("AI assistant use cases network error: $e");
      throw Exception("⚠️ Network/Server error: ${e.toString()}");
    }
  }

  /// Get AI assistant status
  static Future<Map<String, dynamic>> getStatus() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/assistant/status');
    
    ApiConfig.debugPrint("Fetching AI assistant status from: $url");

    try {
      final response = await http.get(
        url,
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ApiConfig.debugPrint("AI assistant status received successfully");
        return Map<String, dynamic>.from(data);
      } else {
        ApiConfig.debugPrint("AI assistant status API error: ${response.statusCode}");
        throw Exception(
            "❌ Failed to get status: ${response.statusCode}");
      }
    } catch (e) {
      ApiConfig.debugPrint("AI assistant status network error: $e");
      throw Exception("⚠️ Network/Server error: ${e.toString()}");
    }
  }

  /// Test AI assistant connectivity
  static Future<bool> testConnectivity() async {
    try {
      final status = await getStatus();
      final isWorking = status['status'] == 'working';
      ApiConfig.debugPrint("AI assistant connectivity test: ${isWorking ? 'PASS' : 'FAIL'}");
      return isWorking;
    } catch (e) {
      ApiConfig.debugPrint("AI assistant connectivity test failed: $e");
      return false;
    }
  }

  /// Get default use cases (fallback if API is not available)
  static Map<String, String> getDefaultUseCases() {
    return {
      "Smart Farming Advice": "General farming advice and best practices",
      "Weather-Based Farming": "Weather-dependent farming decisions",
      "Crop Management": "Crop-specific advice and management",
      "Sustainable Agriculture": "Environmentally friendly farming practices",
      "Emergency Weather Response": "Emergency response for weather crises"
    };
  }
}

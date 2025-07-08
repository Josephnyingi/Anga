import 'dart:convert';
import 'package:http/http.dart' as http;

class AIAssistantService {
  // ⚠️ Replace this with your local IP address if testing on emulator or device
  static const String _baseUrl = 'http://127.0.0.1:8000'; // Update for production

  static Future<String> askAssistant({
    required String prompt,
    String useCase = "Smart Farming Advice",
  }) async {
    final url = Uri.parse('$_baseUrl/ask');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "query": prompt,
          "use_case": useCase,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] ?? "🤖 No response from assistant.";
      } else {
        throw Exception(
            "❌ Failed with status ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("⚠️ Network/Server error: ${e.toString()}");
    }
  }
}

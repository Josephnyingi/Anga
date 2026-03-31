// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class WeatherService {
  /// Fetch weather prediction using /predict/ endpoint
  static Future<Map<String, dynamic>> getWeather(String date, String location) async {
    ApiConfig.debugPrint("Fetching weather for $date at $location");

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.weatherPredictUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({"date": date, "location": location}),
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ApiConfig.debugPrint("Weather data received successfully");
        return data;
      } else {
        ApiConfig.debugPrint("Weather API Error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to fetch weather data: ${response.statusCode}");
      }
    } catch (e) {
      ApiConfig.debugPrint("Weather network error: $e");
      throw Exception("Network error: $e");
    }
  }

  /// Get supported locations
  static List<String> getSupportedLocations() {
    return ['machakos', 'vhembe'];
  }

  /// Validate location
  static bool isValidLocation(String location) {
    return getSupportedLocations().contains(location.toLowerCase());
  }

  /// Format date for API
  static String formatDateForApi(DateTime date) {
    return date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
  }

  /// Parse date from API response
  static DateTime parseDateFromApi(String dateString) {
    return DateTime.parse(dateString);
  }
}

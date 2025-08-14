// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io'; // 👈 For platform check
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import 'models/weather_forecast.dart';

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

  /// Fetch weather forecast using the new model
  static Future<WeatherForecastModel?> getWeatherForecast(String date, String location) async {
    ApiConfig.debugPrint("Fetching weather forecast for $date at $location");

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.weatherPredictUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({"date": date, "location": location}),
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ApiConfig.debugPrint("Weather forecast received successfully");
        return WeatherForecastModel.fromJson(data);
      } else {
        ApiConfig.debugPrint("Weather forecast API Error: ${response.statusCode} - ${response.body}");
        return WeatherForecastModel(
          source: 'error',
          date: date,
          location: location,
          temperaturePrediction: 0.0,
          rainPrediction: 0.0,
          error: "API Error: ${response.statusCode}",
        );
      }
    } catch (e) {
      ApiConfig.debugPrint("Weather forecast network error: $e");
      return WeatherForecastModel(
        source: 'error',
        date: date,
        location: location,
        temperaturePrediction: 0.0,
        rainPrediction: 0.0,
        error: "Network error: $e",
      );
    }
  }

  /// Fetch live weather using the new model
  static Future<WeatherForecastModel?> getLiveWeatherForecast(String location) async {
    ApiConfig.debugPrint("Fetching live weather forecast for $location");

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.liveWeatherUrl}?location=$location"),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ApiConfig.debugPrint("Live weather forecast received successfully");
        return WeatherForecastModel.fromLiveWeather(data);
      } else {
        ApiConfig.debugPrint("Live weather API Error: ${response.statusCode} - ${response.body}");
        return WeatherForecastModel(
          source: 'error',
          date: DateTime.now().toIso8601String().split('T')[0],
          location: location,
          temperaturePrediction: 0.0,
          rainPrediction: 0.0,
          error: "API Error: ${response.statusCode}",
        );
      }
    } catch (e) {
      ApiConfig.debugPrint("Live weather network error: $e");
      return WeatherForecastModel(
        source: 'error',
        date: DateTime.now().toIso8601String().split('T')[0],
        location: location,
        temperaturePrediction: 0.0,
        rainPrediction: 0.0,
        error: "Network error: $e",
      );
    }
  }

  /// Fetch multiple days of weather data (batch operation)
  static Future<List<WeatherForecastModel>> getWeatherForecastBatch(
    List<String> dates, 
    String location
  ) async {
    ApiConfig.debugPrint("Fetching batch weather forecast for ${dates.length} dates at $location");
    
    List<WeatherForecastModel> forecasts = [];
    
    for (String date in dates) {
      try {
        final forecast = await getWeatherForecast(date, location);
        if (forecast != null) {
          forecasts.add(forecast);
        }
      } catch (e) {
        ApiConfig.debugPrint("Error fetching forecast for $date: $e");
        forecasts.add(WeatherForecastModel(
          source: 'error',
          date: date,
          location: location,
          temperaturePrediction: 0.0,
          rainPrediction: 0.0,
          error: "Failed to fetch: $e",
        ));
      }
    }
    
    return forecasts;
  }

  /// Save weather prediction to database
  static Future<bool> savePrediction(
    String date, 
    String location, 
    double temperature, 
    double rain
  ) async {
    ApiConfig.debugPrint("Saving weather prediction for $date at $location");

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.savePredictionUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          "date": date,
          "location": location,
          "temperature": temperature,
          "rain": rain,
        }),
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        ApiConfig.debugPrint("Weather prediction saved successfully");
        return true;
      } else {
        ApiConfig.debugPrint("Save prediction API Error: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      ApiConfig.debugPrint("Save prediction network error: $e");
      return false;
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

// Keep the old WeatherForecast class for backward compatibility
class WeatherForecast {
  final String source;
  final String date;
  final String location;
  final double temperaturePrediction;
  final double rainPrediction;

  WeatherForecast({
    required this.source,
    required this.date,
    required this.location,
    required this.temperaturePrediction,
    required this.rainPrediction,
  });

  static WeatherForecast fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      source: json['source'] ?? 'unknown',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      temperaturePrediction: (json['temperature_prediction'] ?? 0.0).toDouble(),
      rainPrediction: (json['rain_prediction'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'date': date,
      'location': location,
      'temperature_prediction': temperaturePrediction,
      'rain_prediction': rainPrediction,
    };
  }
}

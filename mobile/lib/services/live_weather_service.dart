import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class WeatherException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  WeatherException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'WeatherException: $message${details != null ? ' - $details' : ''}';
}

class LiveWeatherService {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  static Future<Map<String, dynamic>> getLiveWeather(String location) async {
    if (location.trim().isEmpty) {
      throw WeatherException('Location cannot be empty');
    }

    final url = Uri.parse('${ApiConfig.liveWeatherUrl}?location=${Uri.encodeComponent(location)}');
    
    ApiConfig.debugPrint("Fetching live weather from: $url");
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final response = await http.get(
          url,
          headers: ApiConfig.defaultHeaders,
        ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

        if (response.statusCode == 200) {
          try {
            final decoded = json.decode(response.body);
            ApiConfig.debugPrint("Live weather data received successfully");
            return decoded;
          } catch (e) {
            throw WeatherException(
              'Invalid JSON response from weather API',
              statusCode: response.statusCode,
              details: 'JSON decode error: $e'
            );
          }
        } else if (response.statusCode == 404) {
          throw WeatherException(
            'Location not found',
            statusCode: response.statusCode,
            details: 'Weather data not available for: $location'
          );
        } else if (response.statusCode == 429) {
          throw WeatherException(
            'API rate limit exceeded',
            statusCode: response.statusCode,
            details: 'Too many requests. Please try again later.'
          );
        } else if (response.statusCode >= 500) {
          throw WeatherException(
            'Weather service temporarily unavailable',
            statusCode: response.statusCode,
            details: 'Server error: ${response.statusCode}'
          );
        } else {
          throw WeatherException(
            'Failed to fetch weather data',
            statusCode: response.statusCode,
            details: 'HTTP ${response.statusCode}: ${response.reasonPhrase}'
          );
        }
      } catch (e) {
        if (e is WeatherException) {
          // Don't retry for client errors (4xx)
          if (e.statusCode != null && e.statusCode! >= 400 && e.statusCode! < 500) {
            rethrow;
          }
        }
        
        if (attempt == _maxRetries) {
          if (e is WeatherException) {
            rethrow;
          } else {
            throw WeatherException(
              'Network error after $_maxRetries attempts',
              details: 'Last error: $e'
            );
          }
        }
        
        ApiConfig.debugPrint("Attempt $attempt failed: $e. Retrying in ${_retryDelay.inSeconds} seconds...");
        await Future.delayed(_retryDelay);
      }
    }
    
    throw WeatherException('Unexpected error in weather service');
  }

  static Future<Map<String, dynamic>> getWeatherForecast(String location) async {
    if (location.trim().isEmpty) {
      throw WeatherException('Location cannot be empty');
    }

    final url = Uri.parse('${ApiConfig.forecastUrl}?location=${Uri.encodeComponent(location)}');
    
    ApiConfig.debugPrint("Fetching weather forecast from: $url");
    
    try {
      final response = await http.get(
        url,
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        try {
          final decoded = json.decode(response.body);
          ApiConfig.debugPrint("Weather forecast data received successfully");
          return decoded;
        } catch (e) {
          throw WeatherException(
            'Invalid JSON response from forecast API',
            statusCode: response.statusCode,
            details: 'JSON decode error: $e'
          );
        }
      } else {
        throw WeatherException(
          'Failed to fetch forecast data',
          statusCode: response.statusCode,
          details: 'HTTP ${response.statusCode}: ${response.reasonPhrase}'
        );
      }
    } catch (e) {
      if (e is WeatherException) {
        rethrow;
      }
      throw WeatherException(
        'Network error while fetching forecast',
        details: 'Error: $e'
      );
    }
  }
}

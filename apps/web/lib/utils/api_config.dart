import 'dart:io';
import 'package:flutter/foundation.dart';
import 'environment_config.dart';

/// 🌐 **Web-Specific API Configuration**
/// 
/// This file ensures the web app uses consistent API settings and makes it easy
/// to switch between development and production environments.
/// 
/// **Web Platform Detection:**
/// - Web Browser: Uses same-origin '/api' proxy
/// - Development: Uses localhost:8000 (backend running locally)
/// - Production: Uses configured production URL
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Get the base URL based on the current environment
  static String get baseUrl {
    // For web platform, go through same-origin nginx proxy
    if (kIsWeb) {
      const url = '/api';
      debugPrint("🌐 Web platform detected - using same-origin proxy URL: $url");
      return url;
    }
    
    // For other platforms, use environment configuration
    final url = EnvironmentConfig.baseUrl;
    debugPrint("🌐 Platform detected - using URL: $url");
    return url;
  }

  /// Get platform information for debugging
  static String get platformInfo {
    return '''
🌐 Web Platform Information:
   Platform: Web Browser
   Environment: ${EnvironmentConfig.environmentName}
   Base URL: $baseUrl
   User Agent: ${kIsWeb ? 'Web Browser' : 'Unknown'}
''';
  }

  /// Weather prediction endpoint
  static String get weatherPredictUrl => "$baseUrl/predict/";
  
  /// Live weather endpoint
  static String get liveWeatherUrl => "$baseUrl/live_weather/";
  
  /// Weather forecast endpoint
  static String get forecastUrl => "$baseUrl/forecast/";
  
  /// AI Assistant endpoint
  static String get aiAssistantUrl => "$baseUrl/assistant/ask";

  /// Early-warning alerts endpoint
  static String get alertsUrl => "$baseUrl/alerts/";
  
  /// Health check endpoint
  static String get healthCheckUrl => "$baseUrl/health";
  
  /// User authentication endpoints
  static String get loginUrl => "$baseUrl/login/";
  static String get registerUrl => "$baseUrl/users/";
  
  /// Save prediction endpoint
  static String get savePredictionUrl => "$baseUrl/save_prediction/";

  /// Headers for API requests
  static Map<String, String> get defaultHeaders => {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "User-Agent": "ANGA-Weather-Web/1.0.0",
    if (EnvironmentConfig.weatherApiKey.isNotEmpty)
      "X-API-Key": EnvironmentConfig.weatherApiKey,
  };

  /// Timeout duration for API requests
  static Duration get timeout {
    // Increase timeout for development to handle slower connections
    if (EnvironmentConfig.environment == Environment.development) {
      return const Duration(seconds: 30); // 30 seconds for web development
    }
    return EnvironmentConfig.networkTimeout;
  }

  /// Timeout duration for API requests (in seconds) - for backward compatibility
  static int get timeoutSeconds => timeout.inSeconds;

  /// Debug mode based on environment
  static bool get debugMode => EnvironmentConfig.enableDebugMode;

  /// Print debug information if debug mode is enabled
  static void debugPrint(String message) {
    if (debugMode && EnvironmentConfig.enableLogging) {
      print("🔧 [Web API Config] $message");
    }
  }

  /// Print error information
  static void errorPrint(String message) {
    if (EnvironmentConfig.enableLogging) {
      print("❌ [Web API Config] $message");
    }
  }

  /// Print detailed platform and configuration information
  static void printConfigurationDetails() {
    if (!debugMode) return;
    
    print("🔧 [Web API Config] Configuration Details:");
    print("   Environment: ${EnvironmentConfig.environmentName}");
    print("   Platform: Web Browser");
    print("   Base URL: $baseUrl");
    print("   All endpoints:");
    allEndpoints.forEach((name, url) {
      print("     $name: $url");
    });
    print("   Platform Info:");
    print(platformInfo);
  }

  /// Test connectivity to the backend
  static Future<bool> testBackendConnectivity() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(healthCheckUrl));
      final response = await request.close().timeout(const Duration(seconds: 5));
      client.close();
      
      final success = response.statusCode == 200;
      debugPrint("Backend connectivity test: ${success ? '✅ SUCCESS' : '❌ FAILED'} (Status: ${response.statusCode})");
      return success;
    } catch (e) {
      errorPrint("Backend connectivity test: ❌ FAILED - $e");
      return false;
    }
  }

  /// Get current configuration info
  static String get configInfo {
    return '''
🌐 Web API Configuration:
   Environment: ${EnvironmentConfig.environmentName}
   Base URL: $baseUrl
   Platform: Web Browser
   Debug Mode: $debugMode
   Timeout: ${timeoutSeconds}s
   Logging: ${EnvironmentConfig.enableLogging}
''';
  }

  /// Get all available endpoints for testing
  static Map<String, String> get allEndpoints {
    return {
      'Health Check': healthCheckUrl,
      'Weather Predict': weatherPredictUrl,
      'Live Weather': liveWeatherUrl,
      'Weather Forecast': forecastUrl,
      'AI Assistant': aiAssistantUrl,
      'Login': loginUrl,
      'Register': registerUrl,
      'Save Prediction': savePredictionUrl,
    };
  }

  /// Validate API configuration
  static void validateConfig() {
    try {
      EnvironmentConfig.validateConfiguration();
      debugPrint("Configuration validation passed");
    } catch (e) {
      errorPrint("Configuration validation failed: $e");
      rethrow;
    }
  }

  /// Check if API is accessible
  static Future<bool> checkApiHealth() async {
    try {
      final response = await HttpClient()
          .getUrl(Uri.parse(healthCheckUrl))
          .then((request) => request.close())
          .timeout(timeout);
      
      return response.statusCode == 200;
    } catch (e) {
      errorPrint("Health check failed: $e");
      return false;
    }
  }
}

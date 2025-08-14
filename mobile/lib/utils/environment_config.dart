import 'dart:io';

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  
  static Environment get environment => _environment;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  // API Configuration
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://localhost:8000';
      case Environment.staging:
        return 'https://staging-api.anga.com'; // Replace with your staging URL
      case Environment.production:
        return 'https://api.anga.com'; // Replace with your production URL
    }
  }
  
  static String get weatherApiKey {
    // In production, use secure storage or environment variables
    switch (_environment) {
      case Environment.development:
        return const String.fromEnvironment('WEATHER_API_KEY', defaultValue: 'dev_key');
      case Environment.staging:
        return const String.fromEnvironment('WEATHER_API_KEY', defaultValue: 'staging_key');
      case Environment.production:
        return const String.fromEnvironment('WEATHER_API_KEY', defaultValue: 'prod_key');
    }
  }
  
  // Firebase Configuration
  static bool get enableFirebase {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
  
  // Debug Configuration
  static bool get enableDebugMode {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return false;
      case Environment.production:
        return false;
    }
  }
  
  static bool get enableLogging {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }
  
  // Timeout Configuration
  static Duration get networkTimeout {
    switch (_environment) {
      case Environment.development:
        return const Duration(seconds: 30);
      case Environment.staging:
        return const Duration(seconds: 20);
      case Environment.production:
        return const Duration(seconds: 15);
    }
  }
  
  // Retry Configuration
  static int get maxRetries {
    switch (_environment) {
      case Environment.development:
        return 3;
      case Environment.staging:
        return 2;
      case Environment.production:
        return 2;
    }
  }
  
  // Cache Configuration
  static Duration get cacheDuration {
    switch (_environment) {
      case Environment.development:
        return const Duration(minutes: 5);
      case Environment.staging:
        return const Duration(minutes: 10);
      case Environment.production:
        return const Duration(minutes: 15);
    }
  }
  
  // Feature Flags
  static bool get enableAIAssistant {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
  
  static bool get enableWeatherAlerts {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
  
  // Validation
  static void validateConfiguration() {
    if (baseUrl.isEmpty) {
      throw Exception('Base URL cannot be empty');
    }
    
    if (weatherApiKey.isEmpty || weatherApiKey == 'dev_key') {
      if (_environment == Environment.production) {
        throw Exception('Weather API key must be configured for production');
      }
    }
  }
  
  // Helper method to get environment name
  static String get environmentName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }
} 
import 'package:flutter/foundation.dart' show kReleaseMode;

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  // Defaults to production for release builds (what actually ships to
  // users - the App Store/Play Store build and the distributed APK) and
  // development otherwise. Previously this was hardcoded to `development`
  // with nothing anywhere in the app ever calling setEnvironment(production),
  // so every build - including the published release APK - pointed at
  // localhost/emulator-only addresses that no real user's phone could reach.
  static Environment _environment =
      kReleaseMode ? Environment.production : Environment.development;

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
        return productionBaseUrl;
    }
  }

  /// The real backend, regardless of current environment - for fallback
  /// paths that need a URL guaranteed to work (e.g. a physical device with
  /// no local-dev IP override configured) rather than one that resolves
  /// per the *current* (possibly development) environment.
  static const String productionBaseUrl = 'https://anga-weather-api.onrender.com';
  
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
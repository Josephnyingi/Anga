import 'dart:io';
import 'environment_config.dart';

/// 🌐 **Centralized API Configuration**
/// 
/// This file ensures all services use consistent port settings and makes it easy
/// to switch between development and production environments.
/// 
/// **Platform Detection:**
/// - Android Emulator: Uses 10.0.2.2 (Android's localhost equivalent)
/// - Windows Desktop: Uses localhost
/// - iOS Simulator: Uses localhost
/// - Web: Uses localhost
/// - Production: Uses configured production URL
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Get the base URL based on the current platform and environment
  static String get baseUrl {
    // For production, always use the configured production URL
    if (EnvironmentConfig.environment == Environment.production) {
      return EnvironmentConfig.baseUrl;
    }
    
    // Force Windows to use localhost (temporary fix)
    if (Platform.isWindows) {
      debugPrint("🔧 Windows detected - using localhost:8000");
      return "http://localhost:8000";
    }
    
    // Manual override for Windows development (if needed)
    const forceWindowsLocalhost = bool.fromEnvironment('FORCE_WINDOWS_LOCALHOST', defaultValue: false);
    if (forceWindowsLocalhost && Platform.isWindows) {
      debugPrint("🔧 Using forced Windows localhost URL");
      return "http://localhost:8000";
    }
    
    // For development and staging, use platform-specific URLs
    return _getPlatformSpecificUrl();
  }

  /// Get platform-specific URL for development/staging
  static String _getPlatformSpecificUrl() {
    // Force debug output to see what's happening
    debugPrint("🔍 Platform Detection:");
    debugPrint("   Platform.isAndroid: ${Platform.isAndroid}");
    debugPrint("   Platform.isWindows: ${Platform.isWindows}");
    debugPrint("   Platform.operatingSystem: ${Platform.operatingSystem}");
    debugPrint("   Platform.localHostname: ${Platform.localHostname}");
    
    if (Platform.isAndroid) {
      // Android emulator/device - use 10.0.2.2 for emulator, localhost for device
      final isEmulator = _isAndroidEmulator();
      debugPrint("   Is Android Emulator: $isEmulator");
      
      return isEmulator 
          ? "http://10.0.2.2:8000"  // Android emulator
          : "http://localhost:8000"; // Android device
    } else if (Platform.isWindows) {
      debugPrint("   Using Windows localhost URL");
      return "http://localhost:8000"; // Windows desktop
    } else if (Platform.isMacOS) {
      return "http://localhost:8000"; // macOS desktop
    } else if (Platform.isLinux) {
      return "http://localhost:8000"; // Linux desktop
    } else if (Platform.isIOS) {
      return "http://localhost:8000"; // iOS simulator/device
    } else {
      // Web platform or unknown platform
      debugPrint("   Using default localhost URL for unknown platform");
      return "http://localhost:8000";
    }
  }

  /// Detect if running on Android emulator
  static bool _isAndroidEmulator() {
    try {
      if (!Platform.isAndroid) return false;
      
      // Method 1: Check environment variables
      if (Platform.environment.containsKey('ANDROID_EMULATOR') ||
          Platform.environment.containsKey('ANDROID_SDK_ROOT')) {
        return true;
      }
      
      // Method 2: Check hostname (emulator typically has 'emulator' in hostname)
      final hostname = Platform.localHostname.toLowerCase();
      if (hostname.contains('emulator') || hostname.contains('avd')) {
        return true;
      }
      
      // Method 3: Check for emulator-specific environment variables
      final envVars = Platform.environment.keys.where((key) => 
        key.toLowerCase().contains('emulator') || 
        key.toLowerCase().contains('avd') ||
        key.toLowerCase().contains('android')
      ).toList();
      
      if (envVars.isNotEmpty) {
        debugPrint("Found Android-related env vars: $envVars");
        return true;
      }
      
      // Method 4: For development, we can add a manual override
      // You can set this in your environment or add a build flag
      const isEmulatorOverride = bool.fromEnvironment('IS_ANDROID_EMULATOR', defaultValue: false);
      if (isEmulatorOverride) {
        return true;
      }
      
      // If we can't determine, assume it's a physical device for safety
      // (localhost is more likely to work on physical devices)
      return false;
    } catch (e) {
      debugPrint("Error detecting Android emulator: $e");
      // If we can't determine, assume it's a physical device
      return false;
    }
  }

  /// Get platform information for debugging
  static String get platformInfo {
    return '''
📱 Platform Information:
   OS: ${Platform.operatingSystem}
   OS Version: ${Platform.operatingSystemVersion}
   Local Hostname: ${Platform.localHostname}
   Environment Variables: ${Platform.environment.keys.length} variables
   Is Android Emulator: ${Platform.isAndroid ? _isAndroidEmulator() : 'N/A'}
   Current Base URL: $baseUrl
''';
  }

  /// Weather prediction endpoint
  static String get weatherPredictUrl => "$baseUrl/predict/";
  
  /// Live weather endpoint
  static String get liveWeatherUrl => "$baseUrl/live_weather/";
  
  /// Weather forecast endpoint
  static String get forecastUrl => "$baseUrl/forecast/";
  
  /// AI Assistant endpoint
  static String get aiAssistantUrl => "$baseUrl/assistant/ask"; // Matches backend POST /assistant/ask
  
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
    "User-Agent": "ANGA-Weather-App/1.0.0",
    if (EnvironmentConfig.weatherApiKey.isNotEmpty)
      "X-API-Key": EnvironmentConfig.weatherApiKey,
  };

  /// Timeout duration for API requests
  static Duration get timeout {
    // Increase timeout for development to handle slower connections
    if (EnvironmentConfig.environment == Environment.development) {
      return const Duration(seconds: 60); // 60 seconds for development
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
      print("🔧 [API Config] $message");
    }
  }

  /// Print error information
  static void errorPrint(String message) {
    if (EnvironmentConfig.enableLogging) {
      print("❌ [API Config] $message");
    }
  }

  /// Print detailed platform and configuration information
  static void printConfigurationDetails() {
    if (!debugMode) return;
    
    print("🔧 [API Config] Configuration Details:");
    print("   Environment: ${EnvironmentConfig.environmentName}");
    print("   Platform: ${Platform.operatingSystem}");
    print("   Is Android: ${Platform.isAndroid}");
    print("   Is Android Emulator: ${Platform.isAndroid ? _isAndroidEmulator() : 'N/A'}");
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
🌐 API Configuration:
   Environment: ${EnvironmentConfig.environmentName}
   Base URL: $baseUrl
   Platform: ${Platform.operatingSystem}
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
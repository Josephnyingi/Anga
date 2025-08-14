import 'dart:io';
import 'api_config.dart';

/// 🧪 **Port Configuration Test**
/// 
/// This file helps verify that all services are using the correct port configuration.
/// Run this to check if there are any port mismatches.
class PortConfigTest {
  static void runTest() {
    print("🧪 Starting Port Configuration Test...");
    print("=" * 50);
    
    // Test API Config
    print("📋 API Configuration:");
    print(ApiConfig.configInfo);
    
    // Test all endpoints
    print("\n🔗 Endpoint URLs:");
    print("Weather Predict: ${ApiConfig.weatherPredictUrl}");
    print("Live Weather: ${ApiConfig.liveWeatherUrl}");
    print("AI Assistant: ${ApiConfig.aiAssistantUrl}");
    print("Login: ${ApiConfig.loginUrl}");
    print("Register: ${ApiConfig.registerUrl}");
    print("Save Prediction: ${ApiConfig.savePredictionUrl}");
    
    // Verify all URLs use port 8000
    final endpoints = [
      ApiConfig.weatherPredictUrl,
      ApiConfig.liveWeatherUrl,
      ApiConfig.aiAssistantUrl,
      ApiConfig.loginUrl,
      ApiConfig.registerUrl,
      ApiConfig.savePredictionUrl,
    ];
    
    print("\n✅ Port Verification:");
    bool allCorrect = true;
    for (final endpoint in endpoints) {
      final usesPort8000 = endpoint.contains(':8000');
      final status = usesPort8000 ? '✅' : '❌';
      print("$status $endpoint");
      if (!usesPort8000) allCorrect = false;
    }
    
    print("\n" + "=" * 50);
    if (allCorrect) {
      print("🎉 All endpoints are correctly configured to use port 8000!");
    } else {
      print("⚠️ Some endpoints are not using port 8000. Please check configuration.");
    }
    print("=" * 50);
  }
  
  /// Get platform-specific information
  static String getPlatformInfo() {
    return '''
🌐 Platform Information:
   OS: ${Platform.operatingSystem}
   OS Version: ${Platform.operatingSystemVersion}
   Local Hostname: ${Platform.localHostname}
   Environment Variables: ${Platform.environment.keys.length} variables
''';
  }
} 
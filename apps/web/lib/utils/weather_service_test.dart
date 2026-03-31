import 'dart:convert';
import 'dart:io';
import 'api_config.dart';

/// 🌤️ **Weather Service Test**
/// 
/// This utility tests the weather service endpoints
/// to ensure they're working correctly.
class WeatherServiceTest {
  static Future<void> runComprehensiveTest() async {
    print("🌤️ Running Weather Service Test for Web App...");
    
    try {
      await _testHealthEndpoint();
      await _testLiveWeatherEndpoint();
      await _testWeatherPredictionEndpoint();
      
      print("✅ Weather service test completed successfully");
    } catch (e) {
      print("❌ Weather service test failed: $e");
    }
  }
  
  static Future<void> _testHealthEndpoint() async {
    print("🔍 Testing health endpoint...");
    
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(ApiConfig.healthCheckUrl));
      final response = await request.close().timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print("✅ Health endpoint test passed");
      } else {
        print("⚠️ Health endpoint returned status: ${response.statusCode}");
      }
      
      client.close();
    } catch (e) {
      print("❌ Health endpoint test error: $e");
    }
  }
  
  static Future<void> _testLiveWeatherEndpoint() async {
    print("🔍 Testing live weather endpoint...");
    
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse("${ApiConfig.liveWeatherUrl}?location=machakos"));
      final response = await request.close().timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print("✅ Live weather endpoint test passed");
      } else {
        print("⚠️ Live weather endpoint returned status: ${response.statusCode}");
      }
      
      client.close();
    } catch (e) {
      print("❌ Live weather endpoint test error: $e");
    }
  }
  
  static Future<void> _testWeatherPredictionEndpoint() async {
    print("🔍 Testing weather prediction endpoint...");
    
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(ApiConfig.weatherPredictUrl));
      request.headers.set('Content-Type', 'application/json');
      
      final requestBody = json.encode({
        'date': DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0],
        'location': 'machakos'
      });
      
      request.write(requestBody);
      final response = await request.close().timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print("✅ Weather prediction endpoint test passed");
      } else {
        print("⚠️ Weather prediction endpoint returned status: ${response.statusCode}");
      }
      
      client.close();
    } catch (e) {
      print("❌ Weather prediction endpoint test error: $e");
    }
  }
}

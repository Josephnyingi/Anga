import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// 🧪 Mobile App Test Utility
/// 
/// This utility helps diagnose issues with the mobile app's API connectivity,
/// data parsing, and chart rendering.
class MobileTestUtility {
  static const String _testTag = "🧪 [Mobile Test]";
  
  /// Test all API endpoints and return detailed results
  static Future<Map<String, dynamic>> runAllTests() async {
    print("$_testTag Starting comprehensive mobile app tests...");
    
    Map<String, dynamic> results = {
      'timestamp': DateTime.now().toIso8601String(),
      'base_url': ApiConfig.baseUrl,
      'platform': Platform.operatingSystem,
      'tests': {},
    };
    
    // Test 1: Backend Health
    results['tests']['backend_health'] = await _testBackendHealth();
    
    // Test 2: Live Weather API
    results['tests']['live_weather'] = await _testLiveWeather();
    
    // Test 3: Weather Prediction API
    results['tests']['weather_prediction'] = await _testWeatherPrediction();
    
    // Test 4: AI Assistant API
    results['tests']['ai_assistant'] = await _testAIAssistant();
    
    // Test 5: Chart Data Validation
    results['tests']['chart_data'] = await _testChartData();
    
    // Test 6: Network Connectivity
    results['tests']['network'] = await _testNetworkConnectivity();
    
    _printTestSummary(results);
    return results;
  }
  
  /// Test backend health endpoint
  static Future<Map<String, dynamic>> _testBackendHealth() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("$_testTag ✅ Backend Health: OK");
        return {
          'status': 'PASS',
          'response': data,
          'details': 'Backend is healthy and responding'
        };
      } else {
        print("$_testTag ❌ Backend Health: Failed (${response.statusCode})");
        return {
          'status': 'FAIL',
          'error': 'HTTP ${response.statusCode}',
          'details': response.body
        };
      }
    } catch (e) {
      print("$_testTag ❌ Backend Health: Network Error - $e");
      return {
        'status': 'FAIL',
        'error': 'Network Error',
        'details': e.toString()
      };
    }
  }
  
  /// Test live weather API
  static Future<Map<String, dynamic>> _testLiveWeather() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/live_weather/?location=machakos'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("$_testTag ✅ Live Weather: OK");
        print("$_testTag    📊 Data: $data");
        
        // Validate data structure
        final hasRequiredFields = data.containsKey('location') && 
                                 data.containsKey('date') && 
                                 data.containsKey('temperature_max') && 
                                 data.containsKey('rain_sum');
        
        return {
          'status': hasRequiredFields ? 'PASS' : 'WARNING',
          'response': data,
          'details': hasRequiredFields ? 'Data structure is correct' : 'Missing required fields',
          'has_required_fields': hasRequiredFields
        };
      } else {
        print("$_testTag ❌ Live Weather: Failed (${response.statusCode})");
        return {
          'status': 'FAIL',
          'error': 'HTTP ${response.statusCode}',
          'details': response.body
        };
      }
    } catch (e) {
      print("$_testTag ❌ Live Weather: Network Error - $e");
      return {
        'status': 'FAIL',
        'error': 'Network Error',
        'details': e.toString()
      };
    }
  }
  
  /// Test weather prediction API
  static Future<Map<String, dynamic>> _testWeatherPrediction() async {
    try {
      final testDate = DateTime.now().toIso8601String().split('T')[0];
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/predict/'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'date': testDate,
          'location': 'machakos'
        }),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("$_testTag ✅ Weather Prediction: OK");
        print("$_testTag    📊 Data: $data");
        
        // Validate data structure
        final hasRequiredFields = data.containsKey('source') && 
                                 data.containsKey('date') && 
                                 data.containsKey('location') && 
                                 data.containsKey('temperature_prediction') && 
                                 data.containsKey('rain_prediction');
        
        return {
          'status': hasRequiredFields ? 'PASS' : 'WARNING',
          'response': data,
          'details': hasRequiredFields ? 'Data structure is correct' : 'Missing required fields',
          'has_required_fields': hasRequiredFields
        };
      } else {
        print("$_testTag ❌ Weather Prediction: Failed (${response.statusCode})");
        return {
          'status': 'FAIL',
          'error': 'HTTP ${response.statusCode}',
          'details': response.body
        };
      }
    } catch (e) {
      print("$_testTag ❌ Weather Prediction: Network Error - $e");
      return {
        'status': 'FAIL',
        'error': 'Network Error',
        'details': e.toString()
      };
    }
  }
  
  /// Test AI Assistant API
  static Future<Map<String, dynamic>> _testAIAssistant() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/assistant/ask'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'query': 'What crops grow well in Machakos?',
          'use_case': 'Smart Farming Advice'
        }),
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("$_testTag ✅ AI Assistant: OK");
        print("$_testTag    🤖 Response: ${data['answer']?.substring(0, 100)}...");
        
        final hasAnswer = data.containsKey('answer') && data['answer'] != null;
        final isErrorResponse = data['answer']?.toString().contains('Error') ?? false;
        
        return {
          'status': hasAnswer && !isErrorResponse ? 'PASS' : 'WARNING',
          'response': data,
          'details': isErrorResponse ? 'API key issue detected' : 'Response received',
          'has_answer': hasAnswer,
          'is_error_response': isErrorResponse
        };
      } else {
        print("$_testTag ❌ AI Assistant: Failed (${response.statusCode})");
        return {
          'status': 'FAIL',
          'error': 'HTTP ${response.statusCode}',
          'details': response.body
        };
      }
    } catch (e) {
      print("$_testTag ❌ AI Assistant: Network Error - $e");
      return {
        'status': 'FAIL',
        'error': 'Network Error',
        'details': e.toString()
      };
    }
  }
  
  /// Test chart data generation
  static Future<Map<String, dynamic>> _testChartData() async {
    try {
      // Generate sample chart data similar to what the app uses
      List<Map<String, dynamic>> weatherData = [];
      List<String> forecastDates = [];
      
      for (int i = 0; i < 7; i++) {
        final date = DateTime.now().add(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];
        
        // Simulate API call
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/predict/'),
          headers: ApiConfig.defaultHeaders,
          body: jsonEncode({
            'date': dateStr,
            'location': 'machakos'
          }),
        ).timeout(Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          forecastDates.add('${date.day}/${date.month}');
          weatherData.add({
            "day": i.toDouble(),
            "temperature": data['temperature_prediction']?.toDouble() ?? 0.0,
            "rain": data['rain_prediction']?.toDouble() ?? 0.0,
          });
        }
      }
      
      print("$_testTag ✅ Chart Data: Generated ${weatherData.length} data points");
      
      // Validate chart data
      final hasValidData = weatherData.isNotEmpty && 
                          weatherData.every((d) => d['temperature'] != null && d['rain'] != null);
      
      return {
        'status': hasValidData ? 'PASS' : 'WARNING',
        'data_points': weatherData.length,
        'sample_data': weatherData.take(3).toList(),
        'forecast_dates': forecastDates,
        'details': hasValidData ? 'Chart data is valid' : 'Some data points are invalid'
      };
      
    } catch (e) {
      print("$_testTag ❌ Chart Data: Error - $e");
      return {
        'status': 'FAIL',
        'error': 'Chart Data Error',
        'details': e.toString()
      };
    }
  }
  
  /// Test network connectivity
  static Future<Map<String, dynamic>> _testNetworkConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.baseUrl),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(seconds: 5));
      
      print("$_testTag ✅ Network Connectivity: OK");
      return {
        'status': 'PASS',
        'response_time': 'Good',
        'details': 'Network connection is working'
      };
    } catch (e) {
      print("$_testTag ❌ Network Connectivity: Failed - $e");
      return {
        'status': 'FAIL',
        'error': 'Network Error',
        'details': e.toString()
      };
    }
  }
  
  /// Print test summary
  static void _printTestSummary(Map<String, dynamic> results) {
    print("\n$_testTag ========================================");
    print("$_testTag 📊 MOBILE APP TEST SUMMARY");
    print("$_testTag ========================================");
    print("$_testTag Base URL: ${results['base_url']}");
    print("$_testTag Platform: ${results['platform']}");
    print("$_testTag Timestamp: ${results['timestamp']}");
    print("$_testTag");
    
    int passed = 0;
    int failed = 0;
    int warnings = 0;
    
    results['tests'].forEach((testName, result) {
      final status = result['status'];
      final icon = status == 'PASS' ? '✅' : status == 'WARNING' ? '⚠️' : '❌';
      
      print("$_testTag $icon $testName: $status");
      
      if (status == 'PASS') passed++;
      else if (status == 'WARNING') warnings++;
      else failed++;
      
      if (result['details'] != null) {
        print("$_testTag    📝 ${result['details']}");
      }
    });
    
    print("$_testTag");
    print("$_testTag 🎯 Results: $passed passed, $warnings warnings, $failed failed");
    
    if (failed == 0 && warnings == 0) {
      print("$_testTag 🎉 All tests passed! Mobile app should work correctly.");
    } else if (failed == 0) {
      print("$_testTag ⚠️ Some warnings detected. Check the details above.");
    } else {
      print("$_testTag ❌ Some tests failed. Please fix the issues above.");
    }
    
    print("$_testTag ========================================\n");
  }
  
  /// Get troubleshooting tips based on test results
  static List<String> getTroubleshootingTips(Map<String, dynamic> results) {
    List<String> tips = [];
    
    if (results['tests']['backend_health']['status'] == 'FAIL') {
      tips.add("🔧 Backend is not running. Start it with: backend/start_backend.bat");
    }
    
    if (results['tests']['ai_assistant']['status'] == 'WARNING') {
      tips.add("🔧 AI Assistant API key is invalid. Check your .env file and GROQ_API_KEY");
    }
    
    if (results['tests']['network']['status'] == 'FAIL') {
      tips.add("🔧 Network connectivity issue. Check if backend is running on port 8000");
      tips.add("🔧 For Android emulator, ensure backend is accessible at 10.0.2.2:8000");
    }
    
    if (results['tests']['chart_data']['status'] == 'FAIL') {
      tips.add("🔧 Chart data generation failed. Check weather prediction API");
    }
    
    return tips;
  }
} 
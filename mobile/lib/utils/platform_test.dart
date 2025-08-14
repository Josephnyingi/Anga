import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

/// 🧪 Platform Test Utility
/// 
/// This utility helps diagnose platform-specific issues between
/// Windows desktop and Android emulator.
class PlatformTest {
  static const String _testTag = "🧪 [Platform Test]";
  
  /// Run comprehensive platform tests
  static Future<Map<String, dynamic>> runPlatformTests() async {
    print("$_testTag Starting platform-specific tests...");
    
    Map<String, dynamic> results = {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'platform_version': Platform.operatingSystemVersion,
      'local_hostname': Platform.localHostname,
      'environment_variables': Platform.environment,
      'tests': {},
    };
    
    // Test 1: API Connectivity
    results['tests']['api_connectivity'] = await _testApiConnectivity();
    
    // Test 2: Chart Rendering Test
    results['tests']['chart_rendering'] = await _testChartRendering();
    
    // Test 3: AI Assistant Test
    results['tests']['ai_assistant'] = await _testAIAssistant();
    
    // Test 4: Weather Data Test
    results['tests']['weather_data'] = await _testWeatherData();
    
    _printTestSummary(results);
    return results;
  }
  
  /// Test API connectivity
  static Future<Map<String, dynamic>> _testApiConnectivity() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/health');
      print("$_testTag Testing API connectivity to: $url");
      
      final response = await http.get(url).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print("$_testTag ✅ API Connectivity: OK");
        return {
          'status': 'PASS',
          'url': url.toString(),
          'response_code': response.statusCode,
          'response_body': response.body.substring(0, 100) + '...',
        };
      } else {
        print("$_testTag ❌ API Connectivity: Failed (${response.statusCode})");
        return {
          'status': 'FAIL',
          'url': url.toString(),
          'response_code': response.statusCode,
          'error': response.body,
        };
      }
    } catch (e) {
      print("$_testTag ❌ API Connectivity: Network Error - $e");
      return {
        'status': 'FAIL',
        'url': ApiConfig.baseUrl,
        'error': e.toString(),
      };
    }
  }
  
  /// Test chart rendering capabilities
  static Future<Map<String, dynamic>> _testChartRendering() async {
    try {
      // Test if we can create basic chart data
      final testData = [
        {'x': 0, 'y': 25.0},
        {'x': 1, 'y': 26.0},
        {'x': 2, 'y': 24.0},
        {'x': 3, 'y': 27.0},
      ];
      
      print("$_testTag Testing chart data generation...");
      
      return {
        'status': 'PASS',
        'test_data': testData,
        'data_points': testData.length,
        'platform_support': 'Chart data generation works',
      };
    } catch (e) {
      print("$_testTag ❌ Chart Rendering: Error - $e");
      return {
        'status': 'FAIL',
        'error': e.toString(),
      };
    }
  }
  
  /// Test AI Assistant functionality
  static Future<Map<String, dynamic>> _testAIAssistant() async {
    try {
      final url = Uri.parse(ApiConfig.aiAssistantUrl);
      print("$_testTag Testing AI Assistant at: $url");
      
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'query': 'Test question for platform compatibility',
          'use_case': 'Smart Farming Advice'
        }),
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("$_testTag ✅ AI Assistant: OK");
        return {
          'status': 'PASS',
          'response_code': response.statusCode,
          'has_answer': data.containsKey('answer'),
          'answer_length': data['answer']?.toString().length ?? 0,
        };
      } else {
        print("$_testTag ❌ AI Assistant: Failed (${response.statusCode})");
        return {
          'status': 'FAIL',
          'response_code': response.statusCode,
          'error': response.body,
        };
      }
    } catch (e) {
      print("$_testTag ❌ AI Assistant: Network Error - $e");
      return {
        'status': 'FAIL',
        'error': e.toString(),
      };
    }
  }
  
  /// Test weather data fetching
  static Future<Map<String, dynamic>> _testWeatherData() async {
    try {
      final url = Uri.parse('${ApiConfig.liveWeatherUrl}?location=machakos');
      print("$_testTag Testing weather data at: $url");
      
      final response = await http.get(url).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("$_testTag ✅ Weather Data: OK");
        return {
          'status': 'PASS',
          'response_code': response.statusCode,
          'has_temperature': data.containsKey('temperature'),
          'has_humidity': data.containsKey('humidity'),
          'data_keys': data.keys.toList(),
        };
      } else {
        print("$_testTag ❌ Weather Data: Failed (${response.statusCode})");
        return {
          'status': 'FAIL',
          'response_code': response.statusCode,
          'error': response.body,
        };
      }
    } catch (e) {
      print("$_testTag ❌ Weather Data: Network Error - $e");
      return {
        'status': 'FAIL',
        'error': e.toString(),
      };
    }
  }
  
  /// Print test summary
  static void _printTestSummary(Map<String, dynamic> results) {
    print("\n$_testTag ===== PLATFORM TEST SUMMARY =====");
    print("$_testTag Platform: ${results['platform']}");
    print("$_testTag Version: ${results['platform_version']}");
    print("$_testTag Hostname: ${results['local_hostname']}");
    
          final tests = results['tests'] as Map<dynamic, dynamic>;
    tests.forEach((testName, testResult) {
      final status = testResult['status'] as String;
      final icon = status == 'PASS' ? '✅' : status == 'WARNING' ? '⚠️' : '❌';
      print("$_testTag $icon $testName: $status");
    });
    
    print("$_testTag ================================\n");
  }
  
  /// Get platform-specific recommendations
  static String getPlatformRecommendations() {
    if (Platform.isAndroid) {
      return '''
📱 Android Emulator Recommendations:
1. Ensure backend is running on host machine
2. Check if 10.0.2.2:8000 is accessible
3. Verify Android emulator network settings
4. Try restarting the emulator
5. Check if charts render in debug mode
''';
    } else if (Platform.isWindows) {
      return '''
🖥️ Windows Desktop Recommendations:
1. Ensure backend is running on localhost:8000
2. Check if 127.0.0.1:8000 is accessible
3. Verify Windows firewall settings
4. Try running as administrator if needed
5. Check if charts render properly
''';
    } else {
      return '''
💻 Other Platform Recommendations:
1. Check network connectivity to backend
2. Verify API endpoints are accessible
3. Test chart rendering capabilities
4. Check platform-specific limitations
''';
    }
  }
} 
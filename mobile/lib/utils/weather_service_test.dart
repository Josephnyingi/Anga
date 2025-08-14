import '../services/weather_services.dart';
import '../services/models/weather_forecast.dart';
import 'api_config.dart';

/// 🧪 **Weather Service Test Utility**
/// 
/// This utility helps test and verify all weather service functionality.
/// Run this to check if all weather-related features are working correctly.
class WeatherServiceTest {
  static Future<void> runComprehensiveTest() async {
    print("🧪 Starting Weather Service Comprehensive Test...");
    print("=" * 60);
    
    // Test 1: API Configuration
    await _testApiConfiguration();
    
    // Test 2: Basic Weather Fetching
    await _testBasicWeatherFetching();
    
    // Test 3: Live Weather Fetching
    await _testLiveWeatherFetching();
    
    // Test 4: Batch Weather Fetching
    await _testBatchWeatherFetching();
    
    // Test 5: Model Functionality
    await _testWeatherModels();
    
    // Test 6: Utility Functions
    await _testUtilityFunctions();
    
    print("=" * 60);
    print("🎉 Weather Service Test Complete!");
    print("=" * 60);
  }

  static Future<void> _testApiConfiguration() async {
    print("\n📋 Test 1: API Configuration");
    print("-" * 30);
    
    print("Base URL: ${ApiConfig.baseUrl}");
    print("Weather Predict URL: ${ApiConfig.weatherPredictUrl}");
    print("Live Weather URL: ${ApiConfig.liveWeatherUrl}");
    print("AI Assistant URL: ${ApiConfig.aiAssistantUrl}");
    print("Save Prediction URL: ${ApiConfig.savePredictionUrl}");
    
    // Verify all URLs use port 8000
    final endpoints = ApiConfig.allEndpoints.values;
    bool allCorrect = true;
    
    for (final endpoint in endpoints) {
      final usesPort8000 = endpoint.contains(':8000');
      final status = usesPort8000 ? '✅' : '❌';
      print("$status $endpoint");
      if (!usesPort8000) allCorrect = false;
    }
    
    if (allCorrect) {
      print("✅ All endpoints correctly configured!");
    } else {
      print("❌ Some endpoints have incorrect configuration!");
    }
  }

  static Future<void> _testBasicWeatherFetching() async {
    print("\n🌤️ Test 2: Basic Weather Fetching");
    print("-" * 30);
    
    try {
      final today = DateTime.now();
      final dateString = WeatherService.formatDateForApi(today);
      
      print("Fetching weather for today ($dateString) at Machakos...");
      
      final weatherData = await WeatherService.getWeather(dateString, 'machakos');
      
      if (weatherData.isNotEmpty) {
        print("✅ Basic weather fetch successful!");
        print("   Source: ${weatherData['source']}");
        print("   Temperature: ${weatherData['temperature_prediction']}°C");
        print("   Rainfall: ${weatherData['rain_prediction']}mm");
      } else {
        print("❌ Weather data is empty!");
      }
    } catch (e) {
      print("❌ Basic weather fetch failed: $e");
    }
  }

  static Future<void> _testLiveWeatherFetching() async {
    print("\n🌡️ Test 3: Live Weather Fetching");
    print("-" * 30);
    
    try {
      print("Fetching live weather for Machakos...");
      
      final liveWeather = await WeatherService.getLiveWeatherForecast('machakos');
      
      if (liveWeather != null && !liveWeather.hasError) {
        print("✅ Live weather fetch successful!");
        print("   Date: ${liveWeather.date}");
        print("   Temperature: ${liveWeather.temperatureString}");
        print("   Rainfall: ${liveWeather.rainfallString}");
        print("   Condition: ${liveWeather.weatherCondition}");
      } else if (liveWeather != null && liveWeather.hasError) {
        print("⚠️ Live weather fetch returned error: ${liveWeather.error}");
      } else {
        print("❌ Live weather fetch returned null!");
      }
    } catch (e) {
      print("❌ Live weather fetch failed: $e");
    }
  }

  static Future<void> _testBatchWeatherFetching() async {
    print("\n📅 Test 4: Batch Weather Fetching");
    print("-" * 30);
    
    try {
      final today = DateTime.now();
      final dates = [
        WeatherService.formatDateForApi(today),
        WeatherService.formatDateForApi(today.add(Duration(days: 1))),
        WeatherService.formatDateForApi(today.add(Duration(days: 2))),
      ];
      
      print("Fetching batch weather for ${dates.length} days...");
      
      final forecasts = await WeatherService.getWeatherForecastBatch(dates, 'machakos');
      
      print("✅ Batch weather fetch completed!");
      print("   Retrieved ${forecasts.length} forecasts");
      
      int successCount = 0;
      int errorCount = 0;
      
      for (final forecast in forecasts) {
        if (forecast.hasError) {
          errorCount++;
          print("   ❌ ${forecast.date}: ${forecast.error}");
        } else {
          successCount++;
          print("   ✅ ${forecast.date}: ${forecast.temperatureString}, ${forecast.rainfallString}");
        }
      }
      
      print("   Success: $successCount, Errors: $errorCount");
    } catch (e) {
      print("❌ Batch weather fetch failed: $e");
    }
  }

  static Future<void> _testWeatherModels() async {
    print("\n🏗️ Test 5: Weather Models");
    print("-" * 30);
    
    // Test WeatherForecastModel
    final testJson = {
      'source': 'ml-model',
      'date': '2024-01-15',
      'location': 'Machakos',
      'temperature_prediction': 25.5,
      'rain_prediction': 2.3,
    };
    
    final model = WeatherForecastModel.fromJson(testJson);
    
    print("✅ WeatherForecastModel created successfully!");
    print("   Source: ${model.source}");
    print("   Date: ${model.date}");
    print("   Location: ${model.location}");
    print("   Temperature: ${model.temperatureString}");
    print("   Rainfall: ${model.rainfallString}");
    print("   Condition: ${model.weatherCondition}");
    print("   Has Error: ${model.hasError}");
    
    // Test WeatherDataPoint
    final dataPoint = WeatherDataPoint(
      day: 1.0,
      temperature: 25.5,
      rain: 2.3,
    );
    
    print("✅ WeatherDataPoint created successfully!");
    print("   Day: ${dataPoint.day}");
    print("   Temperature: ${dataPoint.temperature}");
    print("   Rain: ${dataPoint.rain}");
  }

  static Future<void> _testUtilityFunctions() async {
    print("\n🔧 Test 6: Utility Functions");
    print("-" * 30);
    
    // Test supported locations
    final locations = WeatherService.getSupportedLocations();
    print("✅ Supported locations: ${locations.join(', ')}");
    
    // Test location validation
    final validLocation = WeatherService.isValidLocation('machakos');
    final invalidLocation = WeatherService.isValidLocation('invalid');
    
    print("✅ Location validation:");
    print("   'machakos' is valid: $validLocation");
    print("   'invalid' is valid: $invalidLocation");
    
    // Test date formatting
    final testDate = DateTime(2024, 1, 15);
    final formattedDate = WeatherService.formatDateForApi(testDate);
    final parsedDate = WeatherService.parseDateFromApi(formattedDate);
    
    print("✅ Date utilities:");
    print("   Original: $testDate");
    print("   Formatted: $formattedDate");
    print("   Parsed: $parsedDate");
    print("   Match: ${testDate.isAtSameMomentAs(parsedDate)}");
  }

  /// Quick connectivity test
  static Future<bool> testConnectivity() async {
    print("🔍 Testing API connectivity...");
    
    try {
      final today = DateTime.now();
      final dateString = WeatherService.formatDateForApi(today);
      
      await WeatherService.getWeather(dateString, 'machakos');
      print("✅ API connectivity test passed!");
      return true;
    } catch (e) {
      print("❌ API connectivity test failed: $e");
      return false;
    }
  }
} 
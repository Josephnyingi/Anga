import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

/// 🌤️ **Weather Provider**
/// 
/// Manages weather data state for the web application
class WeatherProvider with ChangeNotifier {
  static const String _tag = 'WeatherProvider';

  // Weather data
  Map<String, dynamic>? _currentWeather;
  List<Map<String, dynamic>> _forecast = [];
  List<Map<String, dynamic>> _alerts = [];
  
  // Loading states
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get currentWeather => _currentWeather;
  List<Map<String, dynamic>> get forecast => _forecast;
  List<Map<String, dynamic>> get alerts => _alerts;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;

  /// Load current weather data
  Future<void> loadCurrentWeather({String location = 'machakos'}) async {
    _setLoading(true);
    _clearError();

    try {
      print('$_tag: Loading current weather for $location');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.liveWeatherUrl}?location=$location'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);

      print('$_tag: Weather response status: ${response.statusCode}');
      print('$_tag: Weather response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentWeather = data;
        notifyListeners();
      } else {
        _setError('Failed to load weather data');
      }
    } catch (e) {
      print('$_tag: Error loading weather: $e');
      _setError('Network error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load weather forecast
  Future<void> loadForecast({String location = 'machakos', int days = 5}) async {
    _setLoading(true);
    _clearError();

    try {
      print('$_tag: Loading forecast for $location');
      
      // For now, we'll create mock forecast data
      // In a real app, you would call a forecast API
      _forecast = _generateMockForecast(days);
      notifyListeners();
    } catch (e) {
      print('$_tag: Error loading forecast: $e');
      _setError('Network error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load weather alerts
  Future<void> loadAlerts({String location = 'machakos'}) async {
    _setLoading(true);
    _clearError();

    try {
      print('$_tag: Loading alerts for $location');
      
      // For now, we'll create mock alert data
      // In a real app, you would call an alerts API
      _alerts = _generateMockAlerts();
      notifyListeners();
    } catch (e) {
      print('$_tag: Error loading alerts: $e');
      _setError('Network error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh all weather data
  Future<void> refreshWeather({String location = 'machakos'}) async {
    _setRefreshing(true);
    _clearError();

    try {
      await Future.wait([
        loadCurrentWeather(location: location),
        loadForecast(location: location),
        loadAlerts(location: location),
      ]);
    } catch (e) {
      print('$_tag: Error refreshing weather: $e');
      _setError('Failed to refresh weather data');
    } finally {
      _setRefreshing(false);
    }
  }

  /// Get weather prediction for a specific date
  Future<Map<String, dynamic>?> getWeatherPrediction({
    required String date,
    String location = 'machakos',
  }) async {
    try {
      print('$_tag: Getting weather prediction for $date in $location');
      
      final response = await http.post(
        Uri.parse(ApiConfig.weatherPredictUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'date': date,
          'location': location,
        }),
      ).timeout(ApiConfig.timeout);

      print('$_tag: Prediction response status: ${response.statusCode}');
      print('$_tag: Prediction response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        _setError('Prediction failed: ${errorData['detail']}');
        return null;
      }
    } catch (e) {
      print('$_tag: Error getting prediction: $e');
      _setError('Network error: $e');
      return null;
    }
  }

  /// Save weather prediction
  Future<bool> savePrediction({
    required String date,
    required String location,
    required double temperature,
    required double rain,
  }) async {
    try {
      print('$_tag: Saving prediction for $date in $location');
      
      final response = await http.post(
        Uri.parse(ApiConfig.savePredictionUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'date': date,
          'location': location,
          'temperature': temperature,
          'rain': rain,
        }),
      ).timeout(ApiConfig.timeout);

      print('$_tag: Save prediction response status: ${response.statusCode}');
      print('$_tag: Save prediction response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _setError('Save failed: ${errorData['detail']}');
        return false;
      }
    } catch (e) {
      print('$_tag: Error saving prediction: $e');
      _setError('Network error: $e');
      return false;
    }
  }

  /// Clear all data
  void clearData() {
    _currentWeather = null;
    _forecast.clear();
    _alerts.clear();
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Mock data generators (replace with real API calls)
  List<Map<String, dynamic>> _generateMockForecast(int days) {
    final now = DateTime.now();
    return List.generate(days, (index) {
      final date = now.add(Duration(days: index));
      return {
        'date': date.toIso8601String().split('T')[0],
        'day': _getDayName(date.weekday),
        'high': 25 + (index * 2),
        'low': 15 + index,
        'condition': _getRandomCondition(),
        'precip': (index * 10) % 100,
        'humidity': 60 + (index * 5),
        'wind': 10 + index,
      };
    });
  }

  List<Map<String, dynamic>> _generateMockAlerts() {
    return [
      {
        'id': '1',
        'title': 'High Temperature Warning',
        'message': 'Temperatures expected to reach 35°C today',
        'type': 'warning',
        'time': '2 hours ago',
        'location': 'Machakos',
      },
      {
        'id': '2',
        'title': 'Rain Forecast',
        'message': 'Light rain expected tomorrow morning',
        'type': 'info',
        'time': '5 hours ago',
        'location': 'Machakos',
      },
    ];
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getRandomCondition() {
    const conditions = ['sunny', 'cloudy', 'rainy', 'partly_cloudy'];
    return conditions[DateTime.now().millisecond % conditions.length];
  }
}
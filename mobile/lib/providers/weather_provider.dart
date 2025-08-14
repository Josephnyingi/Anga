import 'package:flutter/foundation.dart';
import '../services/live_weather_service.dart';
import '../services/weather_services.dart';
import '../utils/api_config.dart';

class WeatherData {
  final Map<String, dynamic> liveWeather;
  final Map<String, dynamic> currentWeather;
  final List<Map<String, dynamic>> forecast;
  final List<String> forecastDates;
  final DateTime lastUpdated;

  WeatherData({
    required this.liveWeather,
    required this.currentWeather,
    required this.forecast,
    required this.forecastDates,
    required this.lastUpdated,
  });

  WeatherData copyWith({
    Map<String, dynamic>? liveWeather,
    Map<String, dynamic>? currentWeather,
    List<Map<String, dynamic>>? forecast,
    List<String>? forecastDates,
    DateTime? lastUpdated,
  }) {
    return WeatherData(
      liveWeather: liveWeather ?? this.liveWeather,
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
      forecastDates: forecastDates ?? this.forecastDates,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  String _location = 'Nairobi';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  // Getters
  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get location => _location;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  // Check if data is stale (older than 15 minutes)
  bool get isDataStale {
    if (_weatherData == null) return true;
    final difference = DateTime.now().difference(_weatherData!.lastUpdated);
    return difference.inMinutes > 15;
  }

  // Update location
  void updateLocation(String newLocation) {
    if (_location != newLocation) {
      _location = newLocation;
      _error = null;
      notifyListeners();
      fetchWeatherData();
    }
  }

  // Update date range
  void updateDateRange(DateTime start, DateTime end) {
    if (_startDate != start || _endDate != end) {
      _startDate = start;
      _endDate = end;
      _error = null;
      notifyListeners();
      fetchWeatherData();
    }
  }

  // Fetch all weather data
  Future<void> fetchWeatherData() async {
    if (_isLoading) return;

    setState(loading: true, error: null);

    try {
      ApiConfig.debugPrint("🌤️ Fetching weather data for $_location");

      // Fetch all data concurrently
      final results = await Future.wait([
        _fetchLiveWeather(),
        _fetchCurrentWeather(),
        _fetchForecast(),
      ]);

      final liveWeather = results[0] as Map<String, dynamic>;
      final currentWeather = results[1] as Map<String, dynamic>;
      final forecastData = results[2] as Map<String, dynamic>;

      _weatherData = WeatherData(
        liveWeather: liveWeather,
        currentWeather: currentWeather,
        forecast: forecastData['forecast'] as List<Map<String, dynamic>>,
        forecastDates: forecastData['dates'] as List<String>,
        lastUpdated: DateTime.now(),
      );

      setState(loading: false);
      ApiConfig.debugPrint("✅ Weather data updated successfully");

    } catch (e) {
      setState(loading: false, error: e.toString());
      ApiConfig.errorPrint("❌ Error fetching weather data: $e");
    }
  }

  // Fetch live weather
  Future<Map<String, dynamic>> _fetchLiveWeather() async {
    try {
      return await LiveWeatherService.getLiveWeather(_location.toLowerCase());
    } catch (e) {
      ApiConfig.errorPrint("❌ Live weather fetch error: $e");
      rethrow;
    }
  }

  // Fetch current weather
  Future<Map<String, dynamic>> _fetchCurrentWeather() async {
    try {
      final date = _formatApiDate(DateTime.now());
      return await WeatherService.getWeather(date, _location);
    } catch (e) {
      ApiConfig.errorPrint("❌ Current weather fetch error: $e");
      rethrow;
    }
  }

  // Fetch forecast
  Future<Map<String, dynamic>> _fetchForecast() async {
    try {
      List<Map<String, dynamic>> weatherData = [];
      List<String> forecastDates = [];

      ApiConfig.debugPrint("🔍 Fetching forecast from $_startDate to $_endDate");

      for (DateTime date = _startDate;
          date.isBefore(_endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        final dateStr = _formatApiDate(date);
        ApiConfig.debugPrint("📅 Fetching weather for: $dateStr");
        
        final data = await WeatherService.getWeather(dateStr, _location);
        
        forecastDates.add(_formatDisplayDate(date));
        weatherData.add({
          "day": weatherData.length.toDouble(),
          "temperature": data['temperature_prediction']?.toDouble() ?? 0.0,
          "rain": data['rain_prediction']?.toDouble() ?? 0.0,
          "date": dateStr,
        });
      }

      return {
        'forecast': weatherData,
        'dates': forecastDates,
      };
    } catch (e) {
      ApiConfig.errorPrint("❌ Forecast fetch error: $e");
      rethrow;
    }
  }

  // Refresh data if stale
  Future<void> refreshIfNeeded() async {
    if (isDataStale) {
      ApiConfig.debugPrint("🔄 Data is stale, refreshing...");
      await fetchWeatherData();
    }
  }

  // Clear error
  void clearError() {
    if (_error != null) {
      setState(error: null);
    }
  }

  // Set loading and error states
  void setState({bool? loading, String? error}) {
    if (loading != null) _isLoading = loading;
    if (error != null) _error = error;
    notifyListeners();
  }

  // Helper methods
  String _formatApiDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  // Get temperature trend
  String getTemperatureTrend() {
    final forecastLength = _weatherData?.forecast.length ?? 0;
    if (forecastLength < 2) return 'Stable';
    
    final temps = _weatherData!.forecast.map((f) => f['temperature'] as double).toList();
    final first = temps.first;
    final last = temps.last;
    
    if (last > first + 2) return 'Rising';
    if (last < first - 2) return 'Falling';
    return 'Stable';
  }

  // Get rainfall trend
  String getRainfallTrend() {
    final forecastLength = _weatherData?.forecast.length ?? 0;
    if (forecastLength < 2) return 'Stable';
    
    final rains = _weatherData!.forecast.map((f) => f['rain'] as double).toList();
    final first = rains.first;
    final last = rains.last;
    
    if (last > first + 5) return 'Increasing';
    if (last < first - 5) return 'Decreasing';
    return 'Stable';
  }

  // Get weather summary
  Map<String, dynamic> getWeatherSummary() {
    if (_weatherData == null) return {};

    final liveTemp = _weatherData!.liveWeather['temperature_max'];
    final liveRain = _weatherData!.liveWeather['rain_sum'];
    final currentTemp = _weatherData!.currentWeather['temperature_prediction'];
    final currentRain = _weatherData!.currentWeather['rain_prediction'];

    return {
      'live_temperature': liveTemp,
      'live_rainfall': liveRain,
      'current_temperature': currentTemp,
      'current_rainfall': currentRain,
      'temperature_trend': getTemperatureTrend(),
      'rainfall_trend': getRainfallTrend(),
      'last_updated': _weatherData!.lastUpdated,
    };
  }
} 
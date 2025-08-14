import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _weatherDataKey = 'weather_data';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _lastUpdateKey = 'last_update';
  static const String _locationKey = 'location';
  static const String _themeKey = 'theme';
  static const String _notificationsKey = 'notifications';

  SharedPreferences? _prefs;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      ApiConfig.debugPrint("✅ Storage service initialized");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to initialize storage service: $e");
    }
  }

  // Weather data storage
  Future<void> saveWeatherData(Map<String, dynamic> weatherData) async {
    try {
      final data = {
        'data': weatherData,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _prefs?.setString(_weatherDataKey, jsonEncode(data));
      ApiConfig.debugPrint("💾 Weather data saved to local storage");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to save weather data: $e");
    }
  }

  Map<String, dynamic>? getWeatherData() {
    try {
      final data = _prefs?.getString(_weatherDataKey);
      if (data != null) {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        final timestamp = DateTime.parse(decoded['timestamp'] as String);
        
        // Check if data is not too old (24 hours)
        if (DateTime.now().difference(timestamp).inHours < 24) {
          ApiConfig.debugPrint("📱 Retrieved weather data from cache");
          return decoded['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to retrieve weather data: $e");
      return null;
    }
  }

  // User preferences storage
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await _prefs?.setString(_userPreferencesKey, jsonEncode(preferences));
      ApiConfig.debugPrint("💾 User preferences saved");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to save user preferences: $e");
    }
  }

  Map<String, dynamic> getUserPreferences() {
    try {
      final data = _prefs?.getString(_userPreferencesKey);
      if (data != null) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to retrieve user preferences: $e");
      return {};
    }
  }

  // Location storage
  Future<void> saveLocation(String location) async {
    try {
      await _prefs?.setString(_locationKey, location);
      ApiConfig.debugPrint("💾 Location saved: $location");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to save location: $e");
    }
  }

  String getLocation() {
    return _prefs?.getString(_locationKey) ?? 'Nairobi';
  }

  // Theme storage
  Future<void> saveTheme(bool isDarkMode) async {
    try {
      await _prefs?.setBool(_themeKey, isDarkMode);
      ApiConfig.debugPrint("💾 Theme preference saved: ${isDarkMode ? 'Dark' : 'Light'}");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to save theme: $e");
    }
  }

  bool getTheme() {
    return _prefs?.getBool(_themeKey) ?? false;
  }

  // Notifications storage
  Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    try {
      await _prefs?.setString(_notificationsKey, jsonEncode(settings));
      ApiConfig.debugPrint("💾 Notification settings saved");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to save notification settings: $e");
    }
  }

  Map<String, bool> getNotificationSettings() {
    try {
      final data = _prefs?.getString(_notificationsKey);
      if (data != null) {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, value as bool));
      }
      return {
        'weather_alerts': true,
        'daily_forecast': true,
        'extreme_weather': true,
      };
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to retrieve notification settings: $e");
      return {
        'weather_alerts': true,
        'daily_forecast': true,
        'extreme_weather': true,
      };
    }
  }

  // Cache management
  Future<void> clearCache() async {
    try {
      await _prefs?.remove(_weatherDataKey);
      await _prefs?.remove(_lastUpdateKey);
      ApiConfig.debugPrint("🗑️ Cache cleared");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to clear cache: $e");
    }
  }

  Future<void> clearAllData() async {
    try {
      await _prefs?.clear();
      ApiConfig.debugPrint("🗑️ All data cleared");
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to clear all data: $e");
    }
  }

  // Get storage info
  Map<String, dynamic> getStorageInfo() {
    try {
      final keys = _prefs?.getKeys() ?? {};
      final size = keys.length;
      
      return {
        'total_keys': size,
        'keys': keys.toList(),
        'has_weather_data': keys.contains(_weatherDataKey),
        'has_preferences': keys.contains(_userPreferencesKey),
        'location': getLocation(),
        'theme': getTheme(),
      };
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to get storage info: $e");
      return {};
    }
  }

  // Check if data exists
  bool hasWeatherData() {
    return _prefs?.containsKey(_weatherDataKey) ?? false;
  }

  bool hasUserPreferences() {
    return _prefs?.containsKey(_userPreferencesKey) ?? false;
  }

  // Get last update time
  DateTime? getLastUpdateTime() {
    try {
      final data = _prefs?.getString(_weatherDataKey);
      if (data != null) {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        return DateTime.parse(decoded['timestamp'] as String);
      }
      return null;
    } catch (e) {
      ApiConfig.errorPrint("❌ Failed to get last update time: $e");
      return null;
    }
  }
} 
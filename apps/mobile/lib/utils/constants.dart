// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'api_config.dart';

/// 🌍 **API Configuration**
///
/// Delegates to ApiConfig (utils/api_config.dart) so auth uses the same
/// environment-aware URL resolution as every other service, instead of a
/// second, separate config system. This used to be a hardcoded
/// "http://10.0.2.2:8000" (the Android-emulator-to-host address) baked
/// into every build including release - real users' phones could never
/// reach it.

String get API_BASE_URL => ApiConfig.baseUrl;

/// **🔗 API Endpoints**
String get LOGIN_API => ApiConfig.loginUrl;
String get REGISTER_API => ApiConfig.registerUrl;
String get WEATHER_PREDICT_API => ApiConfig.weatherPredictUrl;
String get SAVE_PREDICTION_API => ApiConfig.savePredictionUrl;

/// 🎨 **Theme Colors**
const Color primaryColor = Color(0xFF007ACC);       // 🔹 Modern blue for branding
const Color secondaryColor = Color(0xFF00A896);     // 🔹 Teal accent
const Color backgroundColor = Color(0xFFF5F5F5);    // 🔹 Light gray background

/// 🛠 **Alert Colors**
const Color alertHeatwaveColor = Colors.redAccent;     // 🔥 Heatwave
const Color alertFloodColor = Colors.blueAccent;       // 🌊 Flood
const Color alertStormColor = Colors.orangeAccent;     // ⛈️ Storm

/// 🌡️ **Default Weather Settings**
const String defaultLocation = "Machakos";
const bool defaultIsCelsius = true;
const bool defaultIsMillimeters = true;
const bool defaultEnableNotifications = true;
const bool defaultEnableExtremeAlerts = true;

/// 📢 **Alert Types**
const List<String> alertTypes = [
  "Heatwave",
  "Heavy Rainfall",
  "Storm Warning",
];

/// 🏗 **Feature Toggles**
const bool enableMLModelIntegration = true;     // 🤖 AI forecasting
const bool enableUserFeedback = true;           // 📝 Feedback form
const bool enableMultiLanguageSupport = false;  // 🌍 Future internationalization

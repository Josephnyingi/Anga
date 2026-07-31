// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class WeatherAlert {
  final String type;
  final String severity;
  final String date;
  final String location;
  final String message;

  WeatherAlert({
    required this.type,
    required this.severity,
    required this.date,
    required this.location,
    required this.message,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) => WeatherAlert(
        type: json['type'] ?? '',
        severity: json['severity'] ?? '',
        date: json['date'] ?? '',
        location: json['location'] ?? '',
        message: json['message'] ?? '',
      );

  /// Stable id used to avoid re-notifying for the same alert on every refresh.
  String get id => '$type-$date-$location';
}

class AlertsService {
  /// Fetch the current threshold-based early-warning alerts for a location.
  /// If [phoneNumber] is given and the farmer has registered livestock, the
  /// backend personalizes the livestock heat-stress message with their
  /// actual animals.
  static Future<List<WeatherAlert>> getAlerts(String location, {String? phoneNumber, double? lat, double? lon, String? label}) async {
    try {
      final phoneParam = (phoneNumber != null && phoneNumber.isNotEmpty)
          ? '&phone_number=${Uri.encodeComponent(phoneNumber)}'
          : '';
      final coordsParam = (lat != null && lon != null)
          ? '&lat=$lat&lon=$lon&label=${Uri.encodeComponent(label ?? location)}'
          : '';
      final response = await http
          .get(
            Uri.parse('${ApiConfig.alertsUrl}?location=$location$coordsParam$phoneParam'),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode != 200) {
        ApiConfig.debugPrint("Alerts API Error: ${response.statusCode}");
        return [];
      }

      final data = jsonDecode(response.body);
      final alerts = (data['alerts'] as List? ?? [])
          .map((a) => WeatherAlert.fromJson(a as Map<String, dynamic>))
          .toList();
      return alerts;
    } catch (e) {
      ApiConfig.debugPrint("Alerts network error: $e");
      return [];
    }
  }
}

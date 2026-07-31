// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class ForecastDay {
  final String date;
  final double? tempMax;
  final double? tempMin;
  final double? precipitationSum;
  final String description;

  ForecastDay({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationSum,
    required this.description,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) => ForecastDay(
        date: json['date'] ?? '',
        tempMax: (json['temp_max'] as num?)?.toDouble(),
        tempMin: (json['temp_min'] as num?)?.toDouble(),
        precipitationSum: (json['precipitation_sum'] as num?)?.toDouble(),
        description: json['description'] ?? 'Variable conditions',
      );
}

class ForecastService {
  static Future<List<ForecastDay>> getForecast(String location, {int days = 5, double? lat, double? lon, String? label}) async {
    try {
      final coordsParam = (lat != null && lon != null)
          ? '&lat=$lat&lon=$lon&label=${Uri.encodeComponent(label ?? location)}'
          : '';
      final response = await http
          .get(
            Uri.parse('${ApiConfig.forecastUrl}?location=$location&days=$days$coordsParam'),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode != 200) {
        ApiConfig.debugPrint("Forecast API Error: ${response.statusCode}");
        return [];
      }

      final data = jsonDecode(response.body);
      return (data['forecast'] as List? ?? [])
          .map((d) => ForecastDay.fromJson(d as Map<String, dynamic>))
          .toList();
    } catch (e) {
      ApiConfig.debugPrint("Forecast network error: $e");
      return [];
    }
  }
}

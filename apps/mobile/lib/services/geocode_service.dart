// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class LocationResult {
  final String name;
  final String? admin1;
  final String country;
  final double lat;
  final double lon;

  LocationResult({required this.name, this.admin1, required this.country, required this.lat, required this.lon});

  factory LocationResult.fromJson(Map<String, dynamic> json) => LocationResult(
        name: json['name'] ?? '',
        admin1: json['admin1'],
        country: json['country'] ?? '',
        lat: (json['lat'] as num).toDouble(),
        lon: (json['lon'] as num).toDouble(),
      );

  /// Displayed label, e.g. "Nairobi, Kenya" or "Gulu, Uganda".
  String get displayName => '$name, $country';
}

class GeocodeService {
  /// Search for a place name, restricted server-side to IGAD member states.
  static Future<List<LocationResult>> search(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.geocodeUrl}?query=${Uri.encodeComponent(query.trim())}'),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      return (data['results'] as List? ?? [])
          .map((r) => LocationResult.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Geocode search error: $e');
      return [];
    }
  }
}

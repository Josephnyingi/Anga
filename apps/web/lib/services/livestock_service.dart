// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

const List<String> kAnimalTypes = ['cattle', 'goat', 'sheep', 'poultry', 'pig'];

class LivestockRecord {
  final int id;
  final String location;
  final String animalType;
  final int count;

  LivestockRecord({
    required this.id,
    required this.location,
    required this.animalType,
    required this.count,
  });

  factory LivestockRecord.fromJson(Map<String, dynamic> json) => LivestockRecord(
        id: json['id'],
        location: json['location'] ?? '',
        animalType: json['animal_type'] ?? '',
        count: json['count'] ?? 0,
      );
}

class LivestockException implements Exception {
  final String message;
  LivestockException(this.message);
  @override
  String toString() => message;
}

class LivestockService {
  static Future<List<LivestockRecord>> getLivestock(String phoneNumber) async {
    if (phoneNumber.isEmpty) return [];

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.livestockUrl}?phone_number=${Uri.encodeComponent(phoneNumber)}'),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      return (data['livestock'] as List? ?? [])
          .map((r) => LivestockRecord.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("❌ Livestock fetch error: $e");
      return [];
    }
  }

  /// Registers or updates the count for one animal type.
  static Future<void> upsertLivestock({
    required String phoneNumber,
    required String location,
    required String animalType,
    required int count,
  }) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.livestockUrl),
          headers: ApiConfig.defaultHeaders,
          body: jsonEncode({
            'phone_number': phoneNumber,
            'location': location,
            'animal_type': animalType,
            'count': count,
          }),
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode != 200) {
      final detail = jsonDecode(response.body)['detail'] ?? 'Failed to save';
      throw LivestockException(detail.toString());
    }
  }

  static Future<void> deleteLivestock(int id, String phoneNumber) async {
    final response = await http
        .delete(
          Uri.parse('${ApiConfig.livestockUrl}$id?phone_number=${Uri.encodeComponent(phoneNumber)}'),
          headers: ApiConfig.defaultHeaders,
        )
        .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode != 200) {
      throw LivestockException('Failed to delete');
    }
  }
}

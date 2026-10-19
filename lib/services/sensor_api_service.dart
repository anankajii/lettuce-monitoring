import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/sensor_reading.dart';

class SensorApiException implements Exception {
  const SensorApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SensorApiService {
  const SensorApiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<SensorReading> fetchLatest() async {
    final client = _client ?? http.Client();

    try {
      final response = await client
          .get(Uri.parse(ApiConfig.latestSensorUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw SensorApiException(
          'API merespons dengan status ${response.statusCode}.',
        );
      }

      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) {
        throw const SensorApiException('Format respons API tidak valid.');
      }

      return SensorReading.fromJson(json);
    } on SensorApiException {
      rethrow;
    } catch (_) {
      throw const SensorApiException(
        'Tidak dapat terhubung ke API. Periksa Wi-Fi dan alamat server.',
      );
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}

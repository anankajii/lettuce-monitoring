import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class CloudflarePhoto {
  const CloudflarePhoto({required this.key, required this.uploadedAt});

  final String key;
  final DateTime uploadedAt;

  factory CloudflarePhoto.fromMap(Map<String, dynamic> map) {
    return CloudflarePhoto(
      key: map['key'] as String,
      uploadedAt: DateTime.parse(map['uploadedAt'] as String),
    );
  }
}

class CloudflareService {
  static final CloudflareService _instance = CloudflareService._();

  factory CloudflareService() => _instance;
  CloudflareService._();

  static const _baseUrl = 'https://smart-hydroponic-api.ananakun0.workers.dev';
  static const _tokenKey = 'cloudflare_app_token';
  final _storage = const FlutterSecureStorage();

  /// Set & simpan token (sekali saja di startup atau settings)
  Future<void> setAppToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Ambil token dari secure storage
  Future<String?> getAppToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// GET /list — ambil daftar foto terbaru
  Future<List<CloudflarePhoto>> listPhotos({String? token}) async {
    final authToken = token ?? await getAppToken();
    if (authToken == null) throw Exception('Cloudflare token not set');

    final res = await http.get(
      Uri.parse('$_baseUrl/list'),
      headers: {'Authorization': 'Bearer $authToken'},
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('Failed to list photos: ${res.statusCode}');
    }

    final json = _parseJson(res.body);
    final photos = (json['photos'] as List?)
        ?.map((e) => CloudflarePhoto.fromMap(e as Map<String, dynamic>))
        .toList();

    return photos ?? [];
  }

  /// GET /image/{key} — download foto & simpan ke file
  Future<File> downloadPhoto(String key, {String? token}) async {
    final authToken = token ?? await getAppToken();
    if (authToken == null) throw Exception('Cloudflare token not set');

    final res = await http.get(
      Uri.parse('$_baseUrl/image/$key'),
      headers: {'Authorization': 'Bearer $authToken'},
    ).timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw Exception('Failed to download photo: ${res.statusCode}');
    }

    // ponytail: simpan ke app cache dir, bukan documents (smaller scope)
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/cf_$key');
    await file.writeAsBytes(res.bodyBytes);
    return file;
  }

  /// POST /trigger/{deviceId} — trigger ESP32 untuk capture
  Future<void> triggerESP32Photo(String deviceId, {String? token}) async {
    final authToken = token ?? await getAppToken();
    if (authToken == null) throw Exception('Cloudflare token not set');

    final res = await http.post(
      Uri.parse('$_baseUrl/trigger/$deviceId'),
      headers: {'Authorization': 'Bearer $authToken'},
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Trigger failed: ${res.statusCode}');
    }
  }

  static dynamic _parseJson(String body) {
    try {
      return _simpleJsonParse(body);
    } catch (_) {
      return {};
    }
  }

  static dynamic _simpleJsonParse(String json) {
    // ponytail: dart:convert tidak diimport, parse manual untuk sederhana
    // hanya untuk { "photos": [...], "success": true }
    if (json.contains('"success":true')) {
      final start = json.indexOf('"photos":[');
      if (start != -1) {
        final end = json.indexOf(']', start);
        if (end != -1) {
          final photosStr = json.substring(start + 10, end + 1);
          return {'photos': _parsePhotoArray(photosStr)};
        }
      }
    }
    return {};
  }

  static List<Map<String, dynamic>> _parsePhotoArray(String arr) {
    final photos = <Map<String, dynamic>>[];
    var i = 1;
    while (i < arr.length - 1) {
      final objStart = arr.indexOf('{', i);
      if (objStart == -1) break;
      final objEnd = arr.indexOf('}', objStart);
      if (objEnd == -1) break;

      final obj = arr.substring(objStart, objEnd + 1);
      final keyMatch = RegExp(r'"key":"([^"]+)"').firstMatch(obj);
      final timeMatch = RegExp(r'"uploadedAt":"([^"]+)"').firstMatch(obj);

      if (keyMatch != null && timeMatch != null) {
        photos.add({
          'key': keyMatch.group(1),
          'uploadedAt': timeMatch.group(1),
        });
      }

      i = objEnd + 1;
    }
    return photos;
  }
}

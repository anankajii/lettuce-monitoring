import 'dart:convert';
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

    print('[DEBUG CloudflareService] Downloading: $key');
    // Encode each path segment. Encoding whole key turns `/` into `%2F`,
    // which makes Cloudflare Worker route miss the image key.
    final encodedKey = key.split('/').map(Uri.encodeComponent).join('/');
    final res = await http.get(
      Uri.parse('$_baseUrl/image/$encodedKey'),
      headers: {'Authorization': 'Bearer $authToken'},
    ).timeout(const Duration(seconds: 30));

    final bytes = res.bodyBytes;
        print('[DEBUG CloudflareService] Download status: ${res.statusCode}, size: ${bytes.length}, content-type: ${res.headers['content-type']}');
        if (res.statusCode != 200) {
          throw Exception('Failed to download photo: ${res.statusCode}');
        }
        if (!_looksLikeImage(bytes)) {
          final preview = utf8.decode(bytes, allowMalformed: true).trim();
          if (_isJsonError(preview)) {
            throw Exception('Cloudflare error response: $preview');
          }
          throw Exception('Cloudflare returned invalid image (${bytes.length} bytes): $preview');
        }

    // Keep downloaded images in app cache, not shared system temp.
    final dir = await Directory.systemTemp.createTemp('lettuce_cf_');
    final safeName = key.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final file = File('${dir.path}/$safeName');
    await file.writeAsBytes(res.bodyBytes);
    print('[DEBUG CloudflareService] Saved to: ${file.path}');
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

  static bool _looksLikeImage(List<int> bytes) {
      if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
      if (bytes.length >= 8 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
      if (bytes.length >= 6 && String.fromCharCodes(bytes.take(6)) == 'GIF89a') return true;
      if (bytes.length >= 6 && String.fromCharCodes(bytes.take(6)) == 'GIF87a') return true;
      return false;
    }

    static bool _isJsonError(String preview) {
      final lowered = preview.toLowerCase();
      return lowered.contains('object getresult') ||
          lowered.contains('error') ||
          lowered.contains('not found') ||
          lowered.contains('invalid');
    }

    static dynamic _parseJson(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return <String, dynamic>{};
    }
  }
}

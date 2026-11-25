import 'dart:io';

import '../models/plant_detection.dart';
import '../services/cloudflare_service.dart';
import '../services/firebase_service.dart';
import '../services/plant_classifier.dart';

class PhotoAnalysisService {
  static final PhotoAnalysisService _instance = PhotoAnalysisService._();

  factory PhotoAnalysisService() => _instance;
  PhotoAnalysisService._();

  final _cf = CloudflareService();
  final _fb = FirebaseService();
  final _classifier = PlantClassifier();

  /// Download foto dari Cloudflare → classify → simpan ke Firebase
  Future<PlantDetection> analyzeFromCloudflare(String photoKey, {String? token}) async {
    // 1. Download foto
    final file = await _cf.downloadPhoto(photoKey, token: token);

    // 2. Validate file size
    final fileSize = await file.length();
    if (fileSize == 0) {
      throw Exception('Downloaded file is empty');
    }

    // 3. Classify
    try {
      final classification = await _classifier.classify(file);

      // 4. Simpan metadata ke Firebase
      final detection = PlantDetection(
        label: classification.label,
        confidence: classification.confidence,
        createdAt: DateTime.now(),
        imagePath: file.path,
      );
      await _saveDetectionToFirebase(detection, photoKey);

      return detection;
    } catch (e) {
      throw Exception('Image classification failed: $e');
    }
  }

  /// Get latest foto & auto-analyze
  Future<PlantDetection?> analyzeLatestPhoto({String? token}) async {
    try {
      final photos = await _cf.listPhotos(token: token);
      if (photos.isEmpty) return null;

      // ponytail: ambil foto terbaru (assume sorted by uploadedAt desc)
      final latest = photos.last;
      return analyzeFromCloudflare(latest.key, token: token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveDetectionToFirebase(
    PlantDetection detection,
    String photoKey,
  ) async {
    // Simpan ke: detections/{timestamp}/{photoKey}
    // Nanti bisa query by date atau filter by label
    final ts = DateTime.now().millisecondsSinceEpoch;
    // TODO: implementasi save ke Firebase jika sudah ada endpoint
  }
}

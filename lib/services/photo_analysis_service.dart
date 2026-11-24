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
  Future<PlantDetection> analyzeFromCloudflare(String photoKey) async {
    // 1. Download foto
    final file = await _cf.downloadPhoto(photoKey);

    // 2. Classify
    final classification = await _classifier.classify(file);

    // 3. Simpan metadata ke Firebase
    final detection = PlantDetection(
      label: classification.label,
      confidence: classification.confidence,
      createdAt: DateTime.now(),
      imagePath: file.path,
    );
    await _saveDetectionToFirebase(detection, photoKey);

    return detection;
  }

  /// Get latest foto & auto-analyze
  Future<PlantDetection?> analyzeLatestPhoto() async {
    try {
      final photos = await _cf.listPhotos();
      if (photos.isEmpty) return null;

      // ponytail: ambil foto terbaru (assume sorted by uploadedAt desc)
      final latest = photos.first;
      return analyzeFromCloudflare(latest.key);
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

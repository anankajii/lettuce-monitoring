import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';

class PlantClassification {
  const PlantClassification({required this.label, required this.confidence});

  final String label;
  final double confidence;
}

/// YOLOv8 detector exported to ONNX with embedded NMS.
/// Output rows are [x1, y1, x2, y2, confidence, classId].
class PlantClassifier {
  static const _labels = ['healthy', 'unhealthy'];
  static const _asset = 'assets/models/lettuce_detector.onnx';
  static const _size = 640;

  OrtSession? _session;
  OrtSessionOptions? _options;

  Future<void> load() async {
    if (_session != null) return;
    OrtEnv.instance.init();
    _options = OrtSessionOptions();
    final data = await rootBundle.load(_asset);
    _session = OrtSession.fromBuffer(data.buffer.asUint8List(), _options!);
  }

  Future<PlantClassification> classify(File file) async {
    await load();
    final decoded = img.decodeImage(await file.readAsBytes());
    if (decoded == null) throw const FormatException('Gambar tidak valid');

    final resized = img.copyResize(decoded, width: _size, height: _size);
    // ONNX input is NCHW float32, RGB normalized to 0..1.
    final input = List<double>.filled(1 * 3 * _size * _size, 0);
    final plane = _size * _size;
    for (var y = 0; y < _size; y++) {
      for (var x = 0; x < _size; x++) {
        final p = resized.getPixel(x, y);
        final i = y * _size + x;
        input[i] = p.r / 255.0;
        input[plane + i] = p.g / 255.0;
        input[2 * plane + i] = p.b / 255.0;
      }
    }

    final inputValue = OrtValueTensor.createTensorWithDataList(input, [
      1,
      3,
      _size,
      _size,
    ]);
    final runOptions = OrtRunOptions();
    try {
      final outputs = await _session!.runAsync(runOptions, {
        _session!.inputNames.first: inputValue,
      });
      if (outputs == null || outputs.isEmpty)
        throw StateError('Output model kosong');
      final output = outputs.first;
      if (output == null) throw StateError('Output model kosong');
      final values = output.value as List;
      final rows = _flatten(values).map((e) => (e as num).toDouble()).toList();

      var bestClass = 0;
      var bestConfidence = 0.0;
      for (var i = 0; i + 5 < rows.length; i += 6) {
        final confidence = rows[i + 4].clamp(0.0, 1.0);
        final classId = rows[i + 5].round();
        if (classId >= 0 &&
            classId < _labels.length &&
            confidence > bestConfidence) {
          bestConfidence = confidence;
          bestClass = classId;
        }
      }
      if (bestConfidence == 0) {
        return const PlantClassification(
          label: 'Tidak terdeteksi',
          confidence: 0,
        );
      }
      return PlantClassification(
        label: _labels[bestClass],
        confidence: bestConfidence,
      );
    } finally {
      inputValue.release();
      runOptions.release();
      for (final output in _session == null ? <OrtValue?>[] : []) {
        output?.release();
      }
    }
  }

  Iterable<dynamic> _flatten(dynamic value) sync* {
    if (value is List) {
      for (final item in value) yield* _flatten(item);
    } else {
      yield value;
    }
  }

  void dispose() {
    _session?.release();
    _session = null;
    _options?.release();
    _options = null;
    OrtEnv.instance.release();
  }
}

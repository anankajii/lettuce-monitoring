import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

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
  // v5 classes: 0=healthy, 1=unhealthy.
  static const _labelMap = {0: 'healthy', 1: 'unhealthy'};
  static const _asset = 'assets/models/lettuce_yolov8_v5.onnx';
  static const _confidenceThreshold = 0.35;
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

    final scale = math.min(_size / decoded.width, _size / decoded.height);
    final resizedWidth = (decoded.width * scale).round();
    final resizedHeight = (decoded.height * scale).round();
    final resized = img.copyResize(
      decoded,
      width: resizedWidth,
      height: resizedHeight,
    );
    final canvas = img.Image(width: _size, height: _size);
    img.fill(canvas, color: img.ColorRgb8(114, 114, 114));
    final left = ((_size - resizedWidth) / 2).round();
    final top = ((_size - resizedHeight) / 2).round();
    img.compositeImage(canvas, resized, dstX: left, dstY: top);
    // ONNX input is NCHW float32, RGB normalized to 0..1.
    final input = Float32List(1 * 3 * _size * _size);
    final plane = _size * _size;
    for (var y = 0; y < _size; y++) {
      for (var x = 0; x < _size; x++) {
        final p = canvas.getPixel(x, y);
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

      // YOLOv8 raw output shape: [1, 6, 8400] = x,y,w,h,class0,class1.
      const candidates = 8400;
      var bestClass = 0;
      var bestConfidence = 0.0;
      for (var i = 0; i < candidates; i++) {
        var classId = 0;
        var confidence = rows[4 * candidates + i];
        for (var c = 1; c < _labelMap.length; c++) {
          final score = rows[(4 + c) * candidates + i];
          if (score > confidence) {
            confidence = score;
            classId = c;
          }
        }
        if (confidence >= _confidenceThreshold && confidence > bestConfidence) {
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
        label: _labelMap[bestClass]!,
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

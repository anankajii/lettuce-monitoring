import 'package:flutter/material.dart';

import '../config/sensor_thresholds.dart';
import '../../models/sensor_reading.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum
// ─────────────────────────────────────────────────────────────────────────────

enum SensorStatus { normal, warning, danger, unknown }

enum OverallStatus { good, needsAttention, actionRequired, noData }

// ─────────────────────────────────────────────────────────────────────────────
// Model hasil evaluasi
// ─────────────────────────────────────────────────────────────────────────────

class ParameterResult {
  const ParameterResult({
    required this.status,
    required this.scalePct,
    this.recommendation,
  });

  final SensorStatus status;
  final double scalePct; // 0.0–1.0
  final String? recommendation;
}

class OverallResult {
  const OverallResult({
    required this.status,
    required this.normalCount,
    required this.warningCount,
    required this.dangerCount,
    required this.unknownCount,
    required this.totalCount,
    required this.affectedParams,
  });

  final OverallStatus status;
  final int normalCount;
  final int warningCount;
  final int dangerCount;
  final int unknownCount;
  final int totalCount;
  final List<String> affectedParams;

  int get readableCount => normalCount + warningCount + dangerCount;

  String get title {
    switch (status) {
      case OverallStatus.good:           return 'Kondisi Baik';
      case OverallStatus.needsAttention: return 'Perlu Perhatian';
      case OverallStatus.actionRequired: return 'Tindakan Diperlukan';
      case OverallStatus.noData:         return 'Menunggu Data';
    }
  }

  String get description {
    switch (status) {
      case OverallStatus.good:
        return 'Semua parameter dalam rentang normal.';
      case OverallStatus.needsAttention:
        return '${affectedParams.join(", ")} perlu diperhatikan.';
      case OverallStatus.actionRequired:
        return '${affectedParams.join(", ")} di luar batas. Segera periksa.';
      case OverallStatus.noData:
        return 'Belum ada data sensor dari perangkat.';
    }
  }

  Color get color {
    switch (status) {
      case OverallStatus.good:           return const Color(0xFF16845B);
      case OverallStatus.needsAttention: return const Color(0xFFF59E0B);
      case OverallStatus.actionRequired: return const Color(0xFFDC2626);
      case OverallStatus.noData:         return const Color(0xFF9CA3AF);
    }
  }

  IconData get icon {
    switch (status) {
      case OverallStatus.good:           return Icons.check_circle_rounded;
      case OverallStatus.needsAttention: return Icons.info_rounded;
      case OverallStatus.actionRequired: return Icons.warning_rounded;
      case OverallStatus.noData:         return Icons.sensors_off_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Evaluator
// ─────────────────────────────────────────────────────────────────────────────

class SensorEvaluator {
  const SensorEvaluator._();

  static double _pct(double? v, double min, double max) {
    if (v == null) return 0;
    return ((v - min) / (max - min)).clamp(0.0, 1.0);
  }

  static ParameterResult evaluatePh(double? v) {
    final pct = _pct(v, SensorThresholds.phScaleMin, SensorThresholds.phScaleMax);
    if (v == null) return const ParameterResult(status: SensorStatus.unknown, scalePct: 0);
    if (v < SensorThresholds.phMin) {
      return ParameterResult(
        status: SensorStatus.danger, scalePct: pct,
        recommendation: 'Naikkan pH menggunakan larutan pH up.',
      );
    }
    if (v > SensorThresholds.phMax) {
      return ParameterResult(
        status: SensorStatus.danger, scalePct: pct,
        recommendation: 'Turunkan pH menggunakan larutan pH down.',
      );
    }
    if (v < SensorThresholds.phMin + SensorThresholds.phWarning ||
        v > SensorThresholds.phMax - SensorThresholds.phWarning) {
      return ParameterResult(status: SensorStatus.warning, scalePct: pct);
    }
    return ParameterResult(status: SensorStatus.normal, scalePct: pct);
  }

  static ParameterResult evaluateTds(double? v) {
    final pct = _pct(v, SensorThresholds.tdsScaleMin, SensorThresholds.tdsScaleMax);
    if (v == null) return const ParameterResult(status: SensorStatus.unknown, scalePct: 0);
    final warn = SensorThresholds.tdsMax * SensorThresholds.tdsWarning;
    if (v < SensorThresholds.tdsMin) {
      return ParameterResult(
        status: SensorStatus.danger, scalePct: pct,
        recommendation: 'TDS rendah. Tambahkan larutan nutrisi.',
      );
    }
    if (v > SensorThresholds.tdsMax) {
      return ParameterResult(
        status: SensorStatus.danger, scalePct: pct,
        recommendation: 'TDS tinggi. Tambahkan air baku.',
      );
    }
    if (v < SensorThresholds.tdsMin + warn || v > SensorThresholds.tdsMax - warn) {
      return ParameterResult(status: SensorStatus.warning, scalePct: pct);
    }
    return ParameterResult(status: SensorStatus.normal, scalePct: pct);
  }

  static ParameterResult evaluateWaterTemp(double? v) {
    final pct = _pct(v, SensorThresholds.waterTempScaleMin, SensorThresholds.waterTempScaleMax);
    if (v == null) return const ParameterResult(status: SensorStatus.unknown, scalePct: 0);
    if (v > SensorThresholds.waterTempMax) {
      return ParameterResult(
        status: SensorStatus.danger, scalePct: pct,
        recommendation: 'Suhu air tinggi. Nyalakan aerator atau kipas tandon.',
      );
    }
    if (v >= SensorThresholds.waterTempMax - SensorThresholds.waterTempWarning) {
      return ParameterResult(
        status: SensorStatus.warning, scalePct: pct,
        recommendation: 'Suhu air mendekati batas. Pantau aerator.',
      );
    }
    return ParameterResult(status: SensorStatus.normal, scalePct: pct);
  }

  static ParameterResult evaluateHumidity(double? v) {
    final pct = _pct(v, SensorThresholds.humidityScaleMin, SensorThresholds.humidityScaleMax);
    if (v == null) return const ParameterResult(status: SensorStatus.unknown, scalePct: 0);
    if (v < SensorThresholds.humidityMin || v > SensorThresholds.humidityMax) {
      return ParameterResult(status: SensorStatus.danger, scalePct: pct);
    }
    return ParameterResult(status: SensorStatus.normal, scalePct: pct);
  }

  static ParameterResult evaluateAirTemp(double? v) {
    final pct = _pct(v, SensorThresholds.airTempScaleMin, SensorThresholds.airTempScaleMax);
    if (v == null) return const ParameterResult(status: SensorStatus.unknown, scalePct: 0);
    if (v < SensorThresholds.airTempMin || v > SensorThresholds.airTempMax) {
      return ParameterResult(status: SensorStatus.danger, scalePct: pct);
    }
    return ParameterResult(status: SensorStatus.normal, scalePct: pct);
  }

  static OverallResult evaluateOverall(SensorReading? reading) {
    if (reading == null) {
      return const OverallResult(
        status: OverallStatus.noData,
        normalCount: 0, warningCount: 0, dangerCount: 0,
        unknownCount: 0, totalCount: 0, affectedParams: [],
      );
    }
    final map = {
      'pH Air': evaluatePh(reading.ph),
      'TDS': evaluateTds(reading.tds),
      'Suhu Air': evaluateWaterTemp(reading.waterTemperature),
      'Kelembapan': evaluateHumidity(reading.airHumidity),
    };
    int n = 0, w = 0, d = 0, u = 0;
    final affected = <String>[];
    for (final e in map.entries) {
      switch (e.value.status) {
        case SensorStatus.normal:  n++;
        case SensorStatus.warning: w++; affected.add(e.key);
        case SensorStatus.danger:  d++; affected.add(e.key);
        case SensorStatus.unknown: u++;
      }
    }
    final OverallStatus overall;
    if (d > 0) {
      overall = OverallStatus.actionRequired;
    } else if (w > 0) {
      overall = OverallStatus.needsAttention;
    } else if (n > 0) {
      overall = OverallStatus.good;
    } else {
      overall = OverallStatus.noData;
    }
    return OverallResult(
      status: overall, normalCount: n, warningCount: w,
      dangerCount: d, unknownCount: u, totalCount: map.length,
      affectedParams: affected,
    );
  }

  static bool isStale(DateTime ts) =>
      DateTime.now().difference(ts).inMinutes > SensorThresholds.staleThresholdMinutes;
}

// ─────────────────────────────────────────────────────────────────────────────
// UI extensions
// ─────────────────────────────────────────────────────────────────────────────

extension SensorStatusX on SensorStatus {
  Color get color {
    switch (this) {
      case SensorStatus.normal:  return const Color(0xFF16845B);
      case SensorStatus.warning: return const Color(0xFFF59E0B);
      case SensorStatus.danger:  return const Color(0xFFDC2626);
      case SensorStatus.unknown: return const Color(0xFF9CA3AF);
    }
  }

  Color get bgColor {
    switch (this) {
      case SensorStatus.normal:  return const Color(0xFFE8F5EF);
      case SensorStatus.warning: return const Color(0xFFFFFBEB);
      case SensorStatus.danger:  return const Color(0xFFFEF2F2);
      case SensorStatus.unknown: return const Color(0xFFF3F4F6);
    }
  }

  String get label {
    switch (this) {
      case SensorStatus.normal:  return 'Normal';
      case SensorStatus.warning: return 'Perlu Cek';
      case SensorStatus.danger:  return 'Di Luar Batas';
      case SensorStatus.unknown: return 'Tidak Terbaca';
    }
  }
}

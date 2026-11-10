import 'package:flutter/material.dart';

import '../core/config/sensor_thresholds.dart';
import '../core/domain/sensor_evaluator.dart';
import '../models/sensor_reading.dart';

/// Layar Monitor — 5 kartu sensor dengan nilai, status, progress bar.
/// [reading] null = belum ada data. Diisi dari Firebase nanti.
class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({
    super.key,
    this.reading,
    this.isLoading = false,
    this.lastSynced,
    this.onRefresh,
  });

  final SensorReading? reading;
  final bool isLoading;
  final DateTime? lastSynced;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F2),
        elevation: 0,
        title: const Text('Sensor',
            style:
                TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          // Timestamp + tombol refresh
          Row(
            children: [
              Expanded(
                child: Text(
                  lastSynced != null
                      ? 'Diperbarui pukul ${_fmt(lastSynced!)}'
                      : 'Belum ada data',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: isLoading ? null : onRefresh,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child:
                            CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Perbarui Data',
                    style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5 kartu sensor
          _SensorRow(
            icon: Icons.science_rounded,
            accent: const Color(0xFF7C3AED),
            label: 'pH Air',
            device: 'Analog pH Meter V1.1',
            value: reading?.ph?.toStringAsFixed(2),
            unit: 'pH',
            rangeText:
                'Ideal ${SensorThresholds.phMin}–${SensorThresholds.phMax}',
            result: SensorEvaluator.evaluatePh(reading?.ph),
          ),
          const SizedBox(height: 12),
          _SensorRow(
            icon: Icons.water_drop_rounded,
            accent: const Color(0xFF0891B2),
            label: 'TDS Nutrisi',
            device: 'Gravity Analog TDS',
            value: reading?.tds?.toStringAsFixed(0),
            unit: 'ppm',
            rangeText:
                'Ideal ${SensorThresholds.tdsMin.toInt()}–${SensorThresholds.tdsMax.toInt()} ppm',
            result: SensorEvaluator.evaluateTds(reading?.tds),
          ),
          const SizedBox(height: 12),
          _SensorRow(
            icon: Icons.device_thermostat_rounded,
            accent: const Color(0xFF2878C8),
            label: 'Suhu Air',
            device: 'DS18B20',
            value: reading?.waterTemperature?.toStringAsFixed(1),
            unit: '°C',
            rangeText:
                'Batas maks ${SensorThresholds.waterTempMax} °C',
            result: SensorEvaluator.evaluateWaterTemp(
                reading?.waterTemperature),
          ),
          const SizedBox(height: 12),
          _SensorRow(
            icon: Icons.thermostat_rounded,
            accent: const Color(0xFFE7683F),
            label: 'Suhu Udara',
            device: 'DHT22',
            value: reading?.airTemperature?.toStringAsFixed(1),
            unit: '°C',
            rangeText:
                'Ideal ${SensorThresholds.airTempMin.toInt()}–${SensorThresholds.airTempMax.toInt()} °C',
            result: SensorEvaluator.evaluateAirTemp(
                reading?.airTemperature),
          ),
          const SizedBox(height: 12),
          _SensorRow(
            icon: Icons.water_outlined,
            accent: const Color(0xFF059669),
            label: 'Kelembapan Udara',
            device: 'DHT22',
            value: reading?.airHumidity?.toStringAsFixed(1),
            unit: '%',
            rangeText:
                'Ideal ${SensorThresholds.humidityMin.toInt()}–${SensorThresholds.humidityMax.toInt()} %',
            result: SensorEvaluator.evaluateHumidity(
                reading?.airHumidity),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}:'
        '${l.second.toString().padLeft(2, '0')}';
  }
}

class _SensorRow extends StatelessWidget {
  const _SensorRow({
    required this.icon,
    required this.accent,
    required this.label,
    required this.device,
    required this.value,
    required this.unit,
    required this.rangeText,
    required this.result,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String device;
  final String? value;
  final String unit;
  final String rangeText;
  final ParameterResult result;

  @override
  Widget build(BuildContext context) {
    final s = result.status;
    final pct = result.scalePct;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827))),
                    Text(device,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              // Badge status
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: s.bgColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(s.label,
                    style: TextStyle(
                        color: s.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nilai besar
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value ?? '—',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: value == null
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(unit,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280))),
              ),
              const Spacer(),
              Text(
                '${(pct * 100).toStringAsFixed(0)}% Skala',
                style: TextStyle(
                    fontSize: 12,
                    color: s.color,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation(s.color),
            ),
          ),
          const SizedBox(height: 8),
          Text(rangeText,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF))),

          // Rekomendasi jika ada
          if (result.recommendation != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: s.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      color: s.color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(result.recommendation!,
                        style: TextStyle(
                            color: s.color, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

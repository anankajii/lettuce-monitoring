import 'package:flutter/material.dart';

import '../core/config/sensor_thresholds.dart';
import '../core/domain/sensor_evaluator.dart';
import '../models/sensor_reading.dart';

/// Layar Analisis — evaluasi keseluruhan + detail per parameter.
/// [reading] null = belum ada data. Diisi dari Firebase nanti.
class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({
    super.key,
    this.reading,
    this.lastDetectionLabel,
    this.lastDetectionConfidence,
    this.lastDetectionTime,
    this.onOpenDetection,
  });

  final SensorReading? reading;

  /// Label hasil deteksi terakhir, mis. 'healthy' / 'unhealthy'
  final String? lastDetectionLabel;
  final double? lastDetectionConfidence;
  final DateTime? lastDetectionTime;
  final VoidCallback? onOpenDetection;

  @override
  Widget build(BuildContext context) {
    final overall = SensorEvaluator.evaluateOverall(reading);
    final ph      = SensorEvaluator.evaluatePh(reading?.ph);
    final tds     = SensorEvaluator.evaluateTds(reading?.tds);
    final wTemp   = SensorEvaluator.evaluateWaterTemp(reading?.waterTemperature);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      body: CustomScrollView(
        slivers: [
          // Banner gradient
          SliverToBoxAdapter(child: _AnalysisBanner(overall: overall)),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Dua kartu ringkasan
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: overall.icon,
                        color: overall.color,
                        title: overall.title,
                        subtitle: overall.description,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.monitor_heart_rounded,
                        color: const Color(0xFF0891B2),
                        title:
                            '${overall.readableCount}/${overall.totalCount} Parameter',
                        subtitle:
                            '${overall.normalCount} normal · ${overall.warningCount} perlu cek · ${overall.dangerCount} di luar batas',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text('Detail Evaluasi Sensor',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                // Kartu expandable per parameter
                _ExpandableParam(
                  label: 'pH Air',
                  result: ph,
                  summary: reading?.ph != null
                      ? 'pH ${reading!.ph!.toStringAsFixed(2)} '
                        '${ph.status == SensorStatus.danger ? "di luar" : "di dalam"} '
                        'rentang ${SensorThresholds.phMin}–${SensorThresholds.phMax}'
                      : 'Tidak ada data pH',
                  details: [
                    _Detail('Terukur',
                        reading?.ph?.toStringAsFixed(2) ?? '—', 'pH'),
                    _Detail('Rentang ideal',
                        '${SensorThresholds.phMin}–${SensorThresholds.phMax}',
                        'pH'),
                    _Detail('Status', ph.status.label, ''),
                  ],
                  recommendation: ph.recommendation,
                ),
                const SizedBox(height: 10),

                _ExpandableParam(
                  label: 'Nutrisi TDS',
                  result: tds,
                  summary: reading?.tds != null
                      ? '${reading!.tds!.toStringAsFixed(0)} ppm '
                        '${tds.status == SensorStatus.danger ? "di luar" : "dalam"} '
                        'target ${SensorThresholds.tdsMin.toInt()}–${SensorThresholds.tdsMax.toInt()} ppm'
                      : 'Tidak ada data TDS',
                  details: [
                    _Detail('Terukur',
                        reading?.tds?.toStringAsFixed(0) ?? '—', 'ppm'),
                    _Detail('Target',
                        '${SensorThresholds.tdsMin.toInt()}–${SensorThresholds.tdsMax.toInt()}',
                        'ppm'),
                    _Detail('Status', tds.status.label, ''),
                  ],
                  recommendation: tds.recommendation,
                ),
                const SizedBox(height: 10),

                _ExpandableParam(
                  label: 'Suhu Air',
                  result: wTemp,
                  summary: reading?.waterTemperature != null
                      ? '${reading!.waterTemperature!.toStringAsFixed(1)} °C, '
                        'batas ${SensorThresholds.waterTempMax} °C'
                      : 'Tidak ada data suhu air',
                  details: [
                    _Detail('Terukur',
                        reading?.waterTemperature?.toStringAsFixed(1) ?? '—',
                        '°C'),
                    _Detail('Batas maks',
                        '${SensorThresholds.waterTempMax}', '°C'),
                    _Detail('Status', wTemp.status.label, ''),
                  ],
                  recommendation: wTemp.recommendation,
                ),
                const SizedBox(height: 10),

                // Kondisi Tanaman
                _PlantConditionCard(
                  label: lastDetectionLabel,
                  confidence: lastDetectionConfidence,
                  detectedAt: lastDetectionTime,
                  onOpenDetection: onOpenDetection,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banner ────────────────────────────────────────────────────────────────────

class _AnalysisBanner extends StatelessWidget {
  const _AnalysisBanner({required this.overall});
  final OverallResult overall;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF16845B), Color(0xFF2FA778)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analisis Sistem',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    Text('Evaluasi kondisi hidroponik',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Icon(overall.icon, color: Colors.white, size: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

// ── Expandable Parameter ──────────────────────────────────────────────────────

class _Detail {
  const _Detail(this.label, this.value, this.unit);
  final String label;
  final String value;
  final String unit;
}

class _ExpandableParam extends StatefulWidget {
  const _ExpandableParam({
    required this.label,
    required this.result,
    required this.summary,
    required this.details,
    this.recommendation,
  });
  final String label;
  final ParameterResult result;
  final String summary;
  final List<_Detail> details;
  final String? recommendation;

  @override
  State<_ExpandableParam> createState() => _ExpandableParamState();
}

class _ExpandableParamState extends State<_ExpandableParam> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.result.status;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.label,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        Text(widget.summary,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
          if (_open) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  ...widget.details.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(d.label,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280)))),
                            Text(
                                '${d.value}${d.unit.isNotEmpty ? " ${d.unit}" : ""}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )),
                  if (widget.recommendation != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: s.bgColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded,
                              color: s.color, size: 15),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(widget.recommendation!,
                                style: TextStyle(
                                    color: s.color, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Plant Condition Card ───────────────────────────────────────────────────────

class _PlantConditionCard extends StatelessWidget {
  const _PlantConditionCard({
    required this.label,
    required this.confidence,
    required this.detectedAt,
    required this.onOpenDetection,
  });
  final String? label;
  final double? confidence;
  final DateTime? detectedAt;
  final VoidCallback? onOpenDetection;

  bool get _hasData => label != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _hasData
                      ? const Color(0xFFE8F5EF)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _hasData ? (label ?? '') : 'Menunggu data',
                  style: TextStyle(
                    color: _hasData
                        ? const Color(0xFF16845B)
                        : const Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kondisi Tanaman',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text('Hasil deteksi terakhir',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280))),
                  ],
                ),
              ),
            ],
          ),
          if (_hasData) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (confidence != null)
              Row(
                children: [
                  const Expanded(
                      child: Text('Keyakinan',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280)))),
                  Text(
                      '${(confidence! * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            if (detectedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                      child: Text('Waktu deteksi',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280)))),
                  Text(_fmtDateTime(detectedAt!),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenDetection,
              icon: const Icon(Icons.camera_alt_rounded, size: 16),
              label: const Text('Buka Kamera Deteksi'),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDateTime(DateTime t) {
    final l = t.toLocal();
    return '${l.day}/${l.month}/${l.year} '
        '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }
}

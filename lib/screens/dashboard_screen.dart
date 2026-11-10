import 'package:flutter/material.dart';

import '../core/config/sensor_thresholds.dart';
import '../core/domain/sensor_evaluator.dart';
import '../models/sensor_reading.dart';

/// Beranda.
/// [reading] null = belum ada data. Diisi dari Firebase nanti.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.reading,
    this.isLoading = false,
    this.lastSynced,
    this.onSync,
  });

  final SensorReading? reading;
  final bool isLoading;
  final DateTime? lastSynced;
  final VoidCallback? onSync;

  @override
  Widget build(BuildContext context) {
    final overall = SensorEvaluator.evaluateOverall(reading);
    final stale   = reading != null && SensorEvaluator.isStale(reading!.timestamp);
    final online  = reading != null && !stale;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroBanner(overall: overall, online: online, stale: stale),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionHeader(
                  title: 'Kondisi Terkini',
                  subtitle: 'Hidroponik Utama',
                  trailing: _SyncButton(
                    isLoading: isLoading,
                    lastSynced: lastSynced ?? reading?.timestamp,
                    onSync: onSync,
                  ),
                ),
                const SizedBox(height: 14),
                _SensorGrid(reading: reading),
                const SizedBox(height: 16),
                _DiagnosticCard(overall: overall),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.overall,
    required this.online,
    required this.stale,
  });

  final OverallResult overall;
  final bool online;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16845B), Color(0xFF2FA778)],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar row
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lettuce Monitor',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        Text('Smart Hydroponic System',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_outline_rounded,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Glass card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge lokasi + koneksi
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        const Text('Hidroponik Utama',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(width: 10),
                        _OnlineBadge(online: online, stale: stale),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Status keseluruhan
                    Row(
                      children: [
                        Icon(overall.icon, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(overall.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              Text(overall.description,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Counter chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(
                            label: 'Normal',
                            count: overall.normalCount,
                            color: const Color(0xFF4ADE80)),
                        _StatusChip(
                            label: 'Perlu Cek',
                            count: overall.warningCount,
                            color: const Color(0xFFFBBF24)),
                        _StatusChip(
                            label: 'Di Luar Batas',
                            count: overall.dangerCount,
                            color: const Color(0xFFF87171)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge({required this.online, required this.stale});
  final bool online;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final label = stale ? 'Data Basi' : online ? 'Online' : 'Offline';
    final dot = online && !stale
        ? const Color(0xFF4ADE80)
        : Colors.white38;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(
      {required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Singkatan label kalau terlalu panjang
    final shortLabel = label == 'Di Luar Batas' ? 'Luar' : label;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text('$count',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 2),
          Flexible(
            child: Text(shortLabel,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.title, required this.subtitle, this.trailing});
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

// ── Sync Button ───────────────────────────────────────────────────────────────

class _SyncButton extends StatelessWidget {
  const _SyncButton(
      {required this.isLoading, required this.onSync, this.lastSynced});
  final bool isLoading;
  final DateTime? lastSynced;
  final VoidCallback? onSync;

  String get _label {
    if (lastSynced == null) return 'Belum disinkron';
    final t = lastSynced!.toLocal();
    return 'Diperbarui '
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FilledButton.tonalIcon(
          onPressed: isLoading ? null : onSync,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.sync_rounded, size: 16),
          label: const Text('Sync', style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(height: 4),
        Text(_label,
            style:
                const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}

// ── Sensor Grid ───────────────────────────────────────────────────────────────

class _SensorGrid extends StatelessWidget {
  const _SensorGrid({required this.reading});
  final SensorReading? reading;

  @override
  Widget build(BuildContext context) {
    final items = [
      _CardData(
        label: 'pH Air',
        value: reading?.ph?.toStringAsFixed(1),
        unit: 'pH',
        icon: Icons.science_rounded,
        accent: const Color(0xFF7C3AED),
        result: SensorEvaluator.evaluatePh(reading?.ph),
        range:
            '${SensorThresholds.phMin}–${SensorThresholds.phMax}',
      ),
      _CardData(
        label: 'TDS Nutrisi',
        value: reading?.tds?.toStringAsFixed(0),
        unit: 'ppm',
        icon: Icons.water_drop_rounded,
        accent: const Color(0xFF0891B2),
        result: SensorEvaluator.evaluateTds(reading?.tds),
        range:
            '${SensorThresholds.tdsMin.toInt()}–${SensorThresholds.tdsMax.toInt()} ppm',
      ),
      _CardData(
        label: 'Suhu Air',
        value: reading?.waterTemperature?.toStringAsFixed(1),
        unit: '°C',
        icon: Icons.device_thermostat_rounded,
        accent: const Color(0xFF2878C8),
        result: SensorEvaluator.evaluateWaterTemp(reading?.waterTemperature),
        range: '≤ ${SensorThresholds.waterTempMax} °C',
      ),
      _CardData(
        label: 'Kelembapan',
        value: reading?.airHumidity?.toStringAsFixed(1),
        unit: '%',
        icon: Icons.water_outlined,
        accent: const Color(0xFFE7683F),
        result: SensorEvaluator.evaluateHumidity(reading?.airHumidity),
        range:
            '${SensorThresholds.humidityMin.toInt()}–${SensorThresholds.humidityMax.toInt()} %',
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: items.map((d) => _SensorCard(data: d)).toList(),
    );
  }
}

class _CardData {
  const _CardData({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accent,
    required this.result,
    required this.range,
  });
  final String label;
  final String? value;
  final String unit;
  final IconData icon;
  final Color accent;
  final ParameterResult result;
  final String range;
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({required this.data});
  final _CardData data;

  @override
  Widget build(BuildContext context) {
    final s = data.result.status;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: data.accent, size: 18),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: s.bgColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(s.label,
                    style: TextStyle(
                        color: s.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Spacer(),
          Text(
            data.value ?? '—',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: data.value == null
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF111827),
            ),
          ),
          Text(data.unit,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.result.scalePct,
              minHeight: 5,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation(s.color),
            ),
          ),
          const SizedBox(height: 6),
          Text(data.label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          Text(data.range,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

// ── Diagnostic Card ───────────────────────────────────────────────────────────

class _DiagnosticCard extends StatelessWidget {
  const _DiagnosticCard({required this.overall});
  final OverallResult overall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: overall.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(overall.icon, color: overall.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(overall.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(overall.description,
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 13)),
                if (overall.readableCount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${overall.readableCount}/${overall.totalCount} parameter terbaca',
                    style: TextStyle(
                        fontSize: 12,
                        color: overall.color,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/sensor_reading.dart';
import '../core/config/sensor_thresholds.dart';
import '../core/domain/sensor_evaluator.dart';

/// Layar Riwayat — tab Sensor (timeline) + tab Tanaman (log deteksi).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  String _selectedDuration = '24 jam';
  DateTime _startDate = DateTime.now().subtract(const Duration(hours: 24));
  DateTime _endDate = DateTime.now();

  final List<String> _durations = ['24 jam', '7 hari', '30 hari'];

  void _selectDuration(String? value) {
    if (value == null) return;
    setState(() {
      _selectedDuration = value;
      switch (value) {
        case '24 jam':
          _startDate = DateTime.now().subtract(const Duration(hours: 24));
          break;
        case '7 hari':
          _startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case '30 hari':
          _startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
      }
      _endDate = DateTime.now();
    });
  }

  String _fmtTime(DateTime dt) {
    final t = dt.toLocal();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
  }

  String _fmtDate(DateTime dt) {
    return DateFormat('d MMM yyyy', 'id_ID').format(dt.toLocal());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F2),
        elevation: 0,
        title: const Text('Riwayat', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
      ),
      body: Column(
        children: [
          // ── Filter & Tab Bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Duration selector (dropdown)
                Row(
                  children: [
                    const Text('Periode: ', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedDuration,
                      underline: const SizedBox(),
                      dropdownColor: Colors.white,
                      items: _durations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: _selectDuration,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tab bar container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: TabBar(
                    controller: _tab,
                    tabs: const [
                      Tab(text: 'Sensor'),
                      Tab(text: 'Tanaman'),
                    ],
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF6B7280),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    indicator: BoxDecoration(
                      color: const Color(0xFF16845B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),

          // ── Tab Views ─────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // Tab Sensor
                _SensorHistoryView(startDate: _startDate, endDate: _endDate),
                // Tab Tanaman
                _PlantHistoryView(startDate: _startDate, endDate: _endDate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sensor History View ────────────────────────────────────────────────────────

class _SensorHistoryView extends StatelessWidget {
  const _SensorHistoryView({required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) {
    // Simulasi data history (nanti dari Firebase)
    final logs = [
      _LogData(timestamp: DateTime.now().subtract(const Duration(hours: 1)), ph: 6.2, tds: 450, waterTemp: 24.5, airTemp: 28.0, humidity: 65.0),
      _LogData(timestamp: DateTime.now().subtract(const Duration(hours: 3)), ph: 6.3, tds: 460, waterTemp: 24.3, airTemp: 27.8, humidity: 64.5),
      _LogData(timestamp: DateTime.now().subtract(const Duration(hours: 5)), ph: 6.1, tds: 440, waterTemp: 24.8, airTemp: 28.2, humidity: 66.0),
    ];

    final filtered = logs.where((l) => l.timestamp.isAfter(startDate) && l.timestamp.isBefore(endDate)).toList();

    if (filtered.isEmpty) {
      return _EmptyState(
        icon: Icons.sensors_off_rounded,
        message: 'Belum ada data sensor pada rentang ini',
        shadowColor: Theme.of(context).colorScheme.primary,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _LogCard(log: filtered[i]),
    );
  }
}

class _LogData {
  final DateTime timestamp;
  final double? ph, tds, waterTemp, airTemp, humidity;
  _LogData({required this.timestamp, required this.ph, required this.tds, required this.waterTemp, required this.airTemp, required this.humidity});
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.log});

  final _LogData log;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_fmtDate(log.timestamp),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const Spacer(),
              Text(_fmtTime(log.timestamp),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SensorMini(label: 'pH', value: '${log.ph?.toStringAsFixed(1) ?? '—'}', unit: 'pH', color: const Color(0xFF7C3AED)),
              _SensorMini(label: 'TDS', value: '${log.tds?.toStringAsFixed(0) ?? '—'}', unit: 'ppm', color: const Color(0xFF0891B2)),
              _SensorMini(label: 'Air', value: '${log.waterTemp?.toStringAsFixed(1) ?? '—'}', unit: '°C', color: const Color(0xFF2878C8)),
              _SensorMini(label: 'Udara', value: '${log.airTemp?.toStringAsFixed(1) ?? '—'}', unit: '°C', color: const Color(0xFFE7683F)),
              _SensorMini(label: 'Humid', value: '${log.humidity?.toStringAsFixed(1) ?? '—'}', unit: '%', color: const Color(0xFF059669)),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final t = dt.toLocal();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
  }

  String _fmtDate(DateTime dt) {
    return DateFormat('d MMM yyyy', 'id_ID').format(dt.toLocal());
  }
}

class _SensorMini extends StatelessWidget {
  const _SensorMini({required this.label, required this.value, required this.unit, required this.color});

  final String label, value, unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.water_drop_rounded, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          Text('$label $unit', style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

// ── Plant History View ────────────────────────────────────────────────────────

class _PlantHistoryView extends StatelessWidget {
  const _PlantHistoryView({required this.startDate, required this.endDate});

  final DateTime startDate, endDate;

  @override
  Widget build(BuildContext context) {
    final logs = [
      _PlantLog(timestamp: DateTime.now().subtract(const Duration(hours: 2)), status: 'unhealthy', confidence: 82.5, path: 'detection_001.jpg'),
      _PlantLog(timestamp: DateTime.now().subtract(const Duration(hours: 5)), status: 'healthy', confidence: 91.2, path: 'detection_002.jpg'),
      _PlantLog(timestamp: DateTime.now().subtract(const Duration(days: 1)), status: 'unhealthy', confidence: 76.8, path: 'detection_003.jpg'),
    ];

    final filtered = logs.where((l) => l.timestamp.isAfter(startDate) && l.timestamp.isBefore(endDate)).toList();

    if (filtered.isEmpty) {
      return _EmptyState(
        icon: Icons.leak_remove_rounded,
        message: 'Belum ada deteksi tanaman pada rentang ini',
        shadowColor: Theme.of(context).colorScheme.primary,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _PlantLogCard(log: filtered[i]),
    );
  }
}

class _PlantLog {
  final DateTime timestamp;
  final String status;
  final double confidence;
  final String path;
  _PlantLog({required this.timestamp, required this.status, required this.confidence, required this.path});
}

class _PlantLogCard extends StatelessWidget {
  const _PlantLogCard({required this.log});

  final _PlantLog log;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isHealthy = log.status == 'healthy';
    final statusColor = isHealthy ? const Color(0xFF16845B) : const Color(0xFFDC2626);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_fmtDate(log.timestamp),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const Spacer(),
              Text(_fmtTime(log.timestamp),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isHealthy ? Icons.leak_add_rounded : Icons.leak_remove_rounded, size: 48, color: statusColor),
                  const SizedBox(height: 8),
                  Text(
                    isHealthy ? 'Sehat' : 'Tidak Sehat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: statusColor),
                  ),
                  const SizedBox(height: 4),
                  Text('${log.confidence.toStringAsFixed(1)}% confidence',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDetail(context, log),
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  label: const Text('Detail'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final t = dt.toLocal();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
  }

  String _fmtDate(DateTime dt) {
    return DateFormat('d MMM yyyy', 'id_ID').format(dt.toLocal());
  }

  void _showDetail(BuildContext ctx, _PlantLog l) {
    showDialog(
      context: ctx,
      builder: (ctx) => AlertDialog(
        title: const Text('Detail Deteksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Status: ${l.status == 'healthy' ? "Sehat" : "Tidak Sehat"}'),
            const SizedBox(height: 8),
            Text('Confidence: ${l.confidence.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('Waktu: ${_fmtTime(l.timestamp)} ${_fmtDate(l.timestamp)}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    this.shadowColor,
  });

  final IconData icon;
  final String message;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primary = shadowColor ?? cs.primary;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: primary.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: primary),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

// ── Helper functions ──────────────────────────────────────────────────────────

String _fmtTime(DateTime dt) {
  final t = dt.toLocal();
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
}

String _fmtDate(DateTime dt) {
  return DateFormat('d MMM yyyy', 'id_ID').format(dt.toLocal());
}

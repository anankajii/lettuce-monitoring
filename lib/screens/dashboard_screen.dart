import 'dart:async';

import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/sensor_reading.dart';
import '../services/sensor_api_service.dart';
import '../widgets/sensor_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.sensorApiService});

  final SensorApiService? sensorApiService;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final SensorApiService _sensorApiService;
  Timer? _refreshTimer;
  SensorReading? _reading;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _sensorApiService = widget.sensorApiService ?? const SensorApiService();
    _loadSensor();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadSensor(showLoading: false),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSensor({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final reading = await _sensorApiService.fetchLatest();
      if (!mounted) {
        return;
      }

      setState(() {
        _reading = reading;
        _errorMessage = null;
        _isLoading = false;
      });
    } on SensorApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lettuce Monitor'),
            Text(
              'Smart Hydroponic System',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _isLoading ? null : _loadSensor,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadSensor,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              _ConnectionBanner(
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                reading: _reading,
              ),
              const SizedBox(height: 16),
              Text(
                'Kondisi Terkini',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoading && _reading == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth >= 700
                        ? (constraints.maxWidth - 12) / 2
                        : constraints.maxWidth;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SensorCard(
                          width: cardWidth,
                          label: 'Suhu Udara',
                          value: _format(_reading?.temperature, 1),
                          unit: '°C',
                          icon: Icons.thermostat_rounded,
                          color: const Color(0xFFE7683F),
                          caption: 'Sensor DHT22',
                        ),
                        SensorCard(
                          width: cardWidth,
                          label: 'Kelembapan',
                          value: _format(_reading?.humidity, 1),
                          unit: '%',
                          icon: Icons.water_drop_rounded,
                          color: const Color(0xFF2878C8),
                          caption: 'Kelembapan udara',
                        ),
                        SensorCard(
                          width: cardWidth,
                          label: 'pH Air',
                          value: _format(_reading?.ph, 1),
                          icon: Icons.science_rounded,
                          color: const Color(0xFF7B61B3),
                          caption: _reading?.phStatus ?? 'Tidak Diketahui',
                        ),
                        SensorCard(
                          width: cardWidth,
                          label: 'TDS Nutrisi',
                          value: _format(_reading?.tds, 0),
                          unit: 'ppm',
                          icon: Icons.opacity_rounded,
                          color: const Color(0xFF16845B),
                          caption: _reading?.tdsStatus ?? 'Tidak Diketahui',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _InfoCard(reading: _reading),
              ],
              if (_errorMessage != null && _reading == null) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _loadSensor,
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Coba lagi'),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  'Endpoint: ${ApiConfig.latestSensorUrl}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _format(double? value, int fractionDigits) {
    return value?.toStringAsFixed(fractionDigits) ?? '—';
  }
}

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({
    required this.isLoading,
    required this.errorMessage,
    required this.reading,
  });

  final bool isLoading;
  final String? errorMessage;
  final SensorReading? reading;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;
    final color = hasError ? Colors.red.shade700 : const Color(0xFF16845B);
    final icon = hasError ? Icons.cloud_off_rounded : Icons.cloud_done_rounded;
    final title = hasError
        ? 'API tidak terhubung'
        : isLoading
        ? 'Memperbarui data...'
        : 'ESP32 terhubung';
    final subtitle = hasError
        ? errorMessage!
        : 'Data diperbarui otomatis setiap 10 detik';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.reading});

  final SensorReading? reading;

  @override
  Widget build(BuildContext context) {
    final timestamp = reading?.timestamp;
    final time = timestamp == null
        ? 'Belum tersedia'
        : '${timestamp.day.toString().padLeft(2, '0')}/'
              '${timestamp.month.toString().padLeft(2, '0')}/'
              '${timestamp.year} '
              '${timestamp.hour.toString().padLeft(2, '0')}:'
              '${timestamp.minute.toString().padLeft(2, '0')}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.memory_rounded,
              label: 'Sumber data',
              value: (reading?.source ?? '—').toUpperCase(),
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.schedule_rounded,
              label: 'Pembaruan terakhir',
              value: time,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

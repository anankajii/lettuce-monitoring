import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/sensor_reading.dart';
import '../services/plant_classifier.dart';

/// Layar Deteksi Tanaman — kamera/galeri → inferensi TFLite → hasil.
/// Panel ESP32 menampilkan status device & sensor real-time dari Firebase.
class DetectionScreen extends StatefulWidget {
  const DetectionScreen({
    super.key,
    this.esp32Reading,
    this.esp32Online = false,
    this.esp32LastSeen,
    this.onRequestEsp32Photo,
  });

  /// Data sensor terbaru dari ESP32 via Firebase (null = belum ada data).
  final SensorReading? esp32Reading;

  /// True jika ESP32 online (data tidak basi).
  final bool esp32Online;

  /// Timestamp terakhir ESP32 mengirim data.
  final DateTime? esp32LastSeen;

  /// Callback saat user menekan tombol minta foto ke ESP32-CAM.
  final VoidCallback? onRequestEsp32Photo;

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final _picker     = ImagePicker();
  final _classifier = PlantClassifier();

  XFile?               _image;
  PlantClassification? _result;
  bool                 _loading = false;

  Future<void> _select(ImageSource source) async {
    try {
      final photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (photo == null) return;
      setState(() { _image = photo; _result = null; _loading = true; });
      final result = await _classifier.classify(File(photo.path));
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analisis gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _reset() => setState(() { _image = null; _result = null; });

  @override
  void dispose() { _classifier.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F2),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deteksi Tanaman',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
            Text('Klasifikasi kesehatan daun selada',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // ── Panel ESP32 ────────────────────────────────────────────────
          _Esp32Panel(
            reading: widget.esp32Reading,
            isOnline: widget.esp32Online,
            lastSeen: widget.esp32LastSeen,
            onRequestPhoto: widget.onRequestEsp32Photo,
          ),
          const SizedBox(height: 16),

          // ── Zona upload ──────────────────────────────────────────────
          Stack(
            children: [
              Container(
                height: 260,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _image == null
                        ? Colors.grey.shade300
                        : const Color(0xFF16845B),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: _image == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                size: 52, color: Color(0xFF9CA3AF)),
                            SizedBox(height: 10),
                            Text('Tambahkan foto tanaman',
                                style: TextStyle(
                                    color: Color(0xFF9CA3AF), fontSize: 14)),
                          ],
                        ),
                      )
                    : Image.file(File(_image!.path),
                        fit: BoxFit.cover, width: double.infinity),
              ),
              if (_image != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _reset,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Tombol sumber ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _loading ? null : () => _select(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeri'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      _loading ? null : () => _select(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Kamera'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Hasil ────────────────────────────────────────────────────
          _ResultCard(result: _result, loading: _loading),
        ],
      ),
    );
  }
}

// ── ESP32 Panel ────────────────────────────────────────────────────────────────

class _Esp32Panel extends StatelessWidget {
  const _Esp32Panel({
    required this.reading,
    required this.isOnline,
    required this.lastSeen,
    this.onRequestPhoto,
  });

  final SensorReading? reading;
  final bool isOnline;
  final DateTime? lastSeen;
  final VoidCallback? onRequestPhoto;

  String _fmtTime(DateTime? dt) {
    if (dt == null) return 'Belum pernah';
    final t = dt.toLocal();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
  }

  String _fmtVal(num? v, {String suffix = '', int? decimals}) {
    if (v == null) return '—';
    final d = decimals ?? 0;
    return v.toStringAsFixed(d) + suffix;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
          // Header: status ESP32
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.memory_rounded, color: cs.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ESP32 Hydroponics',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface)),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? const Color(0xFF16845B)
                                : const Color(0xFF9CA3AF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOnline
                                ? const Color(0xFF16845B)
                                : const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('Terakhir: ${_fmtTime(lastSeen)}',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ],
                ),
              ),
              if (onRequestPhoto != null)
                OutlinedButton.icon(
                  onPressed: onRequestPhoto,
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('Minta Foto ESP32'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),

          // Sensor grid (hanya tampil jika ada data)
          if (reading != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _SensorMini(
                  label: 'pH',
                  value: _fmtVal(reading!.ph, decimals: 1),
                  unit: 'pH',
                  icon: Icons.science_rounded,
                  color: const Color(0xFF7C3AED),
                ),
                _SensorMini(
                  label: 'TDS',
                  value: _fmtVal(reading!.tds, decimals: 0),
                  unit: 'ppm',
                  icon: Icons.water_drop_rounded,
                  color: const Color(0xFF0891B2),
                ),
                _SensorMini(
                  label: 'Air',
                  value: _fmtVal(reading!.waterTemperature, decimals: 1),
                  unit: '°C',
                  icon: Icons.device_thermostat_rounded,
                  color: const Color(0xFF2878C8),
                ),
                _SensorMini(
                  label: 'Udara',
                  value: _fmtVal(reading!.airTemperature, decimals: 1),
                  unit: '°C',
                  icon: Icons.thermostat_rounded,
                  color: const Color(0xFFE7683F),
                ),
                _SensorMini(
                  label: 'Humid',
                  value: _fmtVal(reading!.airHumidity, decimals: 1),
                  unit: '%',
                  icon: Icons.water_outlined,
                  color: const Color(0xFF059669),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SensorMini extends StatelessWidget {
  const _SensorMini({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          Text('$label $unit',
              style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

// ── Result Card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.loading});

  final PlantClassification? result;
  final bool loading;

  static const _labelInfo = <String, String>{
    'healthy':
        'Daun dalam kondisi sehat. Warna dan pertumbuhan tampak normal.',
    'unhealthy':
        'Terdeteksi indikasi masalah pada daun. Periksa nutrisi, pH, atau tanda penyakit.',
  };

  @override
  Widget build(BuildContext context) {
    // Loading
    if (loading) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 14),
              Text('Menganalisis gambar...'),
            ],
          ),
        ),
      );
    }

    // Belum ada hasil
    if (result == null) {
      return Container(
        padding: const EdgeInsets.all(18),
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
            Text('Hasil Klasifikasi',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _row('Status tanaman', 'Belum dianalisis'),
            _row('Tingkat keyakinan', '—'),
            const Divider(height: 24),
            const Text(
              'Ambil foto selada untuk memulai klasifikasi.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Hasil valid
    final isHealthy = result!.label == 'healthy';
    final color     = isHealthy ? const Color(0xFF16845B) : const Color(0xFFDC2626);
    final bgColor   = isHealthy ? const Color(0xFFE8F5EF) : const Color(0xFFFEF2F2);
    final icon      = isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded;
    final labelText = isHealthy ? 'Sehat' : 'Tidak Sehat';
    final confPct   = result!.confidence * 100;
    final confCat   = confPct >= 85 ? 'Tinggi' : confPct >= 65 ? 'Sedang' : 'Rendah';
    final info      = _labelInfo[result!.label]
        ?? 'Label: ${result!.label}.';

    return Container(
      padding: const EdgeInsets.all(18),
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
          Text('Hasil Klasifikasi',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),

          // Banner status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 36),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(labelText,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: color)),
                    Text(
                        'Keyakinan: ${confPct.toStringAsFixed(1)}% ($confCat)',
                        style: TextStyle(
                            color: color.withValues(alpha: 0.8),
                            fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Progress bar keyakinan
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: result!.confidence,
              minHeight: 8,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 14),

          // Info kondisi daun dari label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(info,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF374151))),
          ),
          const Divider(height: 24),
          const Text(
            'Akurasi bergantung pada kualitas foto dan model.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

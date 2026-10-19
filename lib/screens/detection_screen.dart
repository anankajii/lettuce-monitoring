import 'package:flutter/material.dart';

import '../widgets/demo_badge.dart';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deteksi Tanaman')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const DemoBadge(),
          const SizedBox(height: 16),
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 68, color: Color(0xFF16845B)),
                SizedBox(height: 14),
                Text('Tambahkan foto tanaman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Area ini disiapkan untuk kamera dan galeri. Fungsinya belum diaktifkan.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showNotReady(context, 'Galeri'),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeri'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showNotReady(context, 'Kamera'),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Kamera'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hasil klasifikasi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  const _ResultPlaceholder(label: 'Status tanaman', value: 'Belum dianalisis'),
                  const Divider(height: 24),
                  const _ResultPlaceholder(label: 'Confidence', value: '—'),
                  const Divider(height: 24),
                  const _ResultPlaceholder(label: 'Model', value: 'Belum dipilih'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showNotReady(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature belum diaktifkan. Task ini disiapkan untuk tim.')),
    );
  }
}

class _ResultPlaceholder extends StatelessWidget {
  const _ResultPlaceholder({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

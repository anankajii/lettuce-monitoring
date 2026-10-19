import 'package:flutter/material.dart';

import '../widgets/demo_badge.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analisis Kondisi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: const [
          DemoBadge(),
          SizedBox(height: 16),
          _AnalysisHero(),
          SizedBox(height: 16),
          _AnalysisItem(
            icon: Icons.science_rounded,
            title: 'Analisis pH',
            description: 'Status dan rekomendasi pH akan tampil di area ini.',
          ),
          SizedBox(height: 12),
          _AnalysisItem(
            icon: Icons.water_drop_rounded,
            title: 'Analisis nutrisi',
            description: 'Status TDS dan rekomendasi nutrisi akan tampil di sini.',
          ),
          SizedBox(height: 12),
          _AnalysisItem(
            icon: Icons.thermostat_rounded,
            title: 'Analisis suhu air',
            description: 'Data DS18B20 akan digunakan setelah integrasi sensor.',
          ),
          SizedBox(height: 12),
          _AnalysisItem(
            icon: Icons.eco_rounded,
            title: 'Kondisi tanaman',
            description: 'Menunggu dataset dan model klasifikasi tanaman.',
          ),
        ],
      ),
    );
  }
}

class _AnalysisHero extends StatelessWidget {
  const _AnalysisHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.auto_awesome_rounded, size: 46, color: Color(0xFF16845B)),
          SizedBox(height: 12),
          Text('Ringkasan analisis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          SizedBox(height: 7),
          Text(
            'Logika analisis belum diaktifkan. Tampilan ini disiapkan sebagai dasar pengerjaan tim.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AnalysisItem extends StatelessWidget {
  const _AnalysisItem({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

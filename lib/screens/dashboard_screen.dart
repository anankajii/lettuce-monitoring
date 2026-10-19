import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../widgets/demo_badge.dart';
import '../widgets/section_title.dart';
import '../widgets/sensor_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reading = DemoData.latest;

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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(child: Icon(Icons.person_outline_rounded)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const DemoBadge(),
          const SizedBox(height: 16),
          _WelcomeCard(),
          const SizedBox(height: 22),
          const SectionTitle(
            title: 'Kondisi terkini',
            subtitle: 'Ringkasan perangkat Hidroponik Utama',
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 700
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SensorCard(
                    width: width,
                    label: 'pH Air',
                    value: reading.ph?.toStringAsFixed(1) ?? '—',
                    icon: Icons.science_rounded,
                    color: const Color(0xFF7454B8),
                    caption: 'Rentang awal 5.5–6.5',
                  ),
                  SensorCard(
                    width: width,
                    label: 'TDS Nutrisi',
                    value: reading.tds?.toStringAsFixed(0) ?? '—',
                    unit: 'ppm',
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFF16845B),
                    caption: 'Rentang awal 560–840 ppm',
                  ),
                  SensorCard(
                    width: width,
                    label: 'Suhu Air',
                    value:
                        reading.waterTemperature?.toStringAsFixed(1) ?? '—',
                    unit: '°C',
                    icon: Icons.device_thermostat_rounded,
                    color: const Color(0xFF2878C8),
                    caption: 'Sensor DS18B20',
                  ),
                  SensorCard(
                    width: width,
                    label: 'Kelembapan Udara',
                    value: reading.airHumidity?.toStringAsFixed(1) ?? '—',
                    unit: '%',
                    icon: Icons.water_drop_outlined,
                    color: const Color(0xFFE7683F),
                    caption: 'DHT22 opsional',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const _SummaryCard(),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16845B), Color(0xFF2FA778)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pantau kondisi hidroponik dari satu aplikasi.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Icon(Icons.eco_rounded, color: Colors.white, size: 52),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFE8F5EF),
              child: Icon(Icons.check_circle_outline, color: Color(0xFF16845B)),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contoh ringkasan kondisi',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Area ini nantinya diisi hasil analisis data sensor dan kondisi tanaman.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

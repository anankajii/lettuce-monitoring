import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../widgets/demo_badge.dart';
import '../widgets/section_title.dart';
import '../widgets/sensor_card.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reading = DemoData.latest;
    final items = [
      ('pH Air', reading.ph, '', Icons.science_rounded, const Color(0xFF7454B8), 'Sensor pH'),
      ('TDS Nutrisi', reading.tds, 'ppm', Icons.water_drop_rounded, const Color(0xFF16845B), 'Sensor TDS'),
      ('Suhu Air', reading.waterTemperature, '°C', Icons.device_thermostat_rounded, const Color(0xFF2878C8), 'DS18B20'),
      ('Suhu Udara', reading.airTemperature, '°C', Icons.thermostat_rounded, const Color(0xFFE7683F), 'DHT22 opsional'),
      ('Kelembapan Udara', reading.airHumidity, '%', Icons.water_drop_outlined, const Color(0xFF318A9D), 'DHT22 opsional'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring Sensor')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const DemoBadge(),
          const SizedBox(height: 16),
          const SectionTitle(
            title: 'Semua parameter',
            subtitle: 'Tampilan dasar sensor yang akan dihubungkan tim',
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SensorCard(
                width: double.infinity,
                label: item.$1,
                value: item.$2?.toStringAsFixed(item.$3 == 'ppm' ? 0 : 1) ?? '—',
                unit: item.$3,
                icon: item.$4,
                color: item.$5,
                caption: item.$6,
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: const ListTile(
              leading: Icon(Icons.wifi_rounded),
              title: Text('Kekuatan sinyal'),
              subtitle: Text('Contoh data ESP32'),
              trailing: Text('-58 dBm', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

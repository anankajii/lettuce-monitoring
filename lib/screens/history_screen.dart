import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../widgets/demo_badge.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Sensor'), Tab(text: 'Tanaman')],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const DemoBadge(),
                const SizedBox(height: 14),
                _ChartPlaceholder(),
                const SizedBox(height: 14),
                ...DemoData.history.reversed.map(
                  (reading) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.sensors)),
                      title: Text(
                        'pH ${reading.ph?.toStringAsFixed(1)}  •  TDS ${reading.tds?.toStringAsFixed(0)} ppm',
                      ),
                      subtitle: Text(
                        'Suhu air ${reading.waterTemperature?.toStringAsFixed(1)} °C',
                      ),
                      trailing: Text(_time(reading.timestamp)),
                    ),
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                DemoBadge(),
                SizedBox(height: 14),
                _EmptyDetectionHistory(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _time(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}

class _ChartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart_rounded, size: 56, color: Color(0xFF16845B)),
          SizedBox(height: 12),
          Text('Area grafik riwayat', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text('Implementasi grafik menjadi task tim.', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _EmptyDetectionHistory extends StatelessWidget {
  const _EmptyDetectionHistory();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          children: [
            Icon(Icons.image_search_rounded, size: 60, color: Colors.grey.shade500),
            const SizedBox(height: 14),
            const Text('Belum ada hasil klasifikasi', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text(
              'Riwayat akan muncul setelah model dan penyimpanan Firebase selesai dibuat.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

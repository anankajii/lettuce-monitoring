import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/sensor_reading.dart';
import '../services/firebase_service.dart';
import 'analysis_screen.dart';
import 'dashboard_screen.dart';
import 'detection_screen.dart';
import 'history_screen.dart';
import 'monitoring_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final _firebase = FirebaseService();

  late final List<Widget> _screens = [
      // 0: Beranda
      StreamBuilder<SensorReading?>(
        stream: _firebase.watchLatestSensor(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Firebase error: ${snapshot.error}');
          }
          if (snapshot.hasData && snapshot.data != null) {
            _firebase.recordHistoryIfHourly(snapshot.data!);
          }
          final reading = snapshot.data ?? (snapshot.hasData ? null : DemoData.latest);
          return DashboardScreen(reading: reading);
        },
      ),
      // 1: Monitor
      StreamBuilder<SensorReading?>(
        stream: _firebase.watchLatestSensor(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Firebase monitor error: ${snapshot.error}');
          }
          final reading = snapshot.data ?? (snapshot.hasData ? null : DemoData.latest);
          return MonitoringScreen(
            reading: reading,
            lastSynced: reading?.timestamp,
          );
        },
      ),
      // 2: Riwayat
      const HistoryScreen(),
      // 3: Analisis
      StreamBuilder<SensorReading?>(
        stream: _firebase.watchLatestSensor(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Firebase analysis error: ${snapshot.error}');
          }
          final reading = snapshot.data ?? (snapshot.hasData ? null : DemoData.latest);
          return AnalysisScreen(reading: reading);
        },
      ),
      // 4: Deteksi
      StreamBuilder<bool>(
        stream: _firebase.watchDeviceOnline('esp32_01'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Firebase device online error: ${snapshot.error}');
          }
          final online = snapshot.data ?? false;
          return StreamBuilder<DateTime?>(
            stream: _firebase.watchDeviceLastSeen('esp32_01'),
            builder: (context, snapshot2) {
              final lastSeen = snapshot2.data;
              return DetectionScreen(
                esp32Online: online,
                esp32LastSeen: lastSeen,
                onRequestEsp32Photo: () => debugPrint('Request photo'),
              );
            },
          );
        },
      ),
    ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.sensors_outlined),
            selectedIcon: Icon(Icons.sensors_rounded),
            label: 'Monitor',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Analisis',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner_rounded),
            label: 'Deteksi',
          ),
        ],
      ),
    );
  }
}
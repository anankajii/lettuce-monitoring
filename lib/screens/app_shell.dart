import 'package:flutter/material.dart';

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
    StreamBuilder(
      stream: _firebase.watchLatestSensor(),
      builder: (context, snapshot) {
        return DashboardScreen(reading: snapshot.data);
      },
    ),
    const MonitoringScreen(),
    const HistoryScreen(),
    const AnalysisScreen(),
    const DetectionScreen(),
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
import 'package:flutter/material.dart';

import 'screens/app_shell.dart';

void main() {
  runApp(const HydroponicApp());
}

class HydroponicApp extends StatelessWidget {
  const HydroponicApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF16845B);

    return MaterialApp(
      title: 'Lettuce Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        scaffoldBackgroundColor: const Color(0xFFF4F7F5),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
        ),
        navigationBarTheme: const NavigationBarThemeData(height: 72),
      ),
      home: home ?? const AppShell(),
    );
  }
}

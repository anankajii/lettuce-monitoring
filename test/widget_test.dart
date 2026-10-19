import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('base app displays demo dashboard and navigation', (tester) async {
    await tester.pumpWidget(const HydroponicApp());

    expect(find.text('Lettuce Monitor'), findsOneWidget);
    expect(find.textContaining('Mode UI demo'), findsOneWidget);
    expect(find.text('pH Air'), findsOneWidget);
    expect(find.text('TDS Nutrisi'), findsOneWidget);
    expect(find.text('Suhu Air'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('navigation opens detection placeholder', (tester) async {
    await tester.pumpWidget(const HydroponicApp());

    await tester.tap(find.text('Deteksi'));
    await tester.pumpAndSettle();

    expect(find.text('Deteksi Tanaman'), findsOneWidget);
    expect(find.text('Belum dianalisis'), findsOneWidget);
    expect(find.text('Belum dipilih'), findsOneWidget);
  });

  testWidgets('camera action explains that feature is not active', (
    tester,
  ) async {
    await tester.pumpWidget(const HydroponicApp());

    await tester.tap(find.text('Deteksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kamera'));
    await tester.pump();

    expect(find.textContaining('Kamera belum diaktifkan'), findsOneWidget);
  });
}

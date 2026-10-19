import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/main.dart';
import 'package:mobile/screens/dashboard_screen.dart';
import 'package:mobile/services/sensor_api_service.dart';

void main() {
  testWidgets('dashboard displays sensor values from API', (tester) async {
    final client = MockClient((_) async {
      return http.Response(
        '{"ph":6.2,"tds":800,"temperature":27.5,"humidity":74.2,'
        '"source":"esp32","ph_status":"Normal","tds_status":"Normal",'
        '"timestamp":"2026-10-01 12:00:00"}',
        200,
      );
    });

    await tester.pumpWidget(
      HydroponicApp(
        home: DashboardScreen(
          sensorApiService: SensorApiService(client: client),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('27.5'), findsOneWidget);
    expect(find.text('74.2'), findsOneWidget);
    expect(find.text('6.2'), findsOneWidget);
    expect(find.text('800'), findsOneWidget);
    expect(find.text('ESP32 terhubung'), findsOneWidget);
  });
}

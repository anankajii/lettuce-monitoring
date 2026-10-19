import '../models/plant_detection.dart';
import '../models/sensor_reading.dart';

class DemoData {
  const DemoData._();

  static final SensorReading latest = SensorReading(
    ph: 6.2,
    tds: 780,
    waterTemperature: 24.8,
    airTemperature: 28.1,
    airHumidity: 72.5,
    wifiRssi: -58,
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    source: 'demo',
  );

  static final List<SensorReading> history = List.generate(10, (index) {
    final offset = 9 - index;
    return SensorReading(
      ph: 5.9 + (index % 4) * 0.1,
      tds: 710 + (index * 9).toDouble(),
      waterTemperature: 24.1 + (index % 5) * 0.2,
      airTemperature: 27.0 + (index % 4) * 0.4,
      airHumidity: 76.0 - (index % 5) * 1.2,
      wifiRssi: -62 + index,
      timestamp: DateTime.now().subtract(Duration(hours: offset * 3)),
      source: 'demo',
    );
  });

  static final List<PlantDetection> detections = [
    PlantDetection(
      label: 'Contoh hasil sehat',
      confidence: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}

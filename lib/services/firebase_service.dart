import 'package:firebase_database/firebase_database.dart';

import '../models/sensor_reading.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();
  
  factory FirebaseService() => _instance;
  FirebaseService._();

  final _db = FirebaseDatabase.instance.ref();

  /// Stream data sensor terbaru dari path: sensors/latest
  Stream<SensorReading?> watchLatestSensor() {
    return _db.child('sensors/latest').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return SensorReading.fromMap(
        Map<Object?, Object?>.from(event.snapshot.value as Map),
      );
    });
  }

  /// Stream riwayat sensor (limit 100 terbaru, ordered by timestamp)
  Stream<List<SensorReading>> watchSensorHistory() {
    return _db
        .child('sensors/history')
        .orderByChild('timestamp')
        .limitToLast(100)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return [];
      final map = Map<Object?, Object?>.from(event.snapshot.value as Map);
      return map.entries
          .map((e) => SensorReading.fromMap(
            Map<Object?, Object?>.from(e.value as Map),
          ))
          .toList()
          .reversed
          .toList();
    });
  }

  /// Tulis data sensor terbaru (ESP32 → Cloud Function → DB)
  Future<void> writeSensorReading(SensorReading reading) async {
    await _db.child('sensors/latest').set({
      'ph': reading.ph,
      'tds': reading.tds,
      'waterTemperature': reading.waterTemperature,
      'airTemperature': reading.airTemperature,
      'airHumidity': reading.airHumidity,
      'wifiRssi': reading.wifiRssi,
      'timestamp': reading.timestamp.millisecondsSinceEpoch,
      'source': reading.source,
    });
  }

  /// Status ESP32 online/offline dari path: devices/{deviceId}/status
  Stream<bool> watchDeviceOnline(String deviceId) {
    return _db.child('devices/$deviceId/lastSeen').onValue.map((event) {
      if (!event.snapshot.exists) return false;
      final ts = (event.snapshot.value as num).toInt();
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      return age < 60000; // online jika < 1 menit
    });
  }
}

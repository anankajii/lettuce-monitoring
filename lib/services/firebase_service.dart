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
      final val = event.snapshot.value;
      if (!event.snapshot.exists || val == null || val is! Map) return null;
      return SensorReading.fromMap(
        Map<Object?, Object?>.from(val),
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

  /// Status ESP32 online/offline dari path: devices/{deviceId}
  Stream<bool> watchDeviceOnline(String deviceId) {
    return _db.child('devices/$deviceId').onValue.map((event) {
      if (!event.snapshot.exists) return false;
      final val = event.snapshot.value;
      if (val is Map) {
        final map = Map<Object?, Object?>.from(val);
        final status = map['status']?.toString().toLowerCase();
        if (status == 'offline') return false;
        // Wajib ada heartbeat lastSeen > 0 agar status tidak nyangkut "online" saat alat mati.
        final ls = map['lastSeen'];
        if (ls is num && ls > 0) {
          final ms = ls.toInt() < 100000000000 ? ls.toInt() * 1000 : ls.toInt();
          final age = DateTime.now().millisecondsSinceEpoch - ms;
          return age >= 0 && age < 120000; // online jika heartbeat < 2 menit
        }
      }
      return false;
    });
  }

  DateTime? _lastHistoryPush;

  /// Catat snapshot sensor ke `sensors/history` maksimal 1x per jam.
  Future<void> recordHistoryIfHourly(SensorReading reading) async {
    final now = DateTime.now();
    if (_lastHistoryPush != null &&
        now.difference(_lastHistoryPush!).inMinutes < 60) {
      return;
    }
    _lastHistoryPush = now;
    try {
      final snap = await _db
          .child('sensors/history')
          .orderByChild('timestamp')
          .limitToLast(1)
          .get();
      if (snap.exists && snap.value is Map) {
        final map = Map<Object?, Object?>.from(snap.value as Map);
        for (final entry in map.values) {
          if (entry is Map) {
            final last = SensorReading.fromMap(Map<Object?, Object?>.from(entry));
            if (now.difference(last.timestamp).inMinutes < 60) {
              _lastHistoryPush = last.timestamp;
              return;
            }
          }
        }
      }
      await _db.child('sensors/history').push().set({
        'ph': reading.ph,
        'tds': reading.tds,
        'waterTemperature': reading.waterTemperature,
        'timestamp': now.millisecondsSinceEpoch,
        'source': reading.source,
      });
    } catch (_) {
      // Abaikan jika gagal tulis riwayat (mis. offline / permission).
    }
  }

  /// Stream lastSeen timestamp dari devices/{deviceId}/lastSeen
  Stream<DateTime?> watchDeviceLastSeen(String deviceId) {
    return _db.child('devices/$deviceId/lastSeen').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      final val = event.snapshot.value;
      if (val is num && val > 0) {
        final ms = val.toInt() < 100000000000 ? val.toInt() * 1000 : val.toInt();
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
      return null;
    });
  }
}

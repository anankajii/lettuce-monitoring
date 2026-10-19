class SensorReading {
  const SensorReading({
    required this.ph,
    required this.tds,
    required this.waterTemperature,
    required this.airTemperature,
    required this.airHumidity,
    required this.wifiRssi,
    required this.timestamp,
    required this.source,
  });

  final double? ph;
  final double? tds;
  final double? waterTemperature;
  final double? airTemperature;
  final double? airHumidity;
  final int? wifiRssi;
  final DateTime timestamp;
  final String source;

  factory SensorReading.fromMap(Map<Object?, Object?> map) {
    return SensorReading(
      ph: _toDouble(map['ph']),
      tds: _toDouble(map['tds']),
      waterTemperature: _toDouble(
        map['waterTemperature'] ?? map['water_temperature'],
      ),
      airTemperature: _toDouble(
        map['airTemperature'] ?? map['temperature'],
      ),
      airHumidity: _toDouble(map['airHumidity'] ?? map['humidity']),
      wifiRssi: _toInt(map['wifiRssi']),
      timestamp: _toDateTime(map['timestamp']),
      source: map['source']?.toString() ?? 'esp32',
    );
  }

  static double? _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  static int? _toInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime _toDateTime(Object? value) {
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }
}

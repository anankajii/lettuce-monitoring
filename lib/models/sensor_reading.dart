class SensorReading {
  const SensorReading({
    required this.ph,
    required this.tds,
    required this.temperature,
    required this.humidity,
    required this.source,
    required this.phStatus,
    required this.tdsStatus,
    required this.timestamp,
  });

  final double? ph;
  final double? tds;
  final double? temperature;
  final double? humidity;
  final String source;
  final String phStatus;
  final String tdsStatus;
  final DateTime? timestamp;

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      ph: _toDouble(json['ph']),
      tds: _toDouble(json['tds']),
      temperature: _toDouble(json['temperature']),
      humidity: _toDouble(json['humidity']),
      source: json['source']?.toString() ?? 'unknown',
      phStatus: json['ph_status']?.toString() ?? 'Tidak Diketahui',
      tdsStatus: json['tds_status']?.toString() ?? 'Tidak Diketahui',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? ''),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }
}

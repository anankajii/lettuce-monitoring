class ApiConfig {
  const ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.25:8000',
  );

  static const latestSensorUrl = '$baseUrl/api/sensors/latest';
}

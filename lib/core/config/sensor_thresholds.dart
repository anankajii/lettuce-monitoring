/// Ambang batas sensor dan skala fisik.
/// Satu-satunya tempat angka konfigurasi — ubah di sini, efek ke seluruh app.
class SensorThresholds {
  const SensorThresholds._();

  // ── Ambang ideal ──────────────────────────────────────────────────────────
  static const double phMin      = 5.5;
  static const double phMax      = 6.5;
  static const double phWarning  = 0.2; // zona waspada dari batas

  static const double tdsMin     = 560;
  static const double tdsMax     = 840;
  static const double tdsWarning = 0.10; // 10% dari batas

  static const double waterTempMax     = 25.0;
  static const double waterTempWarning = 0.5;

  static const double humidityMin = 50.0;
  static const double humidityMax = 85.0;

  static const double airTempMin  = 18.0;
  static const double airTempMax  = 32.0;

  // ── Skala fisik sensor (untuk progress bar rumus 2.5) ────────────────────
  static const double phScaleMin        = 0;
  static const double phScaleMax        = 14;

  static const double tdsScaleMin       = 0;
  static const double tdsScaleMax       = 2000;

  static const double waterTempScaleMin = 0;
  static const double waterTempScaleMax = 50;

  static const double humidityScaleMin  = 0;
  static const double humidityScaleMax  = 100;

  static const double airTempScaleMin   = 0;
  static const double airTempScaleMax   = 50;

  // ── Data basi ────────────────────────────────────────────────────────────
  /// Data dianggap basi bila selisih waktu > nilai ini (menit).
  static const int staleThresholdMinutes = 10;
}

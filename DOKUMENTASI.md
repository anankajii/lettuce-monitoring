# Dokumentasi Teknis Smart Hydroponic Mobile

## 1. Gambaran Umum

Smart Hydroponic Mobile adalah aplikasi Flutter untuk memantau sistem hidroponik berbasis ESP32 dan Firebase.

Parameter yang ditampilkan:

- pH air;
- TDS atau konsentrasi nutrisi;
- suhu air dari DS18B20;
- suhu udara dari DHT22 jika digunakan;
- kelembapan udara dari DHT22 jika digunakan;
- waktu pembaruan terakhir;
- status perangkat ESP32.

Flutter menjadi antarmuka utama pengguna. Firebase Realtime Database ditargetkan sebagai sumber data utama. Base UI saat ini tidak lagi memanggil Laravel API dan belum membaca Firebase.

> **Scope implementasi saat ini:** hanya base UI/APK. Seluruh nilai yang tampil merupakan data demo lokal. Firebase realtime, koneksi sensor, riwayat database, analisis, kamera, upload, dan klasifikasi belum diimplementasikan.

> Istilah “sensor DS” dalam project diasumsikan sebagai DS18B20 untuk mengukur suhu air.

## 2. Status Implementasi

### Sudah tersedia

- project Flutter untuk Android dan Web;
- dashboard awal berbasis Material 3;
- navigasi lima halaman: Beranda, Monitoring, Riwayat, Analisis, dan Deteksi;
- kartu pH, TDS, suhu air, suhu udara, dan kelembapan;
- data demo lokal untuk kebutuhan presentasi UI;
- placeholder grafik, analisis, kamera, dan hasil klasifikasi;
- model `SensorReading` dasar;
- widget test base UI dan navigasi;
- berkas referensi project Firebase untuk integrasi tahap berikutnya;
- Firebase belum menjadi dependensi runtime agar base UI dapat diuji tanpa plugin native.

### Belum selesai

- inisialisasi Firebase pada startup;
- pembacaan Realtime Database;
- model suhu air DS18B20;
- repository abstraction;
- Firebase Authentication;
- halaman riwayat dan grafik;
- analisis ambang sensor;
- push notification;
- pengaturan perangkat;
- kamera dan analisis tanaman;
- Firebase production rules;
- release signing Android.

Fitur yang belum selesai memang sengaja tidak diimplementasikan pada base APK agar dapat dibagi kepada anggota tim melalui `TUGAS_TIM.md`.

Daftar pekerjaan aktif dan statusnya berada di [TUGAS_TIM.md](TUGAS_TIM.md).

## 3. Arsitektur Target

```text
pH ────────────┐
TDS ───────────┤
DS18B20 ───────┼──► ESP32 ──HTTPS──► Cloud Function/API ──► Firebase
DHT22 opsional ┘                                            │
                                                            ▼
                                                     Flutter Mobile
                                                            │
                                  ┌─────────────────────────┼────────────────────┐
                                  ▼                         ▼                    ▼
                              Dashboard                  Riwayat             Analisis
```

### Tanggung jawab komponen

| Komponen | Tanggung jawab |
|---|---|
| ESP32 | Membaca sensor dan mengirim payload |
| Cloud Function/API | Autentikasi perangkat, validasi, timestamp, penyimpanan |
| Realtime Database | Data terbaru dan riwayat sensor |
| Firebase Auth | Identitas pengguna |
| Firebase Storage | Foto tanaman |
| Flutter | UI, realtime stream, riwayat, analisis, notifikasi |

## 4. Struktur Project

```text
mobile/
├── android/
│   └── app/
│       ├── build.gradle.kts
│       ├── google-services.json
│       └── src/main/AndroidManifest.xml
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── config/
│   │   └── api_config.dart
│   ├── models/
│   │   └── sensor_reading.dart
│   ├── screens/
│   │   └── dashboard_screen.dart
│   ├── services/
│   │   └── sensor_api_service.dart
│   └── widgets/
│       └── sensor_card.dart
├── test/
│   └── widget_test.dart
├── firebase.json
├── pubspec.yaml
├── README.md
├── DOKUMENTASI.md
└── TUGAS_TIM.md
```

### Struktur target bertahap

```text
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── utilities/
├── models/
├── repositories/
├── services/
├── screens/
│   ├── authentication/
│   ├── dashboard/
│   ├── history/
│   ├── analysis/
│   ├── detection/
│   └── settings/
└── widgets/
```

Pemindahan file dilakukan secara bertahap. Hindari refactor besar bersamaan dengan penambahan fitur.

## 5. Persyaratan

- Flutter SDK yang mendukung Dart `^3.11.1`;
- Android Studio dan Android SDK;
- perangkat Android atau emulator;
- akun dan akses ke Firebase project;
- Firebase CLI dan FlutterFire CLI untuk perubahan konfigurasi;
- Git.

Periksa lingkungan:

```bash
flutter --version
flutter doctor
dart --version
firebase --version
flutterfire --version
```

## 6. Instalasi dan Menjalankan Project

Clone repository lalu jalankan:

```bash
flutter pub get
flutter run
```

Jika masih menguji Laravel API lokal:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.25:8000
```

Untuk Android Emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Setelah migrasi Firebase selesai, `API_BASE_URL` tidak lagi diperlukan untuk sensor.

## 7. Konfigurasi Firebase

Konfigurasi yang sudah tersedia:

- Project ID: `lettuce-monitoring-165fd`;
- Android application ID: `com.hidroponik.lettucemonitor`;
- `firebase.json`;
- `lib/firebase_options.dart`;
- `android/app/google-services.json`.

### Inisialisasi target

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HydroponicApp());
}
```

Jangan menjalankan operasi Firebase sebelum `Firebase.initializeApp()` selesai.

## 8. Kontrak Data Firebase

```json
{
  "devices": {
    "esp32-01": {
      "info": {
        "name": "Hidroponik Utama",
        "firmwareVersion": "1.0.0",
        "dht22Enabled": true
      },
      "latest": {
        "ph": 6.2,
        "tds": 780,
        "waterTemperature": 24.8,
        "airTemperature": 28.1,
        "airHumidity": 72.5,
        "wifiRssi": -58,
        "timestamp": 1792382400000
      },
      "readings": {
        "-firebasePushId": {
          "ph": 6.2,
          "tds": 780,
          "waterTemperature": 24.8,
          "airTemperature": 28.1,
          "airHumidity": 72.5,
          "timestamp": 1792382400000
        }
      }
    }
  },
  "users": {
    "firebase-user-uid": {
      "devices": {
        "esp32-01": true
      }
    }
  }
}
```

### Ketentuan field

| Field | Tipe | Wajib | Keterangan |
|---|---|---:|---|
| `ph` | number/null | Ya | pH air |
| `tds` | number/null | Ya | TDS dalam ppm |
| `waterTemperature` | number/null | Ya | Suhu air DS18B20 |
| `airTemperature` | number/null | Tidak | Suhu udara DHT22 |
| `airHumidity` | number/null | Tidak | Kelembapan DHT22 |
| `wifiRssi` | integer/null | Tidak | Kekuatan sinyal ESP32 |
| `timestamp` | integer | Ya | Unix epoch milidetik dari server |

Nilai sensor yang tidak tersedia tidak boleh diganti angka nol karena nol dapat dianggap sebagai pembacaan sah.

### Penamaan

- Gunakan camelCase pada field Firebase.
- Jangan mengubah nama field tanpa memperbarui dokumentasi dan persetujuan tim.
- Gunakan `latest` untuk dashboard.
- Gunakan `readings` untuk riwayat.

## 9. Model Domain

Target model:

```dart
class SensorReading {
  const SensorReading({
    required this.ph,
    required this.tds,
    required this.waterTemperature,
    required this.airTemperature,
    required this.airHumidity,
    required this.wifiRssi,
    required this.timestamp,
  });

  final double? ph;
  final double? tds;
  final double? waterTemperature;
  final double? airTemperature;
  final double? airHumidity;
  final int? wifiRssi;
  final DateTime timestamp;
}
```

Parser wajib menangani angka Firebase yang dapat diterima Dart sebagai `int` atau `double`.

## 10. Repository dan Service

UI tidak boleh memanggil Firebase secara langsung. Gunakan repository contract:

```dart
abstract interface class SensorRepository {
  Stream<SensorReading?> watchLatest(String deviceId);

  Future<List<SensorReading>> getHistory({
    required String deviceId,
    required DateTime start,
    required DateTime end,
  });
}
```

Keuntungan:

- UI mudah dites;
- Firebase dapat diganti tanpa membongkar widget;
- fake repository dapat dipakai pada widget test;
- parsing dan error handling terpusat.

## 11. Status Sensor

Ambang awal prototipe:

| Parameter | Normal awal |
|---|---|
| pH | 5.5–6.5 |
| TDS | 560–840 ppm |

Ambang suhu air belum menjadi keputusan final.

Status domain:

```text
normal
warning
danger
unknown
```

Aturan:

- nilai `null` menghasilkan `unknown`;
- data yang terlalu lama tidak boleh dianggap normal;
- perangkat online/offline ditentukan dari timestamp;
- logika status ditempatkan pada domain/service, bukan widget;
- ambang disimpan terpusat agar dapat dikonfigurasi.

## 12. Halaman Aplikasi

### Dashboard

- kartu seluruh sensor;
- status perangkat;
- waktu pembaruan;
- ringkasan kondisi;
- akses cepat ke riwayat dan analisis.

### Riwayat

- grafik per sensor;
- filter tanggal;
- minimum, maksimum, dan rata-rata;
- empty state;
- query Firebase yang dibatasi.

### Analisis

- rekomendasi berdasarkan sensor;
- hasil klasifikasi tanaman;
- confidence dan versi model;
- riwayat analisis.

### Pengaturan

- nama perangkat;
- ambang sensor;
- penggunaan DHT22;
- interval data;
- notifikasi;
- akun pengguna.

## 13. Analisis Gambar

Algoritma belum ditetapkan. KNN hanya salah satu baseline. Kandidat lain:

- SVM;
- Random Forest;
- CNN;
- MobileNet;
- EfficientNet;
- TensorFlow Lite;
- cloud inference.

Pemilihan harus berdasarkan:

- accuracy;
- precision;
- recall;
- F1-score;
- confusion matrix;
- ukuran model;
- waktu inferensi;
- konsumsi memori;
- hasil pada foto HP nyata.

UI hanya menerima kontrak hasil generik:

```dart
class PlantAnalysis {
  final String label;
  final double confidence;
  final String imageUrl;
  final DateTime createdAt;
  final String modelVersion;
}
```

Dengan begitu algoritma dapat diganti tanpa mengubah halaman hasil.

## 14. Authentication dan Security Rules

Target akses:

- pengguna wajib login;
- pengguna hanya membaca perangkat miliknya;
- aplikasi Flutter tidak menulis data sensor;
- ESP32 menulis melalui Cloud Function/API tepercaya;
- service-account tidak disimpan pada client.

Contoh rules awal:

```json
{
  "rules": {
    "devices": {
      "$deviceId": {
        ".read": "auth != null && root.child('users').child(auth.uid).child('devices').child($deviceId).val() == true",
        ".write": false,
        "readings": {
          ".indexOn": ["timestamp"]
        }
      }
    },
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    }
  }
}
```

Rules harus diuji dengan Firebase Emulator Suite.

## 15. Offline dan Error Handling

Setiap screen yang membaca data wajib mempunyai:

- loading state;
- success state;
- empty state;
- offline state;
- permission denied state;
- generic error state;
- tombol mencoba kembali bila relevan.

Data cache terakhir boleh ditampilkan, tetapi waktu pembaruan harus terlihat agar pengguna tidak menganggapnya sebagai data baru.

## 16. Testing

Jalankan:

```bash
dart format lib test
flutter analyze
flutter test
```

### Unit test

- parsing angka `int`, `double`, dan string numerik;
- field DHT22 tidak tersedia;
- timestamp tidak valid;
- status ambang;
- status online/offline;
- mapping exception Firebase.

### Widget test

- loading;
- sensor lengkap;
- tanpa DHT22;
- empty state;
- offline;
- permission denied;
- generic error;
- ukuran layar kecil.

### Integration test

- login;
- membuka perangkat milik pengguna;
- realtime update;
- query riwayat;
- upload foto;
- logout.

## 17. Build

### Debug APK

```bash
flutter build apk --debug
```

### Release APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

Release membutuhkan keystore. Jangan commit file `.jks`, `.keystore`, atau `key.properties`.

## 18. Git dan Kolaborasi

Gunakan feature branch:

```text
feature/firebase-realtime
feature/dashboard-ui
feature/sensor-history
feature/authentication
feature/plant-analysis
fix/dashboard-overflow
```

Sebelum membuka pull request:

1. Perbarui branch dari `main`.
2. Jalankan formatter, analyzer, dan test.
3. Perbarui dokumentasi jika kontrak berubah.
4. Perbarui dan centang task di [TUGAS_TIM.md](TUGAS_TIM.md).
5. Sertakan screenshot jika ada perubahan UI.

## 19. File Sensitif

Jangan commit:

- `.env`;
- service-account JSON;
- Firebase Admin SDK private key;
- password Wi-Fi;
- Android keystore;
- `key.properties`;
- file build.

`firebase_options.dart` dan `google-services.json` adalah konfigurasi client, bukan service-account. Keamanan tetap harus diterapkan melalui Authentication, Security Rules, API restrictions, dan App Check.

## 20. Migrasi dari Laravel

Migrasi dinyatakan selesai jika:

- Flutter membaca `latest` dari Firebase;
- Flutter membaca `readings` dari Firebase;
- ESP32 mengirim ke Cloud Function/API baru;
- tidak ada pemanggilan `SensorApiService` pada runtime;
- `API_BASE_URL` tidak diperlukan;
- seluruh test Firebase lulus;
- data lama yang dibutuhkan sudah diekspor;
- Laravel dapat dimatikan tanpa memengaruhi aplikasi.

Setelah itu, file berikut dapat dihapus melalui pull request terpisah:

```text
lib/config/api_config.dart
lib/services/sensor_api_service.dart
dependency package:http jika tidak dipakai fitur lain
```

## 21. Troubleshooting

### `permission_denied`

- pastikan pengguna login;
- periksa UID dan device mapping;
- periksa path Firebase;
- jalankan test rules di emulator.

### Firebase belum terinisialisasi

- periksa `Firebase.initializeApp()`;
- periksa `firebase_options.dart`;
- pastikan `WidgetsFlutterBinding.ensureInitialized()` dipanggil.

### Dashboard tidak realtime

- gunakan `.onValue`/stream, bukan hanya `once`;
- periksa path `devices/{deviceId}/latest`;
- pastikan ESP32 memperbarui timestamp;
- pastikan subscription tidak tertutup terlalu awal.

### Data null tampil sebagai nol

- periksa parser model;
- jangan memakai fallback `0` untuk sensor yang tidak tersedia;
- tampilkan `—` atau `Tidak tersedia`.

### Build Android gagal

```bash
flutter clean
flutter pub get
flutter doctor
flutter build apk --debug
```

## 22. Dokumen Terkait

- [README.md](README.md) — ringkasan repository.
- [TUGAS_TIM.md](TUGAS_TIM.md) — daftar tugas, pembagian, dan tracker progres.
- `firebase.json` — konfigurasi FlutterFire.
- `pubspec.yaml` — dependensi.

---

Setiap perubahan arsitektur, kontrak Firebase, nama field, atau alur authentication wajib diikuti pembaruan dokumen ini dan checklist pada `TUGAS_TIM.md`.

# Panduan Pengerjaan Tim — Smart Hydroponic Mobile

## 1. Tujuan

Repository ini berisi aplikasi mobile Smart Hydroponic yang dibuat dengan Flutter dan Firebase. Aplikasi digunakan untuk memantau:

- pH air;
- TDS/nutrisi;
- suhu air dari DS18B20;
- suhu udara dari DHT22 jika digunakan;
- kelembapan udara dari DHT22 jika digunakan;
- status koneksi perangkat ESP32;
- riwayat dan analisis kondisi hidroponik.

Produk akhir hanya menggunakan aplikasi mobile sebagai antarmuka utama. Laravel API yang pernah digunakan merupakan prototipe sementara dan akan digantikan Firebase.

> Dalam dokumen ini, “sensor DS” diasumsikan sebagai DS18B20 untuk suhu air.

## 2. Kondisi Project Saat Ini

Yang sudah tersedia:

- project Flutter Android dan Web;
- dashboard awal;
- kartu suhu, kelembapan, pH, dan TDS;
- model `SensorReading` versi Laravel API;
- service HTTP ke Laravel;
- refresh otomatis setiap 10 detik;
- penanganan loading dan error;
- widget test dasar;
- konfigurasi Firebase Android dan Web;
- paket `firebase_core` dan `firebase_database`;
- Firebase project `lettuce-monitoring-165fd`.

Yang belum selesai:

- Firebase belum diinisialisasi pada `main.dart`;
- dashboard masih membaca Laravel API;
- struktur model belum memakai `waterTemperature`;
- autentikasi belum tersedia;
- halaman riwayat belum tersedia;
- grafik belum tersedia;
- analisis kondisi belum lengkap;
- notifikasi belum tersedia;
- fitur kamera/analisis tanaman belum tersedia;
- pengaturan perangkat belum tersedia;
- test coverage masih minimal.

## 3. Teknologi

- Flutter dan Dart;
- Material 3;
- Firebase Core;
- Firebase Realtime Database;
- Firebase Authentication;
- Firebase Storage;
- Firebase Cloud Messaging;
- Firebase Emulator Suite untuk pengujian lokal.

## 4. Cara Menjalankan Project

```bash
flutter pub get
flutter run
```

Sebelum membuat pull request, jalankan:

```bash
dart format lib test
flutter analyze
flutter test
```

Semua perintah harus berhasil tanpa error.

## 5. Struktur Folder

```text
lib/
├── main.dart
├── firebase_options.dart
├── config/
│   └── api_config.dart
├── models/
│   └── sensor_reading.dart
├── screens/
│   └── dashboard_screen.dart
├── services/
│   └── sensor_api_service.dart
└── widgets/
    └── sensor_card.dart
```

Struktur target:

```text
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── utilities/
├── models/
│   ├── sensor_reading.dart
│   ├── device.dart
│   └── plant_analysis.dart
├── repositories/
│   ├── sensor_repository.dart
│   └── analysis_repository.dart
├── services/
│   ├── firebase_sensor_service.dart
│   ├── authentication_service.dart
│   ├── notification_service.dart
│   └── image_analysis_service.dart
├── screens/
│   ├── authentication/
│   ├── dashboard/
│   ├── history/
│   ├── analysis/
│   ├── detection/
│   └── settings/
└── widgets/
```

Jangan melakukan pemindahan seluruh file sekaligus dalam satu pull request. Refactor struktur dilakukan bertahap agar mudah direview.

## 6. Kontrak Data Firebase

Gunakan struktur berikut sebagai kontrak bersama:

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

Ketentuan:

- `ph`, `tds`, dan `waterTemperature` adalah parameter utama;
- `airTemperature` dan `airHumidity` bersifat opsional;
- data opsional yang tidak tersedia harus `null` atau tidak ada, bukan `0`;
- `timestamp` menggunakan Unix epoch dalam milidetik dari server;
- nama field tidak boleh diubah tanpa diskusi tim;
- `latest` digunakan dashboard;
- `readings` digunakan halaman riwayat dan grafik.

## 7. Prioritas Pengerjaan

### P0 — Wajib sebelum fitur lain

- [ ] Inisialisasi Firebase pada `main.dart`.
- [ ] Pastikan aplikasi dapat membaca node Firebase secara realtime.
- [ ] Perbarui model `SensorReading` sesuai kontrak data.
- [ ] Buat abstraksi repository agar UI tidak langsung memanggil Firebase.
- [ ] Ganti polling Laravel dengan Firebase stream.
- [ ] Tambahkan state loading, empty, offline, permission denied, dan error.
- [ ] Tambahkan unit test parsing data.
- [ ] Tambahkan widget test dashboard dengan fake repository.

### P1 — Fitur inti

- [ ] Dashboard final.
- [ ] Navigasi aplikasi.
- [ ] Halaman riwayat.
- [ ] Grafik sensor.
- [ ] Filter periode waktu.
- [ ] Status perangkat online/offline.
- [ ] Analisis ambang sensor.
- [ ] Firebase Authentication.
- [ ] Pembatasan akses berdasarkan pengguna dan perangkat.

### P2 — Fitur tambahan

- [ ] Push notification.
- [ ] Kamera dan galeri.
- [ ] Upload foto ke Firebase Storage.
- [ ] Integrasi model analisis tanaman.
- [ ] Halaman hasil klasifikasi.
- [ ] Riwayat klasifikasi.
- [ ] Pengaturan ambang dan perangkat.

### P3 — Persiapan rilis

- [ ] App icon dan splash screen final.
- [ ] Release signing Android.
- [ ] Firebase production rules.
- [ ] Firebase Crashlytics.
- [ ] Pengujian perangkat fisik.
- [ ] Optimasi performa dan ukuran aplikasi.
- [ ] Build Android App Bundle.

## 8. Pembagian Pekerjaan yang Disarankan

Pembagian berikut dapat disesuaikan dengan jumlah anggota.

### Anggota A — Firebase dan data layer

Tugas:

- inisialisasi Firebase;
- implementasi `FirebaseSensorService`;
- implementasi `SensorRepository`;
- parsing snapshot Firebase;
- penanganan realtime stream;
- Firebase Emulator;
- test repository dan model.

File utama:

```text
lib/main.dart
lib/models/
lib/repositories/
lib/services/firebase_sensor_service.dart
test/models/
test/repositories/
```

Acceptance criteria:

- aplikasi menerima perubahan Firebase tanpa refresh manual;
- data DHT22 opsional tidak menyebabkan crash;
- listener dilepas ketika screen ditutup;
- error Firebase diterjemahkan menjadi state yang dapat ditampilkan UI;
- seluruh test lulus.

### Anggota B — Dashboard dan design system

Tugas:

- menyusun theme global;
- merapikan dashboard;
- membuat komponen sensor reusable;
- membuat indikator online/offline;
- membuat loading skeleton, empty state, dan error state;
- memastikan layout responsif.

File utama:

```text
lib/core/theme/
lib/screens/dashboard/
lib/widgets/
test/screens/dashboard/
```

Acceptance criteria:

- tidak ada overflow pada layar kecil;
- nilai null ditampilkan sebagai `Tidak tersedia` atau `—`;
- warna bukan satu-satunya penanda status;
- UI dapat dipakai pada mode teks besar;
- widget test mencakup seluruh state utama.

### Anggota C — Riwayat dan grafik

Tugas:

- membuat query riwayat berdasarkan timestamp;
- membuat halaman riwayat;
- membuat grafik pH, TDS, dan suhu air;
- membuat grafik DHT22 jika datanya tersedia;
- menambahkan filter hari/minggu/rentang tanggal;
- menampilkan minimum, maksimum, dan rata-rata.

File utama:

```text
lib/screens/history/
lib/repositories/sensor_repository.dart
lib/widgets/charts/
test/screens/history/
```

Acceptance criteria:

- query tidak mengambil seluruh database tanpa batas;
- grafik tetap aman ketika data kosong;
- nilai diurutkan berdasarkan timestamp;
- filter bekerja dan diuji;
- zona waktu ditampilkan dengan benar.

### Anggota D — Authentication dan keamanan

Tugas:

- login/register/logout;
- reset password;
- session/auth state;
- relasi pengguna dengan perangkat;
- Realtime Database Security Rules;
- test Firebase rules melalui emulator.

File utama:

```text
lib/screens/authentication/
lib/services/authentication_service.dart
lib/repositories/authentication_repository.dart
database.rules.json
test/authentication/
```

Acceptance criteria:

- pengguna yang belum login tidak dapat membuka dashboard privat;
- pengguna hanya dapat membaca perangkat miliknya;
- Flutter tidak mempunyai akses tulis ke data sensor;
- rules menolak akses lintas pengguna;
- tidak ada service-account key dalam repository.

### Anggota E — Analisis tanaman

Tugas:

- kamera dan pemilihan galeri;
- kompresi dan validasi foto;
- upload ke Firebase Storage;
- integrasi model atau API analisis;
- hasil label dan confidence;
- riwayat analisis.

File utama:

```text
lib/screens/detection/
lib/screens/analysis/
lib/services/image_analysis_service.dart
lib/models/plant_analysis.dart
test/analysis/
```

Acceptance criteria:

- format dan ukuran gambar divalidasi;
- loading upload/inferensi terlihat;
- kegagalan jaringan tidak menyebabkan crash;
- hasil tersimpan dengan user ID dan timestamp;
- algoritma tidak dikunci ke KNN;
- UI tidak bergantung pada detail internal model.

## 9. Detail Tugas Firebase P0

### 9.1 Inisialisasi

Ubah `main.dart` sehingga Firebase diinisialisasi sebelum aplikasi dijalankan:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HydroponicApp());
}
```

### 9.2 Model sensor target

Model harus mendukung:

```dart
class SensorReading {
  final double? ph;
  final double? tds;
  final double? waterTemperature;
  final double? airTemperature;
  final double? airHumidity;
  final int? wifiRssi;
  final DateTime timestamp;
}
```

Parser harus menerima nilai Firebase bertipe `int`, `double`, atau string numerik tanpa crash.

### 9.3 Repository contract

Contoh interface:

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

UI hanya boleh bergantung pada interface repository, bukan langsung pada `FirebaseDatabase.instance`.

## 10. Analisis Status Sensor

Ambang awal prototipe:

| Parameter | Normal awal |
|---|---|
| pH | 5.5–6.5 |
| TDS | 560–840 ppm |

Ambang suhu air belum ditetapkan sebagai keputusan final. Simpan ambang dalam konfigurasi, jangan hard-code di banyak widget.

Status minimum:

```text
normal
warning
danger
unknown
```

Ketentuan:

- data `null` menghasilkan `unknown`;
- data lama tidak boleh tetap dianggap normal;
- perangkat dianggap offline jika timestamp melewati batas yang dikonfigurasi;
- logika status harus berada di domain/service, bukan di widget.

## 11. Fitur Analisis Gambar

Algoritma belum ditetapkan. Kandidat:

- KNN sebagai baseline;
- SVM;
- Random Forest;
- CNN;
- MobileNet/EfficientNet;
- TensorFlow Lite untuk on-device inference;
- cloud inference.

Sebelum menentukan model, bandingkan:

- accuracy;
- precision;
- recall;
- F1-score;
- confusion matrix;
- ukuran model;
- waktu inferensi;
- konsumsi memori;
- hasil pada foto kamera HP nyata.

Service Flutter harus mengembalikan bentuk generik seperti:

```dart
class PlantAnalysis {
  final String label;
  final double confidence;
  final String imageUrl;
  final DateTime createdAt;
  final String modelVersion;
}
```

Dengan demikian algoritma dapat diganti tanpa mengubah seluruh UI.

## 12. Git Workflow

### Branch

Jangan mengerjakan langsung pada `main`.

Format nama branch:

```text
feature/firebase-realtime
feature/dashboard-ui
feature/sensor-history
feature/authentication
feature/plant-analysis
fix/dashboard-overflow
test/sensor-repository
```

### Commit

Gunakan commit kecil dan jelas:

```text
feat: initialize Firebase on app startup
feat: add realtime sensor repository
feat: add sensor history chart
fix: handle missing DHT22 values
test: add sensor snapshot parsing cases
docs: update Firebase data contract
```

### Pull request

Setiap pull request harus:

- fokus pada satu fitur atau perbaikan;
- menjelaskan masalah dan solusi;
- menyertakan screenshot/video jika mengubah UI;
- mencantumkan cara pengujian;
- tidak membawa file build;
- tidak membawa credential rahasia;
- lolos format, analyze, dan test;
- mendapat review minimal satu anggota lain.

## 13. Aturan Menghindari Konflik

- Satu orang bertanggung jawab atas `main.dart` selama pekerjaan Firebase P0.
- Diskusikan sebelum mengubah kontrak `SensorReading`.
- Jangan mengubah nama path Firebase sendiri-sendiri.
- Jangan melakukan refactor struktur folder bersamaan dengan fitur besar.
- Pisahkan pull request UI, data layer, dan authentication.
- Rebase atau update branch dari `main` sebelum membuka pull request.
- Jangan melakukan force push pada branch milik anggota lain.

## 14. File yang Tidak Boleh Diunggah

Pastikan `.gitignore` mencakup:

```gitignore
.dart_tool/
.idea/
.vscode/
build/
android/.gradle/
android/local.properties
*.jks
*.keystore
key.properties
.env
service-account*.json
firebase-adminsdk*.json
```

Catatan:

- `firebase_options.dart` dan `google-services.json` adalah konfigurasi client, bukan service-account private key;
- tetap batasi project Firebase menggunakan Authentication, Security Rules, API restrictions, dan App Check;
- jangan pernah mengunggah file service account atau private key.

## 15. Definition of Done

Sebuah task dianggap selesai jika:

- implementasi sesuai acceptance criteria;
- tidak ada error analyzer;
- test baru ditambahkan untuk logic penting;
- semua test lama tetap lulus;
- UI diuji minimal pada satu HP atau emulator;
- loading, empty, error, offline, dan success state dipertimbangkan;
- dokumentasi diperbarui jika kontrak berubah;
- tidak ada credential rahasia;
- pull request sudah direview dan disetujui.

## 16. Checklist Pull Request

Salin checklist ini ke deskripsi pull request:

```markdown
## Ringkasan

Jelaskan perubahan yang dibuat.

## Perubahan

- [ ] Fitur/perbaikan utama
- [ ] Test
- [ ] Dokumentasi

## Verifikasi

- [ ] `dart format lib test`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] Diuji pada emulator/perangkat
- [ ] Tidak ada credential rahasia
- [ ] Screenshot/video UI dilampirkan jika relevan

## Catatan

Tuliskan batasan, risiko, atau pekerjaan lanjutan.
```

## 17. Urutan Sprint yang Disarankan

### Sprint 1 — Firebase foundation

- Firebase initialization;
- model baru;
- repository contract;
- realtime service;
- dashboard membaca Firebase;
- unit dan widget test.

### Sprint 2 — Core mobile experience

- navigasi;
- dashboard final;
- online/offline status;
- history query;
- grafik dasar.

### Sprint 3 — User security

- authentication;
- user-device mapping;
- security rules;
- emulator test.

### Sprint 4 — Intelligence

- analisis ambang;
- notifikasi;
- kamera dan upload;
- eksperimen model klasifikasi.

### Sprint 5 — Release

- integration testing;
- physical-device testing;
- performance optimization;
- release signing;
- production Firebase configuration;
- Android App Bundle.

## 18. Pertanyaan yang Harus Diputuskan Tim

- Apakah DHT22 benar-benar digunakan?
- Berapa interval kirim data ESP32?
- Berapa lama data mentah disimpan?
- Berapa batas perangkat dianggap offline?
- Apakah satu pengguna dapat memiliki banyak perangkat?
- Apakah satu perangkat dapat dibagikan ke beberapa pengguna?
- Apakah analisis gambar berjalan on-device atau cloud?
- Algoritma mana yang memberikan hasil terbaik pada dataset?
- Apakah notifikasi menggunakan ambang default atau per pengguna?
- Apakah aplikasi hanya Android atau juga iOS pada tahap berikutnya?

## 19. Kontak dan Koordinasi

Gunakan GitHub Issues untuk setiap task. Satu issue minimal berisi:

- tujuan;
- ruang lingkup;
- file/modul terkait;
- acceptance criteria;
- dependensi dengan task lain;
- penanggung jawab;
- target sprint.

Jangan memulai task yang mengubah kontrak Firebase atau arsitektur utama tanpa persetujuan tim.

---

Prioritas pertama seluruh tim adalah menyelesaikan migrasi dashboard dari Laravel API ke Firebase Realtime Database. Fitur lain dikerjakan setelah data layer stabil dan telah diuji.

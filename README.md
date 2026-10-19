# Smart Hydroponic Mobile

Aplikasi Flutter untuk memantau sistem hidroponik berbasis ESP32 dan Firebase.

Parameter utama:

- pH air;
- TDS/nutrisi;
- suhu air DS18B20;
- suhu dan kelembapan udara DHT22 jika digunakan.

## Memulai

```bash
flutter pub get
flutter run
```

## Verifikasi

```bash
dart format lib test
flutter analyze
flutter test
```

## Panduan Tim

Baca [TUGAS_TIM.md](TUGAS_TIM.md) sebelum mengambil task. Dokumen tersebut berisi:

- status implementasi;
- kontrak data Firebase;
- prioritas P0–P3;
- pembagian tugas;
- acceptance criteria;
- Git workflow;
- checklist pull request;
- definition of done;
- urutan sprint.

Prioritas pertama adalah memindahkan dashboard dari Laravel API ke Firebase Realtime Database.

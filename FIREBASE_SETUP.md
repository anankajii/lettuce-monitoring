## Setup Firebase Credentials (Local)

File `lib/firebase_options.dart` dan `android/app/google-services.json` tidak disimpan di git untuk keamanan. Setiap developer harus setup sendiri.

### Quick Setup

```bash
# 1. Download google-services.json dari Firebase Console
#    Project Settings → Apps → Android → Download google-services.json
cp android/app/google-services.json.example android/app/google-services.json

# 2. Buat firebase_options.dart dari template
cp lib/firebase_options.dart.example lib/firebase_options.dart

# 3. Edit lib/firebase_options.dart, ganti placeholder dengan nilai dari:
#    - android/app/google-services.json
#    - Firebase Console → Realtime Database
```

### Cara Isi firebase_options.dart

1. Buka `android/app/google-services.json`
2. Cari nilai-nilai ini:

```json
"project_number": "763062986012",
"project_id": "lettuce-monitoring-165fd",
"mobilesdk_app_id": "1:763062986012:android:5248c065b40045728f86d9",
"api_key": [{"current_key": "AIza..."}]
```

3. Buka `lib/firebase_options.dart` dan isi:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIza...',  // ← dari google-services.json api_key.current_key
  appId: '1:763062986012:android:5248c065b40045728f86d9',
  messagingSenderId: '763062986012',  // ← project_number
  projectId: 'lettuce-monitoring-165fd',
  databaseURL: 'https://lettuce-monitoring-165fd-default-rtdb.firebaseio.com',
  storageBucket: 'lettuce-monitoring-165fd.appspot.com',
);
```

### Database URL

Cari di Firebase Console → Realtime Database → tab Data, lihat di atas panel:

```
Database URL: https://lettuce-monitoring-165fd-default-rtdb.firebaseio.com
```

### Verifikasi

Setelah setup, jalankan:

```bash
flutter pub get
flutter run
```

Dashboard harus menampilkan data dari Firebase (bukan demo data).

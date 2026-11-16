## Debug — Firebase Data Tidak Muncul

Jika setelah setup, dashboard masih menampilkan data demo, ini checklist:

### 1. Cek Database Structure di Firebase Console

Buka: `https://console.firebase.google.com`

Pilih project → **Realtime Database** → tab **Data**

Pastikan ada struktur:
```json
{
  "sensors": {
    "latest": {
      "ph": 6.2,
      "tds": 780,
      ...
    }
  }
}
```

Jika kosong → [lanjut ke step 2]

### 2. Cek Credentials di firebase_options.dart

Buka file `lib/firebase_options.dart`:

- ✓ `projectId` harus `'lettuce-monitoring-165fd'`
- ✓ `databaseURL` harus `'https://lettuce-monitoring-165fd-default-rtdb.firebaseio.com'`
- ✓ `apiKey` dari `google-services.json` harus benar (bukan `YOUR_API_KEY_HERE`)
- ✓ `appId` harus match dengan `google-services.json`

Jika ada `YOUR_API_KEY_HERE` → belum di-edit dengan benar.

### 3. Buka Console & Lihat Error

Run app dengan:
```bash
flutter run -v
```

Di output console, cari line yang dimulai dengan `[firebase]` atau `[Firestore]`.

Catat error-nya → cek FIREBASE_SETUP.md di section "Troubleshooting".

### 4. Cek Security Rules

Buka Firebase Console → **Realtime Database** → tab **Rules**

Harus ada:
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

Jika tidak → edit & publish.

### 5. Manual Test di Firebase Console

Di tab **Data**, tambah data test:
```
sensors → latest → ph: 7.5
```

Tekan Enter. App harus update dalam 1-2 detik.

Jika tetap tidak muncul → Firebase tidak connect ke app.

---

## Sementara Database Ditest

App sekarang fallback ke `DemoData` jika Firebase kosong. Ini safe untuk development.

Check console output untuk error message Firebase.

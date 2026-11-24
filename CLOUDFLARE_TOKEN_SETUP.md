## Setup Cloudflare Token untuk Flutter

Token `APP_TOKEN` dari Cloudflare harus tersimpan di device lokal secara aman (bukan di kode).

### 1. Setup Token di Startup

Buat simple dialog saat pertama kali app dibuka (atau di Settings screen):

```dart
// main.dart atau settings_screen.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'lib/services/cloudflare_service.dart';

Future<void> setupCloudflareToken() async {
  final cf = CloudflareService();
  final token = await cf.getAppToken();
  
  if (token == null) {
    // Show dialog untuk user input token
    // Simpan via: cf.setAppToken(userInputToken);
  }
}
```

### 2. Ambil APP_TOKEN dari Cloudflare Console

1. Buka: `https://dash.cloudflare.com` → Workers → smart-hydroponic-api
2. Settings → Variables
3. Lihat nilai `APP_TOKEN` (misalnya: `app_xxx...`)
4. Copy token ini

### 3. Input Token ke Flutter App

Saat app pertama kali buka:

```dart
final cf = CloudflareService();
await cf.setAppToken('app_xxx...'); // Dari Cloudflare
```

Token otomatis tersimpan di **flutter_secure_storage** (encrypted).

### 4. Test Koneksi

```dart
final cf = CloudflareService();
final photos = await cf.listPhotos();
print('Found ${photos.length} photos');
// Kalau berhasil, akan melihat daftar foto dari Cloudflare R2
```

### 5. Jangan Hardcode Token!

❌ **Jangan:**
```dart
const appToken = 'app_xxx...'; // Ini di-push ke git!
```

✅ **Lakukan:**
```dart
final token = await CloudflareService().getAppToken();
```

---

## Troubleshooting

| Error | Penyebab | Solusi |
|-------|---------|--------|
| `Cloudflare token not set` | Token belum di-setup | Jalankan `cf.setAppToken()` |
| `401 Unauthorized` | Token salah atau expired | Periksa di Cloudflare Console, generate ulang |
| `Failed to list photos: 403` | Token tidak punya permission | Pastikan APP_TOKEN ada di Worker secrets |
| Connection timeout | Network issue atau Worker down | Test `/health` endpoint terlebih dahulu |

---

## Setup untuk Tim

Buat file `.env.example`:

```
CLOUDFLARE_APP_TOKEN=app_xxx_put_your_token_here
```

Tim yang pull harus:
1. Dapatkan APP_TOKEN dari lead developer
2. Set di app via dialog atau command:
   ```bash
   flutter run --dart-define=CF_APP_TOKEN=app_xxx...
   ```
   Lalu di kode:
   ```dart
   await cf.setAppToken(const String.fromEnvironment('CF_APP_TOKEN'));
   ```

# Refactoring Challenge dan Testing: letak file

Salin file-file ini ke project `campus_notify`:

| File di paket ini | Taruh di project | Catatan |
|---|---|---|
| `lib/routes.dart` | `lib/routes.dart` | GABUNGKAN dengan isi lama jika ada konstanta lain |
| `lib/messaging/route_from_message.dart` | `lib/messaging/route_from_message.dart` | file baru |
| `lib/data/api_errors.dart` | `lib/data/api_errors.dart` | file baru |
| `lib/messaging/push_service.dart` | `lib/messaging/push_service.dart` | MENGGANTI file lama (backup dulu) |
| `test/route_from_message_test.dart` | `test/route_from_message_test.dart` | file baru |

Setelah itu:

1. Di `HomePage`, ganti string `'/pengumuman/3'` dengan `Routes.announcementOf('3')`.
2. Di UI yang menampilkan error (mis. `LoginPage`), pakai `friendlyMessage(error)`.
3. Jalankan `flutter analyze` dan `flutter test`.

## Yang berubah dan alasannya

1. **Rute satu sumber kebenaran (`routes.dart`)**: deep link dari FCM dan GoRouter
   memakai konstanta yang sama, sehingga tidak ada string rute yang tersebar.
2. **`routeFromMessage` (fungsi murni)**: parsing `data.route` dipisah dari Firebase
   agar bisa diunit-test tanpa Firebase. Dipakai di foreground, background-diklik,
   dan terminated.
3. **`friendlyMessage` (`api_errors.dart`)**: pemetaan `DioException` ke pesan ramah
   pengguna (401, timeout, offline, 5xx), sehingga UI hanya menerima pesan.
4. **Tambahan di `push_service.dart`**: `_sendToken` dibungkus `try/catch` supaya
   `onTokenRefresh` tetap terpasang walau backend `/devices` belum tersedia.

Catatan: tes memakai import relatif (`../lib/...`) agar tidak bergantung pada nama
package. Jika lebih suka, ganti dengan `package:<nama_di_pubspec>/...`.

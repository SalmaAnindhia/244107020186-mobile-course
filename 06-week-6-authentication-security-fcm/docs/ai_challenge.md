# AI Challenge Documentation: Campus Notification App (FCM & Security)

Dokumentasi ini mencatat proses eksplorasi AI, evaluasi terhadap draf awal kode AI, daftar penolakan/perbaikan teknis, serta matriks verifikasi lifecycle token dan state notifikasi sesuai panduan Codelab Minggu 6.

---

## 1. AI Prompt

Prompt yang diberikan kepada asisten AI:

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications, flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

---

## 2. Output Draf Awal AI (Raw AI Draft)

Berikut draf awal yang dihasilkan oleh AI sebelum dilakukan audit manual:

```dart
// Draf Awal AI (Mengandung beberapa kesalahan arsitektur)
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushService {
  BuildContext? context; // KESALAHAN 1: Menyimpan BuildContext di service

  // KESALAHAN 2: Background handler ditaruh di dalam kelas
  @pragma('vm:entry-point')
  static Future<void> backgroundHandler(RemoteMessage message) async {
    print("Background message received: ${message.data}");
    // KESALAHAN 3: Mencoba navigasi langsung di background isolate
    // Navigator.of(context).pushNamed(message.data['route']);
  }

  Future<void> init(BuildContext ctx) async {
    context = ctx;
    
    // Permission
    await FirebaseMessaging.instance.requestPermission();

    // Token
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token"); // KESALAHAN 4: Mencetak token sensitif secara utuh ke console

    // Token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      // KESALAHAN 5: Hanya print token baru, tidak mengirim ke API server
      print("Token Refreshed: $newToken");
    });

    // Topic
    await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');

    // Foreground: AI lupa konfigurasi local notifications channel
    FirebaseMessaging.onMessage.listen((message) {
      print("Foreground message: ${message.notification?.title}");
    });

    // Klik background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Navigator.pushNamed(context!, message.data['route']);
    });
  }
}
```

---

## 3. AI Verification Checklist & Audit Manual

| No | Kriteria Evaluasi | Status AI Awal | Tindakan & Keputusan Teknis Kami |
|---|---|---|---|
| 1 | **Background handler fungsi top-level + `@pragma('vm:entry-point')`** | ❌ Gagal (Sebagai static method dalam kelas) | **DITOLAK & DIPERBAIKI**: Dikeluarkan dari kelas menjadi fungsi top-level global murni. Background message berjalan di Isolate terpisah. Method kelas dapat terkena tree-shaking AOT dan gagal dipanggil oleh platform native. |
| 2 | **Tidak ada akses `BuildContext` di background isolate** | ❌ Gagal (Menyimpan field `BuildContext` dan mencoba navigasi) | **DITOLAK & DIPERBAIKI**: Dihapus total. Di background isolate, Flutter UI tree belum siap dan `BuildContext` bernilai null. Navigasi dipindahkan ke saat user mengetuk notifikasi (`onMessageOpenedApp` / `getInitialMessage`). |
| 3 | **`onTokenRefresh` menyinkronkan token ke backend** | ❌ Gagal (Hanya mencetak ke konsol via `print`) | **DITOLAK & DIPERBAIKI**: Diganti dengan callback asinkron `onToken(token)` yang memicu HTTP request `POST /devices` ke API kampus agar database backend tidak menyimpan token basi. |
| 4 | **Banner heads-up Foreground menggunakan Local Notifications** | ❌ Gagal (Hanya logging, tidak menampilkan notifikasi visual) | **DITOLAK & DIPERBAIKI**: Diimplementasikan menggunakan `FlutterLocalNotificationsPlugin.show()` dengan `AndroidNotificationDetails` berprioritas tinggi dan `DarwinNotificationDetails` untuk iOS. |
| 5 | **Penanganan klik rute di 3 App State (Foreground, Background, Terminated)** | ⚠️ Sebagian (Hanya menangani `onMessageOpenedApp`, lupa `getInitialMessage`) | **DIPERBAIKI**: Menambahkan `handleTerminated()` menggunakan `FirebaseMessaging.instance.getInitialMessage()` serta parsing data rute murni via `routeFromMessage()`. |
| 6 | **Keamanan Token & Kepatuhan OWASP Mobile** | ❌ Gagal (Mencetak full token ke terminal) | **DITOLAK & DIPERBAIKI**: Menghapus `print(token)` sensitif. Pada UI dibuat fungsi `maskToken(token)` (`substring(0, 12) + '...'`) agar token tidak terekspos pada screenshot laporan. |

---

## 4. Rincian Perbedaan Platform (Android 13+ vs iOS)

Dalam draf final kami, perbedaan arsitektur kedua platform ditangani secara ketat:

### Android 13+ (API Level 33+)
- Membutuhkan izin runtime eksplisit `android.permission.POST_NOTIFICATIONS`.
- Memerlukan konfigurasi `NotificationChannel` dengan `Importance.high` agar notifikasi lokal di foreground dapat muncul sebagai heads-up pop-up banner.
- Ikon notifikasi menggunakan resource drawable Android native (`@mipmap/ic_launcher`).

### iOS (Apple Push Notification service - APNs)
- Membutuhkan penanganan `DarwinInitializationSettings` dengan opsi `requestAlertPermission`, `requestBadgePermission`, dan `requestSoundPermission`.
- Background notification membutuhkan capability *Remote Notifications* dan APNs Authentication Key (.p8) di Firebase Console.
- Tidak memerlukan Notification Channel terpisah seperti pada sistem Android NotificationManager.

---

## 5. Matriks Pengujian Tiga App State

| App State | Perilaku yang Diharapkan | Mekanisme Handler | Hasil Pengujian |
|---|---|---|---|
| **Foreground** | Aplikasi sedang dibuka aktif. Banner sistem otomatis FCM tidak muncul; digantikan banner lokal buatan `flutter_local_notifications`. Saat banner diklik, navigasi diarahkan ke `/pengumuman/3`. | `FirebaseMessaging.onMessage` + `_local.show()` + `onDidReceiveNotificationResponse` | ✅ Berhasil (Banner lokal muncul dan deep link berfungsi) |
| **Background** | Aplikasi di-minimize (tombol Home). Banner sistem native muncul otomatis di tray notifikasi. Saat banner diklik, aplikasi terbuka dan diarahkan ke rute `/pengumuman/3`. | Banner sistem Android/iOS + `FirebaseMessaging.onMessageOpenedApp` | ✅ Berhasil (Aplikasi resume langsung ke halaman detail) |
| **Terminated** | Aplikasi dimatikan total (swipe-close). Banner sistem native muncul di tray notifikasi. Saat banner diklik, aplikasi diluncurkan dari nol dan langsung diarahkan ke `/pengumuman/3`. | `FirebaseMessaging.instance.getInitialMessage()` + pending route handler pada `main.dart` | ✅ Berhasil (Rute initial terbaca saat startup dan redirect berhasil) |

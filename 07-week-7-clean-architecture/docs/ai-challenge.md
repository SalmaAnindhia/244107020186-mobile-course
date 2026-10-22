# AI Challenge — Minggu 7: Clean Architecture

Referensi: [Codelab #07, bagian AI Challenge](https://jti-polinema.github.io/flutter-codelab/07-minggu-7-clean-architecture/index.html#5)

## 1. Prompt

```
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

## 2. Output awal AI (ringkasan)

**Struktur usulan**

```
lib/
├── core/                      # failure, util murni Dart
├── features/
│   ├── auth/{domain,data,presentation}
│   └── announcements/{domain,data,presentation}
├── messaging/                 # infrastruktur FCM lintas fitur
└── main.dart, routes.dart
```

**Nasib file lama**

| File lama | Usulan AI |
|---|---|
| `pages/login_page.dart` | Pindah ke `features/auth/presentation/pages/` |
| `pages/announcement_page.dart` | Pindah ke `features/announcements/presentation/pages/`; data statis dipecah ke repository |
| `pages/home_page.dart` | Pindah ke `features/home/presentation/pages/`; panggilan `PushService` dikeluarkan dari widget |
| `data/auth_repository.dart` | **Pecah:** interface ke `auth/domain/repositories/`, implementasi ke `auth/data/repositories/` |
| `data/api_errors.dart` | Pindah ke `core/failures.dart` sebagai `sealed class Failure` |
| `data/api_client.dart`, `data/token_store.dart` | Pindah ke layer `data`, hanya dipakai repository impl |
| `providers/auth_provider.dart` | Pindah ke `auth/presentation/providers/` |
| `messaging/*` | Tetap, karena infrastruktur lintas fitur |

**Bagian yang over-engineering untuk CRUD sederhana**

- Use case yang hanya meneruskan satu panggilan repository (mis. `GetAnnouncement`, `Logout`). Repository langsung ke notifier sudah cukup.
- Entity dan model terpisah untuk data yang bentuknya identik tanpa aturan bisnis.
- Use case dibenarkan bila ada aturan bisnis yang layak diuji sendiri, menggabungkan beberapa repository, atau dipakai ulang di banyak layar.

**Wiring DI (Riverpod, tanpa package tambahan)**

```dart
final authRepositoryProvider = Provider<AuthRepository>((_) => AuthRepositoryImpl());
final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);
```

**Trade-off yang disebut AI:** file bertambah banyak dan setup lebih lama, dibayar dengan testabilitas dan isolasi fitur.

## 3. Verifikasi (AI Verification Checklist)

| Pemeriksaan | Hasil |
|---|---|
| Interface di `domain`, implementasi di `data` | Lolos: `auth_repository.dart` (interface) dan `auth_repository_impl.dart` terpisah |
| `domain` dan `core` bebas import Flutter / Dio / SQLite / Firebase | Lolos: hasil pencarian 0 (lihat bagian 5) |
| Use case tidak dibuat untuk CRUD satu baris tanpa alasan | **Sebagian gagal:** `LogoutUseCase` dan `GetAnnouncementUseCase` hanya meneruskan satu panggilan |
| Mapping hanya di model | Lolos: `fromJson/toJson` hanya di `AuthSessionModel` |
| Widget tidak membuat repository sendiri | Lolos: semua lewat provider Riverpod |

## 4. Usulan AI vs keputusan final

| Usulan AI | Keputusan final | Alasan |
|---|---|---|
| Feature-first (`auth`, `announcements`) | **Diterima**, ditambah `features/home` | Project punya lebih dari satu fitur; tiap fitur bisa berdiri sendiri |
| `messaging/` tetap di luar fitur | **Diterima** | Infrastruktur lintas fitur, tidak berubah dari Minggu 6 |
| Pecah `auth_repository.dart` jadi interface + impl | **Diterima** | Inti perbaikan: domain mendefinisikan kontrak, data mengikutinya |
| Data statis pengumuman pindah ke repository | **Diterima** | Widget tidak lagi memuat logika bisnis atau data |
| `Failure` sealed di `core/` | **Diterima sebagian** | `failures.dart` dibuat, tetapi repository masih melempar `Exception`; pemetaan ke `Failure` belum dilakukan |
| Hindari use case satu baris | **Ditolak sebagian** | `LogoutUseCase` dan `GetAnnouncementUseCase` dipertahankan agar pola tiap fitur seragam. Di project nyata keduanya bisa dihapus |
| Tanpa package DI tambahan | **Diterima** | Riverpod `Provider` sudah cukup; tidak ada dependency baru di `pubspec.yaml` |
| `api_client.dart` dan `token_store.dart` tetap di `data` | _isi: sesuaikan dengan nasib kedua file di struktur akhir_ | |

## 5. Hasil tiga pemeriksaan sterilitas

Dijalankan dari root project di PowerShell dengan `rg`:

```
rg "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib -g "**/presentation/**"
rg "import 'package:(flutter|dio|sqflite|firebase)" lib -g "**/domain/**" -g "lib/core/**"
```

| Pemeriksaan | Folder | Hasil |
|---|---|---|
| Widget menyentuh Dio / database / storage / `jsonDecode` | `presentation` | **0 hasil** |
| Import Flutter / Dio / SQLite / Firebase | `domain` dan `core` | **0 hasil** |

Pemeriksaan lain:

- `flutter test`: **4 test lulus** (3 `LoginUseCase`, 1 `GetAnnouncementUseCase`, semuanya dengan repository palsu).
- `flutter analyze`: 1 info `unnecessary_underscores` di `lib/main.dart:32`. _isi: bersih setelah diperbaiki._

## 6. Keputusan final

1. **Feature-first** dengan tiga layer; dependensi hanya mengarah ke dalam (presentation → domain ← data).
2. **Messaging tetap lintas fitur** di `lib/messaging/`.
3. **Use case tetap dipakai merata** demi konsistensi belajar, dengan catatan bahwa untuk operasi satu baris repository langsung ke notifier sebenarnya cukup.
4. **Pemetaan exception ke `Failure`** belum diterapkan; ini pekerjaan lanjutan.
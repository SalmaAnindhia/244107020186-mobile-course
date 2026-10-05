# Minggu 4: Networking & REST API (Flutter)

> **Nama:** [ISI NAMA] | **NIM:** [ISI NIM] | **Kelas:** [ISI KELAS]

Aplikasi Flutter yang menampilkan daftar data dari REST API ([JSONPlaceholder](https://jsonplaceholder.typicode.com)) dengan arsitektur **UI → Provider (Riverpod) → Repository → Dio → API**. Aplikasi menangani empat state tampilan (loading, error, empty, success), mendukung pagination dengan infinite scroll, dan memiliki halaman detail post.

---

## Tujuan

- Memahami konsep HTTP, REST API, dan JSON.
- Memetakan JSON ke model Dart dengan aman null.
- Menerapkan repository pattern agar UI tidak memanggil API secara langsung.
- Mengonfigurasi Dio (base URL, timeout, interceptor) dan menangani error jaringan.
- Menampilkan state loading, error, empty, dan success dengan `AsyncValue` + Riverpod.
- Menerapkan pagination dasar (infinite scroll).

## Fitur Utama

1. **Daftar post** dari `GET /posts` (100 data) dengan pull-to-refresh dan tombol refresh.
2. **Empat state UI:** loading, error (pesan ramah pengguna + tombol "Coba lagi"), empty, dan success.
3. **Infinite scroll** dengan `?_page=N&_limit=10`, dilengkapi guard agar tidak terjadi request ganda dan indikator akhir data.
4. **Halaman detail** (`/post/:id`) dengan GoRouter. Data diambil dari list yang sudah dimuat, atau lewat repository jika halaman dibuka langsung.
5. **Dio terpusat:** base URL, timeout 10 detik, dan interceptor logging di satu tempat.
6. **Model `fromJson` aman null** sehingga tidak crash saat field hilang atau tipe berubah.
7. **Pesan error ramah pengguna** untuk timeout, gagal koneksi, 401/403, 404, dan error server.
8. **Hasil AI Challenge:** repository layer untuk endpoint `/comments` (lihat folder `docs/`).

## Stack Teknologi

| Teknologi | Fungsi |
| --- | --- |
| Flutter / Dart | Framework aplikasi |
| [dio](https://pub.dev/packages/dio) | HTTP client (timeout, interceptor, error terstruktur) |
| [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) | State management (`AsyncNotifier`, `Notifier`, `FutureProvider`) |
| [go_router](https://pub.dev/packages/go_router) | Navigasi ke halaman detail |
| JSONPlaceholder | API dummy (tanpa API key) |

## Struktur Folder

```
04-week-4-networking-rest-api/
├── lib/
│   ├── main.dart
│   ├── data/
│   │   ├── api_client.dart          # konfigurasi Dio terpusat
│   │   ├── network_errors.dart      # friendlyErrorMessage
│   │   ├── providers.dart           # dioProvider, postListProvider, postDetailProvider
│   │   ├── paged_posts.dart         # state + notifier pagination
│   │   ├── comment_providers.dart   # hasil AI Challenge
│   │   ├── models/                  # Post (dan model Comment)
│   │   └── repositories/            # PostRepository (dan CommentRepository)
│   ├── pages/
│   │   ├── post_list_page.dart
│   │   ├── paged_post_page.dart
│   │   └── post_detail_page.dart
│   └── widgets/
│       └── post_tile.dart
├── test/
│   └── post_test.dart
├── docs/                            # dokumentasi AI Challenge
├── screenshots/
└── README.md
```

## Cara Menjalankan

```bash
# 1. Masuk ke folder project
cd 04-week-4-networking-rest-api

# 2. Install dependency
flutter pub get

# 3. Jalankan di emulator atau perangkat
flutter run

# 4. Analisis kode dan jalankan test
flutter analyze
flutter test
```

Halaman awal adalah daftar post (`/`). Halaman infinite scroll tersedia di route `/paged`, dan halaman detail dibuka dengan mengetuk salah satu post.

## Arsitektur

```
UI (ConsumerWidget) --watch--> Provider (AsyncValue)
Provider --panggil--> Repository --pakai--> Dio --HTTP--> REST API
```

- **UI** hanya membaca provider dan tidak pernah memanggil Dio.
- **Repository** adalah satu-satunya pintu ke API. Exception dibiarkan naik.
- **Provider** mengubah exception menjadi `AsyncError` secara otomatis, lalu UI menampilkan pesan ramah lewat `friendlyErrorMessage`.

## Hasil

### Daftar post (success)

> 📸 Tampilan daftar 100 post setelah data berhasil dimuat.

![Daftar post](screenshots/100Data.jpg)

### State loading

> 📸 Tampilan `CircularProgressIndicator` saat data sedang diambil.

![Loading](screenshots/iniloading.png)

### State error dan tombol "Coba lagi"

> 📸 Matikan internet (mode pesawat), tekan refresh, lalu tangkap pesan error dan tombol "Coba lagi".

![Error](screenshots/tidakterhubung.jpg)

### Error baseUrl salah

> 📸 Mengubah `baseUrl` sementara ke URL salah, hasilnya sama seperti yg diatas.

![Error baseUrl](screenshots/tidakterhubung.jpg)

> 📸 Scroll sampai habis sampai muncul teks "Semua data termuat."

![Akhir data](screenshots/databertambah.jpg)

### Hasil `flutter analyze` dan `flutter test`

> 📸 Terminal yang menunjukkan `No issues found!` dan `All tests passed!`.

![Analyze dan test](screenshots/fluttertest.jpg)

## Pengujian

Test ada di `test/post_test.dart` dan semuanya berjalan tanpa internet (memakai `FakePostRepository`). Hasil terakhir `flutter test`: ![Hasil Flutter Test](screenshots/fluttertest.jpg)

| Test | Yang diuji |
| --- | --- |
| `fromJson` field hilang | `Post.fromJson({'id': 7})` menghasilkan `title` kosong dan `userId` 0 tanpa crash |
| Pesan error | `friendlyErrorMessage` untuk `connectionError` memuat kata "terhubung" |
| Provider sukses | `postListProvider` dengan repository palsu menghasilkan data yang benar |
| Provider error | `postListProvider` dengan repository palsu melempar `DioException` |
| [ISI] | Test tambahan (misal test AI Challenge atau edge case buatan sendiri) |

## AI Challenge

Prompt, output awal AI, perbaikan yang dilakukan, dan hasil testing didokumentasikan di folder [`docs/`](docs/).

| Item | File |
| --- | --- |
| Prompt yang digunakan | `docs/01-prompt.md` |
| Output awal AI | `docs/02-output-awal-ai.md` |
| Perbaikan dan alasan | `docs/03` |
| Hasil testing | `docs/[ISI NAMA FILE]` |

## Refactoring

Tiga refactoring yang dikerjakan setelah aplikasi berjalan:

1. **`PostTile`** diekstrak ke `lib/widgets/post_tile.dart` agar `ListView.builder` pendek dan dipakai ulang di halaman list dan paged.
2. **`friendlyErrorMessage`** dipindah ke `lib/data/network_errors.dart` agar bisa dipakai bersama oleh semua halaman.
3. **Halaman detail** `/post/:id` ditambahkan dengan GoRouter. Datanya diambil dari list yang sudah dimuat, atau lewat `postDetailProvider` bila halaman dibuka langsung.

## Refleksi

### 1. Mengapa UI dilarang memanggil Dio langsung?

Agar logika jaringan (URL, timeout, parsing, error) tidak bercampur dengan tampilan. Kalau dilanggar:

- **Sulit diuji:** test butuh internet atau mock Dio yang rumit. Dengan repository cukup override provider dengan `FakePostRepository`.
- **Sulit diubah:** ganti `baseUrl` atau sumber data berarti mengubah banyak widget.
- **Kode berulang dan tidak konsisten:** try/catch, parsing, dan pesan error ditulis ulang di tiap widget.

### 2. Pagination client-side vs server

- **Client-side cukup** untuk data kecil (puluhan sampai ratusan item) yang memang datang sebagai satu respons.
- **Server (`_page`/`_limit`) wajib** untuk data besar atau terus bertambah: loading awal cepat, hemat kuota dan memori. Kalau API mendukung, selalu pakai.

### 3. Dari exception repository ke `AsyncError`

Repository tidak menelan exception, jadi `DioException` naik ke `build()` pada `AsyncNotifier`. Riverpod menangkapnya dan mengubah state menjadi `AsyncError`, lalu UI tinggal menyediakan cabang `error:` di `.when(...)`.

Try/catch eksplisit tetap perlu saat `state` diatur manual di luar `build()`, seperti `refresh()`, `loadFirstPage()`, dan `loadNextPage()` (agar data lama tetap tampil saat error).

### 4. Bagian hasil AI yang saya perbaiki

- **`fromJson` crash pada tipe salah.** Versi AI memakai `as num?` dan `as String?`, yang aman untuk field hilang tapi melempar exception kalau tipe salah. Ditemukan lewat test edge case buatan sendiri (`type 'String' is not a subtype of type 'num?'`). Diganti dengan pengecekan `is` (`id is num ? id.toInt() : 0`).
- **Timeout tersebar.** AI menambahkan `Options(sendTimeout, receiveTimeout)` di `fetchComments`, padahal `createDio()` sudah mengatur timeout 10 detik. Dihapus agar terpusat di satu tempat.
- **Pesan error duplikat.** `commentErrorMessage` hampir sama dengan `friendlyErrorMessage`. Disatukan di `network_errors.dart`, dan komentar hanya mengganti pesan 404 lewat parameter.

## Checklist Verifikasi Mandiri

- [x] UI tidak memanggil Dio langsung, semua akses data lewat repository + provider.
- [x] Empat state tampil benar: loading, error (+ retry), empty, success.
- [x] Pagination: data bertambah saat scroll, tidak ada request ganda, ada indikator akhir data.
- [x] `flutter analyze` tanpa issue **(centang setelah hasil terakhir benar-benar bersih)**
- [x] Semua test lulus.
- [x] Hasil AI diverifikasi dan didokumentasikan di folder `docs/` 

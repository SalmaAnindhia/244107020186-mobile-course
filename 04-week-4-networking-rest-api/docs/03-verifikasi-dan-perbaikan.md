# 03 - Verifikasi dan Perbaikan

## AI Verification Checklist

| # | Pertanyaan | Temuan |
| --- | --- | --- |
| 1 | Apakah UI memanggil Dio langsung? | **Tidak.** UI hanya membaca `commentListProvider`. Dio hanya dipakai di `CommentRepository`, yang diambil lewat `commentRepositoryProvider`. |
| 2 | Apakah `fromJson` aman null? | **Sebagian.** Versi AI memakai `as num?` dan `as String?`. Aman untuk field hilang, tetapi **crash** kalau tipe salah: `type 'String' is not a subtype of type 'num?' in type cast`. Ditemukan lewat edge case test buatan sendiri. |
| 3 | Apakah semua `DioExceptionType` dipetakan? | **Sebagian besar.** `connectionTimeout`, `sendTimeout`, `receiveTimeout`, `connectionError`, dan `badResponse` (404, 5xx) dipetakan spesifik. `badCertificate`, `cancel`, `unknown` jatuh ke pesan umum. Status 4xx selain 404 (mis. 401/403) hanya mendapat pesan "Permintaan gagal". Dinilai cukup untuk cakupan tugas. |
| 4 | Apakah `baseUrl`/timeout terpusat? | **Belum.** `baseUrl`, `connectTimeout`, dan `receiveTimeout` sudah di `createDio()`, tetapi AI menambah `Options(sendTimeout, receiveTimeout)` lagi di `fetchComments`, sehingga timeout tersebar di dua tempat. |
| 5 | Apakah test menguji field hilang, bukan hanya happy path? | **Ya.** Test AI menguji `Comment.fromJson({'id': 5})`. Namun hanya mencakup model, tidak ada test repository atau provider untuk komentar. Saya menambah 1 edge case sendiri: tipe data salah. |
| 6 | Apakah lolos `flutter analyze` dan `flutter test`? | **Tidak sepenuhnya pada percobaan pertama.** Test `tipe yang salah` gagal. Setelah perbaikan, lihat dokumen 04. |

## Perbaikan yang Dilakukan

### 1. `fromJson` crash pada tipe yang salah

- **Masalah:** cast langsung `json['id'] as num?` melempar exception kalau field ada tetapi bertipe salah. Komentar di kode AI mengklaim aman, padahal hanya aman untuk field hilang.
- **Perubahan:** diganti pengecekan tipe dengan `is`, yang tidak pernah melempar exception.

  ```dart
  factory Comment.fromJson(Map<String, dynamic> json) {
    final postId = json['postId'];
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    final body = json['body'];

    return Comment(
      postId: postId is num ? postId.toInt() : 0,
      id: id is num ? id.toInt() : 0,
      name: name is String ? name : '',
      email: email is String ? email : '',
      body: body is String ? body : '',
    );
  }
  ```
- **Alasan:** API nyata sering mengirim tipe yang tidak sesuai dokumentasi. Model harus tahan terhadap field hilang **dan** tipe salah.

### 2. Timeout tersebar di dua tempat

- **Masalah:** `Options(sendTimeout, receiveTimeout)` di `fetchComments` menduplikasi konfigurasi di `createDio()`. `sendTimeout` juga tidak berpengaruh pada GET tanpa body.
- **Perubahan:** menghapus `Options(...)` dan konstanta `_timeout` dari repository.
- **Alasan:** satu sumber kebenaran. Mengubah timeout cukup di `api_client.dart`.

### 3. Fungsi pesan error duplikat

- **Masalah:** `commentErrorMessage` hampir identik dengan `friendlyErrorMessage` di `providers.dart`.
- **Perubahan:** keduanya disatukan di `lib/data/network_errors.dart`. `friendlyErrorMessage` menerima parameter `notFoundMessage`, dan `commentErrorMessage` menjadi pembungkus tipis:

  ```dart
  String commentErrorMessage(Object error) => friendlyErrorMessage(
        error,
        notFoundMessage: 'Komentar tidak ditemukan (404).',
      );
  ```
- **Alasan:** menghindari logika yang sama di dua tempat dan memastikan pesan error konsisten.

### 4. Edge case test tambahan

Ditambahkan di `test/comment_test.dart`:

```dart
test('Comment.fromJson aman terhadap tipe yang salah', () {
  final comment = Comment.fromJson({'id': 'bukan-angka', 'name': 123});

  expect(comment.id, 0);
  expect(comment.name, '');
});
```

Test ini yang membongkar bug nomor 1.

## Keterbatasan yang Diketahui

- Belum ada test untuk `CommentRepository` maupun `commentListProvider` dengan repository palsu.
- Di Flutter web, kegagalan request (termasuk 404 karena CORS) dapat dilaporkan sebagai `connectionError`, sehingga pesan 404 hanya terlihat di platform native.

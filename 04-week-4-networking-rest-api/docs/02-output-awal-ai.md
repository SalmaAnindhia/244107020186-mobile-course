# 02 - Output Awal AI (sebelum diperbaiki)

Kode di bawah ini disalin apa adanya dari hasil AI, **sebelum** ada perbaikan apa pun.

## `lib/data/models/comment.dart`

```dart
/// Model satu komentar dari GET /comments.
/// Semua field dibuat non-null; nilai default dipakai kalau JSON tidak lengkap.
class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  /// fromJson aman null: `as num?` lalu `?? 0` mencegah crash
  /// "type 'Null' is not a subtype" kalau field hilang atau tipenya berubah.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}
```

## `lib/data/repositories/comment_repository.dart`

```dart
import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Satu-satunya pintu ke API untuk data komentar.
/// UI tidak boleh memanggil Dio langsung.
class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  /// Batas waktu 10 detik untuk request ini.
  static const _timeout = Duration(seconds: 10);

  /// GET /comments?postId={postId}
  /// Exception (DioException) sengaja tidak ditangkap di sini,
  /// supaya provider otomatis mengubahnya menjadi AsyncError.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      // connectTimeout sudah 10 detik di BaseOptions (api_client.dart).
      // Di sini kita pastikan send/receive timeout juga 10 detik.
      options: Options(sendTimeout: _timeout, receiveTimeout: _timeout),
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
```

## `lib/data/comment_providers.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart'; // untuk dioProvider
import 'repositories/comment_repository.dart';

/// Menyediakan CommentRepository dengan Dio yang sama dengan fitur posts.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// Notifier per postId. Di Riverpod 3, argumen family diterima lewat constructor.
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  CommentListNotifier(this.postId);
  final int postId;

  @override
  Future<List<Comment>> build() {
    // Exception dari repository otomatis menjadi AsyncError,
    // tanpa try/catch manual.
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }
}

/// Pemakaian: ref.watch(commentListProvider(postId))
final commentListProvider = AsyncNotifierProvider.family<
    CommentListNotifier, List<Comment>, int>(
  CommentListNotifier.new,
  // Matikan retry otomatis Riverpod 3 supaya error langsung tampil.
  retry: (retryCount, error) => null,
);

/// Mengubah error teknis menjadi pesan yang aman dibaca pengguna.
String commentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      // Timeout
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
      // Tidak bisa terhubung (offline, DNS gagal, dll.)
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
      // Server membalas dengan status error
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Komentar tidak ditemukan (404).';
        if (code != null && code >= 500) {
          return 'Server sedang bermasalah ($code). Coba lagi nanti.';
        }
        return 'Permintaan gagal ($code).';
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  return 'Terjadi kesalahan tak terduga.';
}
```

## `test/comment_test.dart` (test dari AI)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:week_4_networking_rest_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson aman terhadap field yang hilang', () {
    // Hanya id yang ada; sisanya hilang.
    final comment = Comment.fromJson({'id': 5});

    expect(comment.id, 5);
    expect(comment.postId, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}
```

Catatan: test kedua (`tipe yang salah`) **bukan** dari AI. Itu edge case tambahan buatan sendiri, dibahas di dokumen 03.

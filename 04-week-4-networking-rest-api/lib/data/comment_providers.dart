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
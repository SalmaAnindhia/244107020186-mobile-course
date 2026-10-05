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
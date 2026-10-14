import 'package:dio/dio.dart';

/// Memetakan error (terutama DioException) menjadi pesan ramah pengguna,
/// agar UI hanya menerima teks, bukan exception mentah.
String friendlyMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi terlalu lama. Coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) return 'Sesi berakhir. Silakan login ulang.';
        if (code == 403) return 'Kamu tidak punya akses.';
        if (code != null && code >= 500) return 'Server sedang bermasalah.';
        return 'Permintaan gagal ($code).';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
  return 'Terjadi kesalahan. Coba lagi.';
}

/// Domain failure types — murni Dart, tidak ada import Flutter/Dio/Firebase.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Email atau kata sandi tidak valid.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server sedang bermasalah.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Terjadi kesalahan. Coba lagi.']);
}

import '../entities/auth_session.dart';

/// Kontrak repository auth — tinggal di domain layer.
/// Presentation dan use case bergantung pada abstraksi ini,
/// bukan pada implementasi konkret.
abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<String> refresh(String refreshToken);
  Future<void> saveSession(AuthSession session);
  Future<bool> isLoggedIn();
  Future<void> clearSession();
}

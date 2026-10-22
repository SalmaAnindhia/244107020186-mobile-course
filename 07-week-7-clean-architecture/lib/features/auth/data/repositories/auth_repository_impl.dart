import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementasi konkret AuthRepository menggunakan mock + FlutterSecureStorage.
/// Hidup di data layer — boleh tahu tentang storage.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }
    return AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
  }

  @override
  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await _storage.write(key: _accessKey, value: session.access);
    await _storage.write(key: _refreshKey, value: session.refresh);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _accessKey);
    return token != null;
  }

  @override
  Future<void> clearSession() => _storage.deleteAll();
}

import 'package:flutter_test/flutter_test.dart';
import 'package:week_7_clean_architecture/features/auth/domain/entities/auth_session.dart';
import 'package:week_7_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:week_7_clean_architecture/features/auth/domain/usecases/login_use_case.dart';

/// Fake repository — tidak butuh database atau jaringan sungguhan.
/// Mengimplementasikan kontrak AuthRepository (Liskov Substitution).
class FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }
    return AuthSession(
      access: 'fake-access-$email',
      refresh: 'fake-refresh-$email',
    );
  }

  @override
  Future<String> refresh(String refreshToken) async =>
      'fake-renewed-$refreshToken';

  @override
  Future<void> saveSession(AuthSession session) async {}

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<void> clearSession() async {}
}

void main() {
  late LoginUseCase loginUseCase;
  late FakeAuthRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    loginUseCase = LoginUseCase(fakeRepo);
  });

  group('LoginUseCase', () {
    test('mengembalikan AuthSession saat kredensial valid', () async {
      final session = await loginUseCase(
        email: 'salma@polinema.ac.id',
        password: 'password123',
      );
      expect(session.access, contains('salma@polinema.ac.id'));
      expect(session.refresh, isNotEmpty);
    });

    test('melempar Exception saat email tidak ada @', () async {
      expect(
        () => loginUseCase(email: 'bukan-email', password: 'password123'),
        throwsException,
      );
    });

    test('melempar Exception saat password < 6 karakter', () async {
      expect(
        () => loginUseCase(email: 'test@test.com', password: '123'),
        throwsException,
      );
    });
  });
}

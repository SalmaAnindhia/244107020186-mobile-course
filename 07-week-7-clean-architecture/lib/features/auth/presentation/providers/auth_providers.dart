import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';

// — DI: wiring repository dan use case via Riverpod —
final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepositoryImpl(),
);

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(authRepositoryProvider).isLoggedIn();

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(loginUseCaseProvider);
      final session = await useCase(email: email, password: password);
      await ref.read(authRepositoryProvider).saveSession(session);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider)();
    ref.invalidateSelf();
  }
}

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Use case: satu operasi bisnis — login.
/// Hidup di domain, tidak tahu apa pun tentang UI atau Dio.
class LoginUseCase {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<AuthSession> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}

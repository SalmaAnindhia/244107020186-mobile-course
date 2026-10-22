import '../repositories/auth_repository.dart';

/// Use case: logout — hapus sesi dari secure storage.
class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.clearSession();
}

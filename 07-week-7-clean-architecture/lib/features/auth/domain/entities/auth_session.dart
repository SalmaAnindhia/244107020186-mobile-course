/// Entity domain: objek bisnis murni tanpa toMap/fromMap/toJson.
/// Hidup di domain layer — tidak tahu tentang SQLite, Dio, atau Firebase.
class AuthSession {
  const AuthSession({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

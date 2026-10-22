import '../../domain/entities/auth_session.dart';

/// Model: representasi data + mapping ke entity.
/// Hidup di data layer — boleh tahu tentang JSON/SQLite.
class AuthSessionModel extends AuthSession {
  const AuthSessionModel({required super.access, required super.refresh});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        access: json['access'] as String,
        refresh: json['refresh'] as String,
      );

  Map<String, dynamic> toJson() => {'access': access, 'refresh': refresh};

  factory AuthSessionModel.fromEntity(AuthSession entity) =>
      AuthSessionModel(access: entity.access, refresh: entity.refresh);
}

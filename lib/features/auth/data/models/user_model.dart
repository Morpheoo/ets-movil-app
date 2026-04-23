import '../../domain/entities/user_entity.dart';

/// Data model que extiende UserEntity con capacidad de serialización JSON.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
  });

  /// Construye un UserModel a partir de un Map JSON (respuesta de API).
  ///
  /// Ejemplo de JSON esperado:
  /// ```json
  /// {
  ///   "id": "usr-001",
  ///   "email": "student@escom.ipn.mx",
  ///   "name": "Juan Pérez",
  ///   "role": "student"
  /// }
  /// ```
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      role: entity.role,
    );
  }
}

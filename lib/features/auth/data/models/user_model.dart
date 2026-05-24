import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.nombre,
    required super.email,
    required super.token,
    required super.rol,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      rol: json['rol'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'token': token,
    'rol': rol,
  };
}
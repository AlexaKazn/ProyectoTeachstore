import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String nombre;
  final String email;
  final String token;
  final String rol;

  const UserEntity({
    required this.id,
    required this.nombre,
    required this.email,
    required this.token,
    required this.rol,
  });

  @override
  List<Object> get props => [id, email, token];
}
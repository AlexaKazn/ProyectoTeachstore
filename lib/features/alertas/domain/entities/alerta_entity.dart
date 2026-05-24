import 'package:equatable/equatable.dart';

class AlertaEntity extends Equatable {
  final String producto;
  final String sucursal;
  final int stock;
  final String tipoAlerta;
  final String fechaAlerta;
  final String nivelUrgencia;

  const AlertaEntity({
    required this.producto,
    required this.sucursal,
    required this.stock,
    required this.tipoAlerta,
    required this.fechaAlerta,
    required this.nivelUrgencia,
  });

  @override
  List<Object> get props => [producto, sucursal, stock];
}

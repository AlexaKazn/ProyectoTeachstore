import 'package:equatable/equatable.dart';

class PrediccionEntity extends Equatable {
  final int anio;
  final int mes;
  final String nombreMes;
  final double ventasPredichas;
  final int unidadesPredichas;
  final double tasaCrecimiento;
  final String tendencia;
  final String modelo;

  const PrediccionEntity({
    required this.anio,
    required this.mes,
    required this.nombreMes,
    required this.ventasPredichas,
    required this.unidadesPredichas,
    required this.tasaCrecimiento,
    required this.tendencia,
    required this.modelo,
  });

  @override
  List<Object> get props => [anio, mes];
}

class RecomendacionEntity extends Equatable {
  final String tipo;
  final String descripcion;
  final String? producto;
  final String? accion;

  const RecomendacionEntity({
    required this.tipo,
    required this.descripcion,
    this.producto,
    this.accion,
  });

  @override
  List<Object?> get props => [tipo, descripcion];
}

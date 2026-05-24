import 'package:equatable/equatable.dart';

class VentaMensualEntity extends Equatable {
  final int anio;
  final int mes;
  final String nombreMes;
  final double totalVentas;
  final int totalUnidades;
  final int numTransacciones;

  const VentaMensualEntity({
    required this.anio,
    required this.mes,
    required this.nombreMes,
    required this.totalVentas,
    required this.totalUnidades,
    required this.numTransacciones,
  });

  @override
  List<Object> get props => [anio, mes];
}

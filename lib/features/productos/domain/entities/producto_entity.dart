import 'package:equatable/equatable.dart';

class StockItemEntity extends Equatable {
  final String producto;
  final String sucursal;
  final int stock;
  final String? tipoAlerta;
  final String? nivelUrgencia;

  const StockItemEntity({
    required this.producto,
    required this.sucursal,
    required this.stock,
    this.tipoAlerta,
    this.nivelUrgencia,
  });

  @override
  List<Object?> get props => [producto, sucursal, stock];
}

class ProductoTopEntity extends Equatable {
  final String producto;
  final String? categoria;
  final int cantidadVendida;
  final double ingresosTotales;

  const ProductoTopEntity({
    required this.producto,
    this.categoria,
    required this.cantidadVendida,
    required this.ingresosTotales,
  });

  @override
  List<Object?> get props => [producto, cantidadVendida];
}

import 'package:equatable/equatable.dart';

class DashboardSummaryEntity extends Equatable {
  final double totalVentas;
  final int totalClientes;
  final int totalProductos;
  final int alertasPendientes;
  final double crecimientoMensual;
  final int stockCritico;
  final int clientesVip;
  final int alertasActivas;
  final List<VentaMensual> ventasMensuales;

  const DashboardSummaryEntity({
    required this.totalVentas,
    required this.totalClientes,
    required this.totalProductos,
    required this.alertasPendientes,
    required this.crecimientoMensual,
    this.stockCritico = 0,
    this.clientesVip = 0,
    this.alertasActivas = 0,
    required this.ventasMensuales,
  });

  @override
  List<Object> get props => [
        totalVentas,
        totalClientes,
        totalProductos,
        alertasPendientes,
      ];
}

class VentaMensual {
  final String mes;
  final double total;
  const VentaMensual({required this.mes, required this.total});
}
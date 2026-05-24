import '../../domain/entities/dashboard_summary_entity.dart';

class DashboardSummaryModel extends DashboardSummaryEntity {
  const DashboardSummaryModel({
    required super.totalVentas,
    required super.totalClientes,
    required super.totalProductos,
    required super.alertasPendientes,
    required super.crecimientoMensual,
    super.stockCritico = 0,
    super.clientesVip = 0,
    super.alertasActivas = 0,
    required super.ventasMensuales,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalVentas: (json['total_ventas'] ?? 0).toDouble(),
      totalClientes: json['total_clientes'] ?? 0,
      totalProductos: json['total_productos'] ?? 0,
      alertasPendientes: json['alertas_activas'] ?? json['stock_critico'] ?? 0,
      crecimientoMensual: (json['crecimiento_mensual'] ?? 0).toDouble(),
      stockCritico: json['stock_critico'] ?? 0,
      clientesVip: json['clientes_vip'] ?? 0,
      alertasActivas: json['alertas_activas'] ?? 0,
      ventasMensuales: (json['ventas_mensuales'] as List? ?? [])
          .map((e) => VentaMensual(
                mes: e['nombre_mes'] ?? e['mes'] ?? '',
                total: (e['total_ventas'] ?? e['total'] ?? 0).toDouble(),
              ))
          .toList(),
    );
  }
}
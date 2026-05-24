import '../../domain/entities/dashboard_summary_entity.dart';
import '../models/dashboard_summary_model.dart';
import '../../../../core/network/api_client.dart';

abstract class DashboardDataSource {
  Future<DashboardSummaryModel> getSummary();
}

class DashboardRemoteDataSource implements DashboardDataSource {
  final ApiClient apiClient;
  DashboardRemoteDataSource(this.apiClient);

  @override
  Future<DashboardSummaryModel> getSummary() async {
    // Llamadas paralelas
    final results = await Future.wait([
      apiClient.dio.get('/dashboard/resumen'),
      apiClient.dio.get('/ventas/por-mes'),
      apiClient.dio.get('/alertas'),
    ]);

    final resumen = results[0].data as Map<String, dynamic>;
    final ventasData = results[1].data as Map<String, dynamic>;
    final alertasData = results[2].data as Map<String, dynamic>;

    final ventasList = (ventasData['resumen'] as List? ?? [])
        .map((e) => VentaMensual(
              mes: _shortMonth(e['nombre_mes'] ?? ''),
              total: (e['total_ventas'] ?? 0).toDouble(),
            ))
        .toList();

    return DashboardSummaryModel(
      totalVentas: (resumen['total_ventas'] ?? 0).toDouble(),
      totalClientes: resumen['total_clientes'] ?? 0,
      totalProductos: resumen['total_productos'] ?? 0,
      alertasPendientes: resumen['alertas_activas'] ?? resumen['stock_critico'] ?? 0,
      crecimientoMensual: (resumen['crecimiento_mensual'] ?? 0).toDouble(),
      ventasMensuales: ventasList,
      stockCritico: resumen['stock_critico'] ?? 0,
      clientesVip: resumen['clientes_vip'] ?? 0,
      alertasActivas: alertasData['total'] ?? 0,
    );
  }

  String _shortMonth(String mes) {
    const map = {
      'Enero': 'Ene', 'Febrero': 'Feb', 'Marzo': 'Mar',
      'Abril': 'Abr', 'Mayo': 'May', 'Junio': 'Jun',
      'Julio': 'Jul', 'Agosto': 'Ago', 'Septiembre': 'Sep',
      'Octubre': 'Oct', 'Noviembre': 'Nov', 'Diciembre': 'Dic',
    };
    return map[mes] ?? mes.substring(0, 3);
  }
}

class DashboardMockDataSource implements DashboardDataSource {
  @override
  Future<DashboardSummaryModel> getSummary() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const DashboardSummaryModel(
      totalVentas: 284750.50,
      totalClientes: 1243,
      totalProductos: 387,
      alertasPendientes: 3,
      crecimientoMensual: 12.4,
      stockCritico: 3,
      clientesVip: 5,
      alertasActivas: 3,
      ventasMensuales: [
        VentaMensual(mes: 'Ene', total: 21000),
        VentaMensual(mes: 'Feb', total: 28500),
        VentaMensual(mes: 'Mar', total: 24300),
        VentaMensual(mes: 'Abr', total: 31200),
        VentaMensual(mes: 'May', total: 29800),
        VentaMensual(mes: 'Jun', total: 35400),
      ],
    );
  }
}
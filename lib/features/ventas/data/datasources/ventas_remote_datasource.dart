import '../../../../core/network/api_client.dart';
import '../../domain/entities/venta_mensual_entity.dart';

abstract class VentasDataSource {
  Future<List<VentaMensualEntity>> getVentasPorMes();
}

class VentasRemoteDataSource implements VentasDataSource {
  final ApiClient apiClient;
  VentasRemoteDataSource(this.apiClient);

  @override
  Future<List<VentaMensualEntity>> getVentasPorMes() async {
    final res = await apiClient.dio.get('/ventas/por-mes');
    final data = res.data as Map<String, dynamic>;
    return (data['resumen'] as List? ?? [])
        .map((e) => VentaMensualEntity(
              anio: e['anio'] ?? 0,
              mes: e['mes'] ?? 0,
              nombreMes: e['nombre_mes'] ?? '',
              totalVentas: (e['total_ventas'] ?? 0).toDouble(),
              totalUnidades: e['total_unidades'] ?? 0,
              numTransacciones: e['num_transacciones'] ?? 0,
            ))
        .toList();
  }
}

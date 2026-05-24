import '../../../../core/network/api_client.dart';
import '../../domain/entities/producto_entity.dart';

abstract class ProductosDataSource {
  Future<List<ProductoTopEntity>> getProductosTop();
  Future<List<StockItemEntity>> getStockCritico();
}

class ProductosRemoteDataSource implements ProductosDataSource {
  final ApiClient apiClient;
  ProductosRemoteDataSource(this.apiClient);

  @override
  Future<List<ProductoTopEntity>> getProductosTop() async {
    final res = await apiClient.dio.get('/productos/top', queryParameters: {'limite': 8});
    final data = res.data as Map<String, dynamic>;
    return (data['productos'] as List? ?? [])
        .map((e) => ProductoTopEntity(
              producto: e['producto'] ?? '',
              categoria: e['categoria'],
              cantidadVendida: e['cantidad_vendida'] ?? 0,
              ingresosTotales: (e['ingresos_totales'] ?? 0).toDouble(),
            ))
        .toList();
  }

  @override
  Future<List<StockItemEntity>> getStockCritico() async {
    final res = await apiClient.dio.get('/productos/stock-critico');
    final data = res.data as Map<String, dynamic>;
    return (data['stock_critico'] as List? ?? [])
        .map((e) => StockItemEntity(
              producto: e['producto'] ?? '',
              sucursal: e['sucursal'] ?? '',
              stock: e['stock'] ?? 0,
              tipoAlerta: e['tipo_alerta'],
              nivelUrgencia: e['nivel_urgencia'],
            ))
        .toList();
  }
}

import '../../domain/entities/producto_entity.dart';
import '../../domain/repositories/productos_repository.dart';
import '../datasources/productos_remote_datasource.dart';

class ProductosRepositoryImpl implements ProductosRepository {
  final ProductosDataSource dataSource;
  ProductosRepositoryImpl(this.dataSource);

  @override
  Future<List<ProductoTopEntity>> getProductosTop() => dataSource.getProductosTop();

  @override
  Future<List<StockItemEntity>> getStockCritico() => dataSource.getStockCritico();
}

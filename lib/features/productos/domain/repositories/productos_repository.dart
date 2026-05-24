import '../../domain/entities/producto_entity.dart';

abstract class ProductosRepository {
  Future<List<ProductoTopEntity>> getProductosTop();
  Future<List<StockItemEntity>> getStockCritico();
}

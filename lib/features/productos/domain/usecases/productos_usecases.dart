import '../../domain/entities/producto_entity.dart';
import '../../domain/repositories/productos_repository.dart';

class GetProductosTop {
  final ProductosRepository repository;
  GetProductosTop(this.repository);
  Future<List<ProductoTopEntity>> call() => repository.getProductosTop();
}

class GetStockCritico {
  final ProductosRepository repository;
  GetStockCritico(this.repository);
  Future<List<StockItemEntity>> call() => repository.getStockCritico();
}

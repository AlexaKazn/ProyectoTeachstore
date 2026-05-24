import '../../domain/entities/venta_mensual_entity.dart';
import '../../domain/repositories/ventas_repository.dart';
import '../datasources/ventas_remote_datasource.dart';

class VentasRepositoryImpl implements VentasRepository {
  final VentasDataSource dataSource;
  VentasRepositoryImpl(this.dataSource);

  @override
  Future<List<VentaMensualEntity>> getVentasPorMes() => dataSource.getVentasPorMes();
}

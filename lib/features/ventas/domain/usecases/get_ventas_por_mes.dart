import '../../domain/entities/venta_mensual_entity.dart';
import '../../domain/repositories/ventas_repository.dart';

class GetVentasPorMes {
  final VentasRepository repository;
  GetVentasPorMes(this.repository);
  Future<List<VentaMensualEntity>> call() => repository.getVentasPorMes();
}

import '../../domain/entities/venta_mensual_entity.dart';

abstract class VentasRepository {
  Future<List<VentaMensualEntity>> getVentasPorMes();
}

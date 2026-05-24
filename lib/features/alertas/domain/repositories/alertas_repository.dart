import '../../domain/entities/alerta_entity.dart';

abstract class AlertasRepository {
  Future<List<AlertaEntity>> getAlertas();
}

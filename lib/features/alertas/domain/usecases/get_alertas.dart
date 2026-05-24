import '../../domain/entities/alerta_entity.dart';
import '../../domain/repositories/alertas_repository.dart';

class GetAlertas {
  final AlertasRepository repository;
  GetAlertas(this.repository);
  Future<List<AlertaEntity>> call() => repository.getAlertas();
}

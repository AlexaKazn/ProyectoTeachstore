import '../../domain/entities/alerta_entity.dart';
import '../../domain/repositories/alertas_repository.dart';
import '../datasources/alertas_remote_datasource.dart';

class AlertasRepositoryImpl implements AlertasRepository {
  final AlertasDataSource dataSource;
  AlertasRepositoryImpl(this.dataSource);

  @override
  Future<List<AlertaEntity>> getAlertas() => dataSource.getAlertas();
}

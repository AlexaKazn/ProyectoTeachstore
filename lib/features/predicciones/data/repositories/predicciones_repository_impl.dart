import '../../domain/entities/prediccion_entity.dart';
import '../../domain/repositories/predicciones_repository.dart';
import '../datasources/predicciones_remote_datasource.dart';

class PrediccionesRepositoryImpl implements PrediccionesRepository {
  final PrediccionesDataSource dataSource;
  PrediccionesRepositoryImpl(this.dataSource);

  @override
  Future<List<PrediccionEntity>> getPredicciones() => dataSource.getPredicciones();

  @override
  Future<List<RecomendacionEntity>> getRecomendaciones() => dataSource.getRecomendaciones();
}

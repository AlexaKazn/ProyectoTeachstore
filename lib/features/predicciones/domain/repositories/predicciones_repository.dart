import '../../domain/entities/prediccion_entity.dart';

abstract class PrediccionesRepository {
  Future<List<PrediccionEntity>> getPredicciones();
  Future<List<RecomendacionEntity>> getRecomendaciones();
}

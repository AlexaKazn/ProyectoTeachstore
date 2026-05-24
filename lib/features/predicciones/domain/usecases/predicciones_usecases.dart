import '../../domain/entities/prediccion_entity.dart';
import '../../domain/repositories/predicciones_repository.dart';

class GetPredicciones {
  final PrediccionesRepository repository;
  GetPredicciones(this.repository);
  Future<List<PrediccionEntity>> call() => repository.getPredicciones();
}

class GetRecomendaciones {
  final PrediccionesRepository repository;
  GetRecomendaciones(this.repository);
  Future<List<RecomendacionEntity>> call() => repository.getRecomendaciones();
}

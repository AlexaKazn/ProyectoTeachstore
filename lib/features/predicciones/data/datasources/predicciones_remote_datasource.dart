import '../../../../core/network/api_client.dart';
import '../../domain/entities/prediccion_entity.dart';

abstract class PrediccionesDataSource {
  Future<List<PrediccionEntity>> getPredicciones();
  Future<List<RecomendacionEntity>> getRecomendaciones();
}

class PrediccionesRemoteDataSource implements PrediccionesDataSource {
  final ApiClient apiClient;
  PrediccionesRemoteDataSource(this.apiClient);

  @override
  Future<List<PrediccionEntity>> getPredicciones() async {
    final res = await apiClient.dio.get('/predicciones');
    final data = res.data as Map<String, dynamic>;
    return (data['predicciones'] as List? ?? [])
        .map((e) => PrediccionEntity(
              anio: e['anio'] ?? 0,
              mes: e['mes'] ?? 0,
              nombreMes: e['nombre_mes'] ?? '',
              ventasPredichas: (e['ventas_predichas'] ?? 0).toDouble(),
              unidadesPredichas: e['unidades_predichas'] ?? 0,
              tasaCrecimiento: (e['tasa_crecimiento'] ?? 0).toDouble(),
              tendencia: e['tendencia'] ?? '',
              modelo: e['modelo'] ?? '',
            ))
        .toList();
  }

  @override
  Future<List<RecomendacionEntity>> getRecomendaciones() async {
    final res = await apiClient.dio.get('/patrones/recomendaciones');
    final data = res.data;
    // La API puede devolver lista directa o wrapper
    final List raw = data is List ? data : (data['recomendaciones'] as List? ?? []);
    return raw
        .map((e) => RecomendacionEntity(
              tipo: e['tipo'] ?? e['category'] ?? 'INFO',
              descripcion: e['descripcion'] ?? e['description'] ?? e.toString(),
              producto: e['producto'],
              accion: e['accion'] ?? e['action'],
            ))
        .toList();
  }
}

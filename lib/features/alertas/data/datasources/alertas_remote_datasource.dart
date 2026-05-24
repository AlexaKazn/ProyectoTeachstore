import '../../../../core/network/api_client.dart';
import '../../domain/entities/alerta_entity.dart';

abstract class AlertasDataSource {
  Future<List<AlertaEntity>> getAlertas();
}

class AlertasRemoteDataSource implements AlertasDataSource {
  final ApiClient apiClient;
  AlertasRemoteDataSource(this.apiClient);

  @override
  Future<List<AlertaEntity>> getAlertas() async {
    final res = await apiClient.dio.get('/alertas');
    final data = res.data as Map<String, dynamic>;
    return (data['alertas'] as List? ?? [])
        .map((e) => AlertaEntity(
              producto: e['producto'] ?? '',
              sucursal: e['sucursal'] ?? '',
              stock: e['stock'] ?? 0,
              tipoAlerta: e['tipo_alerta'] ?? '',
              fechaAlerta: e['fecha_alerta'] ?? '',
              nivelUrgencia: e['nivel_urgencia'] ?? 'BAJO',
            ))
        .toList();
  }
}

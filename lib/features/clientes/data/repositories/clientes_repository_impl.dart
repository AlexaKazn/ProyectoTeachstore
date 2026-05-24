import '../../../../core/network/api_client.dart';
import '../../domain/entities/cliente_entity.dart';
import '../../domain/repositories/clientes_repository.dart';
import '../models/cliente_model.dart';

class ClientesRepositoryImpl implements ClientesRepository {
  final ApiClient apiClient;

  ClientesRepositoryImpl(this.apiClient);

  @override
  Future<List<ClienteEntity>> getClientesVip() async {
    final response = await apiClient.dio.get('/clientes/vip');
    final List<dynamic> data = response.data['clientes_vip'] ?? [];
    return data.map((json) => ClienteModel.fromJson(json)).toList();
  }
}

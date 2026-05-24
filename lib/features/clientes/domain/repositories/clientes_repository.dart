import '../entities/cliente_entity.dart';

abstract class ClientesRepository {
  Future<List<ClienteEntity>> getClientesVip();
}

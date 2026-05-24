import '../entities/cliente_entity.dart';
import '../repositories/clientes_repository.dart';

class GetClientesVipUseCase {
  final ClientesRepository repository;

  GetClientesVipUseCase(this.repository);

  Future<List<ClienteEntity>> call() {
    return repository.getClientesVip();
  }
}

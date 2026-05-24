import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cliente_entity.dart';
import '../../domain/usecases/get_clientes_vip_usecase.dart';

part 'clientes_event.dart';
part 'clientes_state.dart';

class ClientesBloc extends Bloc<ClientesEvent, ClientesState> {
  final GetClientesVipUseCase getClientesVipUseCase;

  ClientesBloc({required this.getClientesVipUseCase}) : super(ClientesInitial()) {
    on<LoadClientesEvent>((event, emit) async {
      emit(ClientesLoading());
      try {
        final clientes = await getClientesVipUseCase();
        emit(ClientesLoaded(clientes));
      } catch (e) {
        emit(ClientesError(e.toString()));
      }
    });
  }
}

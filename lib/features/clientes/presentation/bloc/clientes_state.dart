part of 'clientes_bloc.dart';

abstract class ClientesState extends Equatable {
  const ClientesState();

  @override
  List<Object?> get props => [];
}

class ClientesInitial extends ClientesState {}

class ClientesLoading extends ClientesState {}

class ClientesLoaded extends ClientesState {
  final List<ClienteEntity> clientes;

  const ClientesLoaded(this.clientes);

  @override
  List<Object?> get props => [clientes];
}

class ClientesError extends ClientesState {
  final String message;

  const ClientesError(this.message);

  @override
  List<Object?> get props => [message];
}

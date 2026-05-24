part of 'clientes_bloc.dart';

abstract class ClientesEvent extends Equatable {
  const ClientesEvent();

  @override
  List<Object?> get props => [];
}

class LoadClientesEvent extends ClientesEvent {}

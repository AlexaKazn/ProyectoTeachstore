import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/venta_mensual_entity.dart';
import '../../domain/usecases/get_ventas_por_mes.dart';

abstract class VentasEvent extends Equatable {
  @override List<Object> get props => [];
}
class LoadVentasEvent extends VentasEvent {}

abstract class VentasState extends Equatable {
  @override List<Object?> get props => [];
}
class VentasInitial extends VentasState {}
class VentasLoading extends VentasState {}
class VentasLoaded extends VentasState {
  final List<VentaMensualEntity> ventas;
  VentasLoaded(this.ventas);
  @override List<Object?> get props => [ventas];
}
class VentasError extends VentasState {
  final String message;
  VentasError(this.message);
  @override List<Object?> get props => [message];
}

class VentasBloc extends Bloc<VentasEvent, VentasState> {
  final GetVentasPorMes getVentasPorMes;
  VentasBloc(this.getVentasPorMes) : super(VentasInitial()) {
    on<LoadVentasEvent>(_onLoad);
  }
  Future<void> _onLoad(LoadVentasEvent event, Emitter<VentasState> emit) async {
    emit(VentasLoading());
    try {
      final ventas = await getVentasPorMes();
      emit(VentasLoaded(ventas));
    } catch (e) {
      emit(VentasError(e.toString()));
    }
  }
}

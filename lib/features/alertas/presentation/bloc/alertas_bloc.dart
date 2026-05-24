import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/alerta_entity.dart';
import '../../domain/usecases/get_alertas.dart';

abstract class AlertasEvent extends Equatable {
  @override List<Object> get props => [];
}
class LoadAlertasEvent extends AlertasEvent {}

abstract class AlertasState extends Equatable {
  @override List<Object?> get props => [];
}
class AlertasInitial extends AlertasState {}
class AlertasLoading extends AlertasState {}
class AlertasLoaded extends AlertasState {
  final List<AlertaEntity> alertas;
  AlertasLoaded(this.alertas);
  @override List<Object?> get props => [alertas];
}
class AlertasError extends AlertasState {
  final String message;
  AlertasError(this.message);
  @override List<Object?> get props => [message];
}

class AlertasBloc extends Bloc<AlertasEvent, AlertasState> {
  final GetAlertas getAlertas;
  AlertasBloc(this.getAlertas) : super(AlertasInitial()) {
    on<LoadAlertasEvent>(_onLoad);
  }
  Future<void> _onLoad(LoadAlertasEvent event, Emitter<AlertasState> emit) async {
    emit(AlertasLoading());
    try {
      final alertas = await getAlertas();
      emit(AlertasLoaded(alertas));
    } catch (e) {
      emit(AlertasError(e.toString()));
    }
  }
}

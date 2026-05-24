import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/prediccion_entity.dart';
import '../../domain/usecases/predicciones_usecases.dart';

abstract class PrediccionesEvent extends Equatable {
  @override List<Object> get props => [];
}
class LoadPrediccionesEvent extends PrediccionesEvent {}

abstract class PrediccionesState extends Equatable {
  @override List<Object?> get props => [];
}
class PrediccionesInitial extends PrediccionesState {}
class PrediccionesLoading extends PrediccionesState {}
class PrediccionesLoaded extends PrediccionesState {
  final List<PrediccionEntity> predicciones;
  final List<RecomendacionEntity> recomendaciones;
  PrediccionesLoaded({required this.predicciones, required this.recomendaciones});
  @override List<Object?> get props => [predicciones, recomendaciones];
}
class PrediccionesError extends PrediccionesState {
  final String message;
  PrediccionesError(this.message);
  @override List<Object?> get props => [message];
}

class PrediccionesBloc extends Bloc<PrediccionesEvent, PrediccionesState> {
  final GetPredicciones getPredicciones;
  final GetRecomendaciones getRecomendaciones;

  PrediccionesBloc({required this.getPredicciones, required this.getRecomendaciones})
      : super(PrediccionesInitial()) {
    on<LoadPrediccionesEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadPrediccionesEvent event, Emitter<PrediccionesState> emit) async {
    emit(PrediccionesLoading());
    try {
      final pred = await getPredicciones();
      List<RecomendacionEntity> recs = [];
      try { recs = await getRecomendaciones(); } catch (_) {}
      emit(PrediccionesLoaded(predicciones: pred, recomendaciones: recs));
    } catch (e) {
      emit(PrediccionesError(e.toString()));
    }
  }
}

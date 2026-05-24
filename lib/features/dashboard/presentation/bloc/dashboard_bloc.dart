import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/usecases/get_dashboard_summary.dart';

// Events
abstract class DashboardEvent extends Equatable {
  @override List<Object> get props => [];
}
class LoadDashboardEvent extends DashboardEvent {}

// States
abstract class DashboardState extends Equatable {
  @override List<Object?> get props => [];
}
class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final DashboardSummaryEntity summary;
  DashboardLoaded(this.summary);
  @override List<Object?> get props => [summary];
}
class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
  @override List<Object?> get props => [message];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummary getDashboardSummary;

  DashboardBloc(this.getDashboardSummary) : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoad);
  }

  Future<void> _onLoad(
      LoadDashboardEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final summary = await getDashboardSummary();
      emit(DashboardLoaded(summary));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
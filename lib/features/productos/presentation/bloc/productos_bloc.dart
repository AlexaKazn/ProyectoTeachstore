import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/producto_entity.dart';
import '../../domain/usecases/productos_usecases.dart';

abstract class ProductosEvent extends Equatable {
  @override List<Object> get props => [];
}
class LoadProductosEvent extends ProductosEvent {}
class LoadStockCriticoEvent extends ProductosEvent {}

abstract class ProductosState extends Equatable {
  @override List<Object?> get props => [];
}
class ProductosInitial extends ProductosState {}
class ProductosLoading extends ProductosState {}
class ProductosLoaded extends ProductosState {
  final List<ProductoTopEntity> top;
  final List<StockItemEntity> stock;
  ProductosLoaded({required this.top, required this.stock});
  @override List<Object?> get props => [top, stock];
}
class ProductosError extends ProductosState {
  final String message;
  ProductosError(this.message);
  @override List<Object?> get props => [message];
}

class ProductosBloc extends Bloc<ProductosEvent, ProductosState> {
  final GetProductosTop getProductosTop;
  final GetStockCritico getStockCritico;

  ProductosBloc({required this.getProductosTop, required this.getStockCritico})
      : super(ProductosInitial()) {
    on<LoadProductosEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadProductosEvent event, Emitter<ProductosState> emit) async {
    emit(ProductosLoading());
    try {
      final results = await Future.wait([
        getProductosTop(),
        getStockCritico(),
      ]);
      emit(ProductosLoaded(
        top: results[0] as List<ProductoTopEntity>,
        stock: results[1] as List<StockItemEntity>,
      ));
    } catch (e) {
      emit(ProductosError(e.toString()));
    }
  }
}

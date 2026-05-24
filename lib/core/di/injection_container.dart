import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../constants/app_constants.dart';

// AUTH
import '../../features/auth/data/datasources/auth_mock_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// DASHBOARD
import '../../features/dashboard/data/datasources/dashboard_mock_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_summary.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

// CLIENTES VIP
import '../../features/clientes/data/repositories/clientes_repository_impl.dart';
import '../../features/clientes/domain/repositories/clientes_repository.dart';
import '../../features/clientes/domain/usecases/get_clientes_vip_usecase.dart';
import '../../features/clientes/presentation/bloc/clientes_bloc.dart';

import '../navigation/navigation_cubit.dart';

// PRODUCTOS
import '../../features/productos/data/datasources/productos_remote_datasource.dart';
import '../../features/productos/data/repositories/productos_repository_impl.dart';
import '../../features/productos/domain/repositories/productos_repository.dart';
import '../../features/productos/domain/usecases/productos_usecases.dart';
import '../../features/productos/presentation/bloc/productos_bloc.dart';

// PREDICCIONES
import '../../features/predicciones/data/datasources/predicciones_remote_datasource.dart';
import '../../features/predicciones/data/repositories/predicciones_repository_impl.dart';
import '../../features/predicciones/domain/repositories/predicciones_repository.dart';
import '../../features/predicciones/domain/usecases/predicciones_usecases.dart';
import '../../features/predicciones/presentation/bloc/predicciones_bloc.dart';

// ALERTAS
import '../../features/alertas/data/datasources/alertas_remote_datasource.dart';
import '../../features/alertas/data/repositories/alertas_repository_impl.dart';
import '../../features/alertas/domain/repositories/alertas_repository.dart';
import '../../features/alertas/domain/usecases/get_alertas.dart';
import '../../features/alertas/presentation/bloc/alertas_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── CORE ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ApiClient());

  // ── AUTH ──────────────────────────────────────────────────────────────────
  if (AppConstants.useMockData) {
    sl.registerLazySingleton<AuthDataSource>(() => AuthMockDataSource());
  } else {
    sl.registerLazySingleton<AuthDataSource>(
      () => AuthRemoteDataSource(sl<ApiClient>()),
    );
  }
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthDataSource>()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => AuthBloc(sl<LoginUseCase>()));

  // ── DASHBOARD ─────────────────────────────────────────────────────────────
  if (AppConstants.useMockData) {
    sl.registerLazySingleton<DashboardDataSource>(() => DashboardMockDataSource());
  } else {
    sl.registerLazySingleton<DashboardDataSource>(
      () => DashboardRemoteDataSource(sl<ApiClient>()),
    );
  }
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl<DashboardDataSource>()),
  );
  sl.registerLazySingleton(() => GetDashboardSummary(sl<DashboardRepository>()));
  sl.registerFactory(() => DashboardBloc(sl<GetDashboardSummary>()));

  // ── NAVIGATION ────────────────────────────────────────────────────────────
  sl.registerFactory(() => NavigationCubit());

  // ── CLIENTES VIP ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<ClientesRepository>(
    () => ClientesRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton(() => GetClientesVipUseCase(sl<ClientesRepository>()));
  sl.registerFactory(() => ClientesBloc(getClientesVipUseCase: sl<GetClientesVipUseCase>()));

  // ── PRODUCTOS ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProductosDataSource>(
    () => ProductosRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ProductosRepository>(
    () => ProductosRepositoryImpl(sl<ProductosDataSource>()),
  );
  sl.registerLazySingleton(() => GetProductosTop(sl<ProductosRepository>()));
  sl.registerLazySingleton(() => GetStockCritico(sl<ProductosRepository>()));
  sl.registerFactory(() => ProductosBloc(
    getProductosTop: sl<GetProductosTop>(),
    getStockCritico: sl<GetStockCritico>(),
  ));

  // ── PREDICCIONES ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<PrediccionesDataSource>(
    () => PrediccionesRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<PrediccionesRepository>(
    () => PrediccionesRepositoryImpl(sl<PrediccionesDataSource>()),
  );
  sl.registerLazySingleton(() => GetPredicciones(sl<PrediccionesRepository>()));
  sl.registerLazySingleton(() => GetRecomendaciones(sl<PrediccionesRepository>()));
  sl.registerFactory(() => PrediccionesBloc(
    getPredicciones: sl<GetPredicciones>(),
    getRecomendaciones: sl<GetRecomendaciones>(),
  ));

  // ── ALERTAS ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AlertasDataSource>(
    () => AlertasRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<AlertasRepository>(
    () => AlertasRepositoryImpl(sl<AlertasDataSource>()),
  );
  sl.registerLazySingleton(() => GetAlertas(sl<AlertasRepository>()));
  sl.registerFactory(() => AlertasBloc(sl<GetAlertas>()));
}
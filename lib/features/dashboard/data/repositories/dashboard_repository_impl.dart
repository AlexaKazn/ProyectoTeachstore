import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_mock_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource dataSource;
  DashboardRepositoryImpl(this.dataSource);

  @override
  Future<DashboardSummaryEntity> getSummary() async {
    return await dataSource.getSummary();
  }
}
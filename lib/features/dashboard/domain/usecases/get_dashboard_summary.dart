import '../entities/dashboard_summary_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummary {
  final DashboardRepository repository;
  GetDashboardSummary(this.repository);

  Future<DashboardSummaryEntity> call() => repository.getSummary();
}
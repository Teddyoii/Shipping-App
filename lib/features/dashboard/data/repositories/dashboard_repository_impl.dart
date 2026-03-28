import '../../../../domain/entities/dashboard_stats.dart';
import '../datasources/dashboard_datasource.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getDashboardStats();
}

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource dashboardDataSource;

  DashboardRepositoryImpl({required this.dashboardDataSource});

  @override
  Future<DashboardStats> getDashboardStats() async {
    try {
      return await dashboardDataSource.fetchDashboardStats();
    } catch (e) {
      throw Exception('Failed to fetch dashboard statistics: $e');
    }
  }
}
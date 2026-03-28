// lib/features/dashboard/presentation/bloc/dashboard_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

/// BLoC for dashboard business logic
/// Handles loading and refreshing dashboard statistics
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository dashboardRepository;

  DashboardBloc({required this.dashboardRepository}) : super(DashboardInitial()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  /// Load dashboard statistics
  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final stats = await dashboardRepository.getDashboardStats();
      emit(DashboardLoaded(stats: stats));
    } catch (e) {
      print('Error loading dashboard stats: $e');
      emit(DashboardError(message: 'Failed to load dashboard data'));
    }
  }

  /// Refresh dashboard data
  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final stats = await dashboardRepository.getDashboardStats();
      emit(DashboardLoaded(stats: stats));
    } catch (e) {
      print('Error refreshing dashboard: $e');
      emit(DashboardError(message: 'Failed to refresh data'));
    }
  }
}
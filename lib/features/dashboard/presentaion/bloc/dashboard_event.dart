// lib/features/dashboard/presentation/bloc/dashboard_event.dart
import 'package:equatable/equatable.dart';

/// Base class for all dashboard events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

/// Event to load dashboard statistics
class LoadDashboardStats extends DashboardEvent {}

/// Event to refresh dashboard data
class RefreshDashboard extends DashboardEvent {}
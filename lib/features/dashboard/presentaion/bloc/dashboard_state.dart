// lib/features/dashboard/presentation/bloc/dashboard_state.dart
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/dashboard_stats.dart';

/// Base class for all dashboard states
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

/// Initial state
class DashboardInitial extends DashboardState {}

/// Loading state
class DashboardLoading extends DashboardState {}

/// Loaded state with statistics
class DashboardLoaded extends DashboardState {
  final DashboardStats stats;

  const DashboardLoaded({required this.stats});

  @override
  List<Object> get props => [stats];
}

/// Error state
class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}
// lib/domain/entities/dashboard_stats.dart
import 'package:equatable/equatable.dart';
import 'order.dart';

/// Dashboard statistics entity
/// Contains aggregated data for the dashboard view
class DashboardStats extends Equatable {
  final int totalOrders;
  final int pendingOrders;
  final int deliveredOrders;
  final double totalRevenue;
  final double monthlyRevenue;
  final Map<OrderStatus, int> statusBreakdown;

  const DashboardStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.deliveredOrders,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.statusBreakdown,
  });

  @override
  List<Object> get props => [
    totalOrders,
    pendingOrders,
    deliveredOrders,
    totalRevenue,
    monthlyRevenue,
    statusBreakdown,
  ];

  /// Create an empty stats object
  factory DashboardStats.empty() {
    return const DashboardStats(
      totalOrders: 0,
      pendingOrders: 0,
      deliveredOrders: 0,
      totalRevenue: 0,
      monthlyRevenue: 0,
      statusBreakdown: {},
    );
  }
}
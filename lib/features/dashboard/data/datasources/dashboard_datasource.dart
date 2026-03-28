import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/entities/dashboard_stats.dart';
import '../../../../domain/entities/order.dart';

abstract class DashboardDataSource {
  Future<DashboardStats> fetchDashboardStats();
}

class DashboardDataSourceImpl implements DashboardDataSource {
  final FirebaseFirestore firestore;

  DashboardDataSourceImpl({required this.firestore});

  @override
  Future<DashboardStats> fetchDashboardStats() async {
    try {
      // Fetch all orders from Firestore
      final ordersSnapshot = await firestore.collection('orders').get();
      final orders = ordersSnapshot.docs;

      int totalOrders = orders.length;
      int pendingOrders = 0;
      int deliveredOrders = 0;
      double totalRevenue = 0;
      double monthlyRevenue = 0;
      Map<OrderStatus, int> statusBreakdown = {};

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);

      // Process each order
      for (var doc in orders) {
        final data = doc.data();
        final status = _parseOrderStatus(data['status']);
        final amount = (data['totalAmount'] ?? 0).toDouble();
        final orderDate = (data['orderDate'] as Timestamp).toDate();

        // Count by status
        statusBreakdown[status] = (statusBreakdown[status] ?? 0) + 1;

        if (status == OrderStatus.pending) pendingOrders++;
        if (status == OrderStatus.delivered) deliveredOrders++;

        // Calculate revenue
        totalRevenue += amount;
        if (orderDate.isAfter(currentMonth)) {
          monthlyRevenue += amount;
        }
      }

      return DashboardStats(
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        deliveredOrders: deliveredOrders,
        totalRevenue: totalRevenue,
        monthlyRevenue: monthlyRevenue,
        statusBreakdown: statusBreakdown,
      );
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      throw Exception('Failed to fetch dashboard stats');
    }
  }

  /// Parse string to OrderStatus enum
  OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'in_transit':
        return OrderStatus.inTransit;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
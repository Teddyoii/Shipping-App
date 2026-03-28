// lib/features/orders/data/repositories/orders_repository_impl.dart
import '../../../../domain/entities/order.dart';
import '../datasources/orders_datasource.dart';

/// Abstract repository interface for orders
abstract class OrdersRepository {
  Future<List<Order>> getAllOrders();
  Future<List<Order>> getOrdersByStatus(OrderStatus status);
  Future<void> addRemark({required String orderId, required String remark});
  Future<String> exportToExcel(List<Order> orders);
}

/// Implementation of orders repository
/// Manages data flow between domain and data layers
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDataSource ordersDataSource;

  OrdersRepositoryImpl({required this.ordersDataSource});

  @override
  Future<List<Order>> getAllOrders() async {
    try {
      return await ordersDataSource.fetchAllOrders();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    try {
      return await ordersDataSource.fetchOrdersByStatus(status);
    } catch (e) {
      throw Exception('Failed to fetch orders by status: $e');
    }
  }

  @override
  Future<void> addRemark({
    required String orderId,
    required String remark,
  }) async {
    try {
      await ordersDataSource.addRemarkToOrder(
        orderId: orderId,
        remark: remark,
      );
    } catch (e) {
      throw Exception('Failed to add remark: $e');
    }
  }

  @override
  Future<String> exportToExcel(List<Order> orders) async {
    try {
      return await ordersDataSource.exportOrdersToExcel(orders);
    } catch (e) {
      throw Exception('Failed to export orders: $e');
    }
  }
}
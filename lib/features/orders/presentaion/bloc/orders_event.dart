import 'package:equatable/equatable.dart';
import '../../../../domain/entities/order.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

/// Load all orders
class LoadOrders extends OrdersEvent {}

/// Filter orders by status
class FilterOrdersByStatus extends OrdersEvent {
  final OrderStatus? status;

  const FilterOrdersByStatus({this.status});

  @override
  List<Object?> get props => [status];
}

/// Add remark to order
class AddOrderRemark extends OrdersEvent {
  final String orderId;
  final String remark;

  const AddOrderRemark({required this.orderId, required this.remark});

  @override
  List<Object> get props => [orderId, remark];
}

/// Export orders to Excel
class ExportOrdersToExcel extends OrdersEvent {
  final List<Order> orders;

  const ExportOrdersToExcel({required this.orders});

  @override
  List<Object> get props => [orders];
}
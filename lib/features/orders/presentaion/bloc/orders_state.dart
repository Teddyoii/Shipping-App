import 'package:equatable/equatable.dart';

import '../../../../domain/entities/order.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;
  final OrderStatus? selectedStatus;

  const OrdersLoaded({required this.orders, this.selectedStatus});

  @override
  List<Object?> get props => [orders, selectedStatus];

  /// Get filtered orders based on selected status
  List<Order> get filteredOrders {
    if (selectedStatus == null) return orders;
    return orders.where((order) => order.status == selectedStatus).toList();
  }
}

class OrderRemarkAdded extends OrdersState {
  final String orderId;

  const OrderRemarkAdded({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class OrdersExported extends OrdersState {
  final String filePath;

  const OrdersExported({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError({required this.message});

  @override
  List<Object> get props => [message];
}
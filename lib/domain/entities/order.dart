// lib/domain/entities/order.dart
import 'package:equatable/equatable.dart';

/// Order entity representing a customer order
class Order extends Equatable {
  final String id;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final OrderStatus status;
  final double totalAmount;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final List<OrderItem> items;
  final List<String> remarks;
  final LocationData? currentLocation;

  const Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    this.deliveryDate,
    required this.items,
    required this.remarks,
    this.currentLocation,
  });

  @override
  List<Object?> get props => [
    id,
    customerName,
    customerPhone,
    deliveryAddress,
    status,
    totalAmount,
    orderDate,
    deliveryDate,
    items,
    remarks,
    currentLocation,
  ];

  /// Create a copy of Order with updated fields
  Order copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    OrderStatus? status,
    double? totalAmount,
    DateTime? orderDate,
    DateTime? deliveryDate,
    List<OrderItem>? items,
    List<String>? remarks,
    LocationData? currentLocation,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      items: items ?? this.items,
      remarks: remarks ?? this.remarks,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}

/// Enum for order status
enum OrderStatus {
  pending,
  processing,
  shipped,
  inTransit,
  outForDelivery,
  delivered,
  cancelled,
}

/// Order item entity
class OrderItem extends Equatable {
  final String productName;
  final int quantity;
  final double price;

  const OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object> get props => [productName, quantity, price];
}

/// Location data entity
class LocationData extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  List<Object> get props => [latitude, longitude, timestamp];
}
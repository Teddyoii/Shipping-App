// lib/features/orders/presentation/widgets/order_filter_chips.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/order.dart';

/// Horizontal scrollable filter chips for order status
class OrderFilterChips extends StatelessWidget {
  final OrderStatus? selectedStatus;
  final Function(OrderStatus?) onStatusSelected;

  const OrderFilterChips({
    Key? key,
    required this.selectedStatus,
    required this.onStatusSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          // "All" filter chip
          _buildFilterChip(
            label: 'All',
            isSelected: selectedStatus == null,
            onTap: () => onStatusSelected(null),
          ),
          
          // Status filter chips
          ...OrderStatus.values.map(
            (status) => _buildFilterChip(
              label: _getStatusLabel(status),
              isSelected: selectedStatus == status,
              color: _getStatusColor(status),
              onTap: () => onStatusSelected(status),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual filter chip
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? const Color(0xFF2196F3);
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: chipColor.withOpacity(0.2),
        checkmarkColor: chipColor,
        labelStyle: TextStyle(
          color: isSelected ? chipColor : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? chipColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// Get color for order status
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.inTransit:
        return Colors.indigo;
      case OrderStatus.outForDelivery:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  /// Get display label for order status
  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
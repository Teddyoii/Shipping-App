// lib/features/orders/presentation/pages/order_details_page.dart
// MODIFIED VERSION - With in-app status update functionality

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shipping_app/features/tracking/presentaion/pages/order_tracking_page.dart';
import '../../../../domain/entities/order.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../../../../core/services/order_update_service.dart';

/// Detailed view of a single order with status update capability
class OrderDetailsPage extends StatefulWidget {
  final Order order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final _remarkController = TextEditingController();
  bool _isUpdating = false;

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.order.id.substring(0, 8).toUpperCase()}'),
        actions: [
          // Track order button
          if (widget.order.currentLocation != null)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingPage(order: widget.order),
                  ),
                );
              },
              tooltip: 'Track Order',
            ),
          
          // 🆕 UPDATE STATUS BUTTON - Works on FREE Firebase plan!
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showStatusUpdateDialog,
            tooltip: 'Update Status',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(20),
              color: _getStatusColor(widget.order.status).withOpacity(0.1),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(widget.order.status),
                    size: 60,
                    color: _getStatusColor(widget.order.status),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getStatusLabel(widget.order.status),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(widget.order.status),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 🆕 Quick status update hint
                  Text(
                    'Tap edit icon to update status',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            // Customer Information
            _buildSection(
              title: 'Customer Information',
              child: Column(
                children: [
                  _buildInfoRow(Icons.person, 'Name', widget.order.customerName),
                  _buildInfoRow(Icons.phone, 'Phone', widget.order.customerPhone),
                  _buildInfoRow(Icons.location_on, 'Address', widget.order.deliveryAddress),
                ],
              ),
            ),
            
            // Order Information
            _buildSection(
              title: 'Order Information',
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.shopping_cart,
                    'Order Date',
                    dateFormat.format(widget.order.orderDate),
                  ),
                  if (widget.order.deliveryDate != null)
                    _buildInfoRow(
                      Icons.local_shipping,
                      'Delivery Date',
                      dateFormat.format(widget.order.deliveryDate!),
                    ),
                  _buildInfoRow(
                    Icons.attach_money,
                    'Total Amount',
                    currencyFormat.format(widget.order.totalAmount),
                  ),
                ],
              ),
            ),
            
            // Order Items
            _buildSection(
              title: 'Order Items',
              child: Column(
                children: widget.order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Quantity: ${item.quantity} × ${currencyFormat.format(item.price)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormat.format(item.price * item.quantity),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Remarks Section
            _buildSection(
              title: 'Remarks',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.order.remarks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'No remarks added yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...widget.order.remarks.map((remark) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.comment,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                remark,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddRemarkDialog,
                    icon: const Icon(Icons.add_comment),
                    label: const Text('Add Remark'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🆕 Show status update dialog
  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new status for this order:'),
            const SizedBox(height: 16),
            _buildStatusOption('pending', 'Pending', Colors.orange),
            _buildStatusOption('processing', 'Processing', Colors.blue),
            _buildStatusOption('shipped', 'Shipped', Colors.purple),
            _buildStatusOption('in_transit', 'In Transit', Colors.indigo),
            _buildStatusOption('out_for_delivery', 'Out for Delivery', Colors.teal),
            _buildStatusOption('delivered', 'Delivered', Colors.green),
            _buildStatusOption('cancelled', 'Cancelled', Colors.red),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Build status option button
  Widget _buildStatusOption(String status, String label, Color color) {
    final isCurrentStatus = _statusToString(widget.order.status) == status;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          isCurrentStatus ? Icons.check_circle : Icons.circle_outlined,
          color: color,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        tileColor: isCurrentStatus ? color.withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        enabled: !isCurrentStatus && !_isUpdating,
        onTap: () async {
          Navigator.pop(context);
          await _updateOrderStatus(status);
        },
      ),
    );
  }

  /// 🆕 Update order status using FREE Firebase
  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    try {
      // Use OrderUpdateService (works on FREE plan!)
      final success = await OrderUpdateService().updateOrderStatus(
        orderId: widget.order.id,
        newStatus: newStatus,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${_formatStatus(newStatus)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Go back to refresh the orders list
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update order status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _showAddRemarkDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Remark'),
        content: TextField(
          controller: _remarkController,
          decoration: const InputDecoration(
            hintText: 'Enter your remark',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _remarkController.clear();
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_remarkController.text.trim().isNotEmpty) {
                context.read<OrdersBloc>().add(
                      AddOrderRemark(
                        orderId: widget.order.id,
                        remark: _remarkController.text.trim(),
                      ),
                    );
                _remarkController.clear();
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.inTransit:
        return 'in_transit';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'in_transit':
        return 'In Transit';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

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

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_actions;
      case OrderStatus.processing:
        return Icons.settings;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.inTransit:
        return Icons.airport_shuttle;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

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
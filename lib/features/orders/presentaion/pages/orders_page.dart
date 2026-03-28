// lib/features/orders/presentation/pages/orders_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filter_chips.dart';
import 'order_details_page.dart';
import '../../../../domain/entities/order.dart';

/// Main orders page displaying all orders with filtering
class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    // Load orders when page opens
    context.read<OrdersBloc>().add(LoadOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          // Export button
          BlocBuilder<OrdersBloc, OrdersState>(
            builder: (context, state) {
              if (state is OrdersLoaded) {
                return IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    _exportOrders(context, state.filteredOrders);
                  },
                  tooltip: 'Export to Excel',
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocConsumer<OrdersBloc, OrdersState>(
        listener: (context, state) {
          // Handle state changes
          if (state is OrdersExported) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Orders exported to:\n${state.filePath}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          } else if (state is OrderRemarkAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Remark added successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is OrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrdersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OrdersBloc>().add(LoadOrders());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is OrdersLoaded) {
            final orders = state.filteredOrders;

            return Column(
              children: [
                // Filter chips
                OrderFilterChips(
                  selectedStatus: state.selectedStatus,
                  onStatusSelected: (status) {
                    context.read<OrdersBloc>().add(
                          FilterOrdersByStatus(status: status),
                        );
                  },
                ),
                
                // Orders list
                Expanded(
                  child: orders.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<OrdersBloc>().add(LoadOrders());
                            await Future.delayed(const Duration(seconds: 1));
                          },
                          child: ListView.builder(
                            itemCount: orders.length,
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return OrderCard(
                                order: order,
                                onTap: () {
                                  _navigateToOrderDetails(context, order);
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  /// Build empty state when no orders found
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to order details page
  void _navigateToOrderDetails(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsPage(order: order),
      ),
    ).then((_) {
      // Reload orders when coming back from details page
      context.read<OrdersBloc>().add(LoadOrders());
    });
  }

  /// Show export confirmation dialog
  void _exportOrders(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No orders to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Export Orders'),
        content: Text(
          'Export ${orders.length} order${orders.length > 1 ? 's' : ''} to Excel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OrdersBloc>().add(
                    ExportOrdersToExcel(orders: orders),
                  );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}
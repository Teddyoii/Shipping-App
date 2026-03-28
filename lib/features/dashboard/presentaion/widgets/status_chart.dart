// lib/features/dashboard/presentation/widgets/status_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../domain/entities/order.dart';

/// Pie chart widget showing order status breakdown
class StatusChart extends StatelessWidget {
  final Map<OrderStatus, int> statusBreakdown;

  const StatusChart({Key? key, required this.statusBreakdown}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (statusBreakdown.isEmpty) {
      return Card(
        child: Container(
          padding: const EdgeInsets.all(32.0),
          child: const Center(
            child: Text('No order data available'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Orders by Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _generateSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  /// Generate pie chart sections from status data
  List<PieChartSectionData> _generateSections() {
    final total = statusBreakdown.values.fold(0, (sum, count) => sum + count);
    
    return statusBreakdown.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      final color = _getStatusColor(entry.key);
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '$percentage%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  /// Build legend showing status labels and counts
  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: statusBreakdown.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getStatusColor(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${_getStatusLabel(entry.key)} (${entry.value})',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Get color for each order status
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
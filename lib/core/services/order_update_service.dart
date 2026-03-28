// lib/core/services/order_update_service.dart
// This replaces Cloud Functions - works on FREE Firebase plan!

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service to update order status directly in Firestore
/// No Cloud Functions needed - works on FREE Firebase plan!
class OrderUpdateService {
  static final OrderUpdateService _instance = OrderUpdateService._internal();
  factory OrderUpdateService() => _instance;
  OrderUpdateService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Update order status directly in Firestore
  /// This replaces the Cloud Function API call
  Future<bool> updateOrderStatus({
    required String orderId,
    required String newStatus,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Prepare update data
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add location if provided
      if (latitude != null && longitude != null) {
        updateData['currentLocation'] = {
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': FieldValue.serverTimestamp(),
        };
      }

      // Update order in Firestore
      await _firestore.collection('orders').doc(orderId).update(updateData);

      print('✅ Order $orderId status updated to $newStatus');
      return true;
    } catch (e) {
      print('❌ Error updating order status: $e');
      return false;
    }
  }

  /// Listen to order changes for a specific merchant
  /// Shows notifications when orders are updated
  void listenToOrderUpdates(String merchantId) {
    _firestore
        .collection('orders')
        .where('merchantId', isEqualTo: merchantId)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final order = change.doc.data();
          final orderId = change.doc.id;
          final status = order?['status'] ?? '';

          // Show local notification
          _showOrderUpdateNotification(orderId, status);
        }
      }
    });
  }

  /// Show notification when order is updated
  Future<void> _showOrderUpdateNotification(
    String orderId,
    String status,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'order_updates_channel',
      'Order Updates',
      channelDescription: 'Notifications for order status updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      orderId.hashCode,
      'Order Status Updated',
      'Order #${orderId.substring(0, 8).toUpperCase()} is now ${_formatStatus(status)}',
      details,
    );
  }

  /// Format status for display
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

  /// Batch update multiple orders (for admin use)
  Future<bool> batchUpdateOrders({
    required List<String> orderIds,
    required String newStatus,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final orderId in orderIds) {
        final docRef = _firestore.collection('orders').doc(orderId);
        batch.update(docRef, {
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('✅ Batch updated ${orderIds.length} orders to $newStatus');
      return true;
    } catch (e) {
      print('❌ Error batch updating orders: $e');
      return false;
    }
  }

  /// Update order location (for tracking)
  Future<bool> updateOrderLocation({
    required String orderId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'currentLocation': {
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Order location updated');
      return true;
    } catch (e) {
      print('❌ Error updating location: $e');
      return false;
    }
  }
}
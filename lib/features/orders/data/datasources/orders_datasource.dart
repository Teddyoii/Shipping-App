// lib/features/orders/data/datasources/orders_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:shipping_app/domain/entities/order.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'dart:io';


/// Abstract data source interface for orders
abstract class OrdersDataSource {
  Future<List<Order>> fetchAllOrders();
  Future<List<Order>> fetchOrdersByStatus(OrderStatus status);
  Future<void> addRemarkToOrder({required String orderId, required String remark});
  Future<String> exportOrdersToExcel(List<Order> orders);
}

/// Implementation of orders data source using Firebase
class OrdersDataSourceImpl implements OrdersDataSource {
  final FirebaseFirestore firestore;

  OrdersDataSourceImpl({required this.firestore});

  @override
  Future<List<Order>> fetchAllOrders() async {
    try {
      final snapshot = await firestore
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => _orderFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to fetch orders');
    }
  }

  @override
  Future<List<Order>> fetchOrdersByStatus(OrderStatus status) async {
    try {
      final snapshot = await firestore
          .collection('orders')
          .where('status', isEqualTo: _statusToString(status))
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => _orderFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching orders by status: $e');
      throw Exception('Failed to fetch orders by status');
    }
  }

  @override
  Future<void> addRemarkToOrder({
    required String orderId,
    required String remark,
  }) async {
    try {
      final doc = firestore.collection('orders').doc(orderId);
      
      await doc.update({
        'remarks': FieldValue.arrayUnion([
          {
            'text': remark,
            'timestamp': FieldValue.serverTimestamp(),
          }
        ]),
      });
    } catch (e) {
      print('Error adding remark: $e');
      throw Exception('Failed to add remark');
    }
  }

  @override
  Future<String> exportOrdersToExcel(List<Order> orders) async {
    try {
      // Create a new Excel workbook
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];

      // Set column headers
      sheet.getRangeByName('A1').setText('Order ID');
      sheet.getRangeByName('B1').setText('Customer Name');
      sheet.getRangeByName('C1').setText('Phone');
      sheet.getRangeByName('D1').setText('Address');
      sheet.getRangeByName('E1').setText('Status');
      sheet.getRangeByName('F1').setText('Amount');
      sheet.getRangeByName('G1').setText('Order Date');
      sheet.getRangeByName('H1').setText('Delivery Date');
      sheet.getRangeByName('I1').setText('Items');
      sheet.getRangeByName('J1').setText('Remarks');

      // Style headers
      final xlsio.Style headerStyle = workbook.styles.add('HeaderStyle');
      headerStyle.bold = true;
      headerStyle.backColor = '#2196F3';
      headerStyle.fontColor = '#FFFFFF';
      sheet.getRangeByName('A1:J1').cellStyle = headerStyle;

      // Add data rows
      for (int i = 0; i < orders.length; i++) {
        final order = orders[i];
        final row = i + 2;

        sheet.getRangeByName('A$row').setText(order.id);
        sheet.getRangeByName('B$row').setText(order.customerName);
        sheet.getRangeByName('C$row').setText(order.customerPhone);
        sheet.getRangeByName('D$row').setText(order.deliveryAddress);
        sheet.getRangeByName('E$row').setText(_statusToDisplayString(order.status));
        sheet.getRangeByName('F$row').setNumber(order.totalAmount);
        sheet.getRangeByName('G$row').setDateTime(order.orderDate);
        
        if (order.deliveryDate != null) {
          sheet.getRangeByName('H$row').setDateTime(order.deliveryDate!);
        }
        
        // Combine items into a single cell
        final itemsText = order.items
            .map((item) => '${item.productName} (${item.quantity}x \$${item.price})')
            .join(', ');
        sheet.getRangeByName('I$row').setText(itemsText);
        
        // Combine remarks into a single cell
        sheet.getRangeByName('J$row').setText(order.remarks.join('; '));
      }

      // Auto-fit columns for better readability
      sheet.autoFitColumn(1);
      sheet.autoFitColumn(2);
      sheet.autoFitColumn(3);
      sheet.autoFitColumn(4);
      sheet.autoFitColumn(5);

      // Save the file
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // Get directory to save the file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/orders_$timestamp.xlsx';
      
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      // Optional: Upload metadata to Firestore
      await _uploadExportMetadata(filePath, bytes.length);

      return filePath;
    } catch (e) {
      print('Error exporting to Excel: $e');
      throw Exception('Failed to export to Excel');
    }
  }

  /// Upload export metadata to Firestore (optional)
  Future<void> _uploadExportMetadata(String fileName, int fileSize) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await firestore.collection('exports').add({
        'fileName': 'orders_$timestamp.xlsx',
        'createdAt': FieldValue.serverTimestamp(),
        'size': fileSize,
      });
    } catch (e) {
      print('Failed to upload export metadata: $e');
      // Don't throw error - metadata upload is optional
    }
  }

/// Convert Firestore document to Order entity
Order _orderFromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  
  print('DEBUG: Processing order doc ID: ${doc.id}');
  
  try {
    return Order(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      deliveryAddress: data['deliveryAddress'] ?? '',
      status: _parseOrderStatus(data['status']),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      orderDate: _parseDateTime(data['orderDate']),
      deliveryDate: data['deliveryDate'] != null && data['deliveryDate'] != ''
          ? _parseDateTime(data['deliveryDate'])
          : null,
      items: (data['items'] as List?)
              ?.map((item) => OrderItem(
                    productName: item['productName'] ?? '',
                    // Handle both 'quantity' and 'quatity' (typo in Firestore)
                    quantity: item['quantity'] ?? item['quatity'] ?? 0,
                    price: (item['price'] ?? 0).toDouble(),
                  ))
              .toList() ??
          [],
      remarks: (data['remarks'] as List?)
              ?.map((remark) {
                // Handle if remark is a map with 'text' field or just a string
                if (remark is Map) {
                  return remark['text'] as String? ?? '';
                }
                return remark.toString();
              })
              .where((remark) => remark.isNotEmpty)
              .toList() ??
          [],
      currentLocation: data['currentLocation'] != null
          ? LocationData(
              latitude: (data['currentLocation']['latitude'] ?? 0).toDouble(),
              longitude: (data['currentLocation']['longitude'] ?? 0).toDouble(),
              timestamp: _parseDateTime(data['currentLocation']['timestamp']),
            )
          : null,
    );
  } catch (e, stackTrace) {
    print('ERROR creating Order object: $e');
    print('Stack trace: $stackTrace');
    print('Problematic data: $data');
    rethrow;
  }
}
/// Parse DateTime from various Firestore formats
DateTime _parseDateTime(dynamic value) {
  print('DEBUG: Parsing DateTime - Type: ${value.runtimeType}, Value: $value');
  
  if (value == null) {
    print('DEBUG: Value is null, returning current time');
    return DateTime.now();
  }
  
  if (value is Timestamp) {
    print('DEBUG: Value is Timestamp');
    return value.toDate();
  }
  
  if (value is String) {
    print('DEBUG: Value is String: $value');
    try {
      return DateTime.parse(value);
    } catch (e) {
      print('Error parsing date string: $value, Error: $e');
      return DateTime.now();
    }
  }
  
  if (value is int) {
    print('DEBUG: Value is int (milliseconds): $value');
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  
  print('DEBUG: Unknown date format: ${value.runtimeType}');
  return DateTime.now();
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

  /// Convert OrderStatus enum to Firestore string
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

  /// Convert OrderStatus enum to display string
  String _statusToDisplayString(OrderStatus status) {
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
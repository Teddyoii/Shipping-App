// // lib/core/services/order_status_api_service.dart
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// /// Service to handle order status updates via REST API
// /// This can be called from Postman or other API testing tools
// class OrderStatusApiService {
//   // TODO: Replace with your actual Firebase Cloud Function URL
//   static const String baseUrl = 'YOUR_CLOUD_FUNCTION_URL';
  
//   /// Update order status and trigger push notification
//   /// 
//   /// Example usage:
//   /// ```dart
//   /// await OrderStatusApiService.updateOrderStatus(
//   ///   orderId: 'order_123',
//   ///   newStatus: 'in_transit',
//   ///   latitude: 6.9271,
//   ///   longitude: 79.8612,
//   /// );
//   /// ```
//   /// 
//   /// Example request body:
//   /// ```json
//   /// {
//   ///   "orderId": "order_123",
//   ///   "newStatus": "in_transit",
//   ///   "location": {
//   ///     "latitude": 6.9271,
//   ///     "longitude": 79.8612
//   ///   }
//   /// }
//   /// ```
//   static Future<bool> updateOrderStatus({
//     required String orderId,
//     required String newStatus,
//     double? latitude,
//     double? longitude,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/updateOrderStatus'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'orderId': orderId,
//           'newStatus': newStatus,
//           if (latitude != null && longitude != null)
//             'location': {
//               'latitude': latitude,
//               'longitude': longitude,
//               'timestamp': DateTime.now().toIso8601String(),
//             },
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Order status updated successfully');
//         return true;
//       } else {
//         print('Failed to update order status: ${response.statusCode}');
//         print('Response: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       print('Error updating order status: $e');
//       return false;
//     }
//   }

//   /// Get all orders for a merchant
//   static Future<List<Map<String, dynamic>>?> getOrders({
//     required String merchantId,
//   }) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/getOrders?merchantId=$merchantId'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return List<Map<String, dynamic>>.from(data['orders']);
//       } else {
//         print('Failed to fetch orders: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       print('Error fetching orders: $e');
//       return null;
//     }
//   }
// }
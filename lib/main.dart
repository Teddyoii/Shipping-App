// lib/main.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shipping_app/core/services/order_update_service.dart';
import 'package:shipping_app/features/auth/presentaion/bloc/auth_bloc.dart';
import 'package:shipping_app/features/auth/presentaion/bloc/auth_event.dart';
import 'package:shipping_app/features/auth/presentaion/pages/loading_page.dart';
import 'package:shipping_app/features/dashboard/presentaion/bloc/dashboard_bloc.dart';
import 'package:shipping_app/features/orders/presentaion/bloc/orders_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize dependency injection
  await di.init();
  
  // Initialize push notifications
  await NotificationService().initialize();
    // 🆕 ADD THIS - Get and print FCM token
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // print('=================================');
  // print('FCM TOKEN: $fcmToken');
  // print('=================================');

    OrderUpdateService().listenToOrderUpdates('merchant_001');
  
  runApp(const ShippingTrackerApp());
}

class ShippingTrackerApp extends StatelessWidget {
  const ShippingTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatus())),
        BlocProvider(create: (_) => di.sl<DashboardBloc>()),
        BlocProvider(create: (_) => di.sl<OrdersBloc>()),
      ],
      child: MaterialApp(
        title: 'Shipping Tracker',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const LoadingPage(),
      ),
    );
  }
}
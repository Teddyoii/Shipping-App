
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shipping_app/features/auth/presentaion/bloc/auth_bloc.dart';
import 'package:shipping_app/features/dashboard/presentaion/bloc/dashboard_bloc.dart';
import 'package:shipping_app/features/orders/presentaion/bloc/orders_bloc.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/data/datasources/dashboard_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/data/datasources/orders_datasource.dart';
import '../services/order_update_service.dart'; // 🆕 Added

/// Service locator for dependency injection
/// Uses GetIt package to manage dependencies
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  // =====================================================================
  // Blocs
  // =====================================================================
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => DashboardBloc(dashboardRepository: sl()));
  sl.registerFactory(() => OrdersBloc(ordersRepository: sl()));
  
  // =====================================================================
  // Repositories
  // =====================================================================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authDataSource: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(dashboardDataSource: sl()),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(ordersDataSource: sl()),
  );
  
  // =====================================================================
  // Data Sources
  // =====================================================================
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<DashboardDataSource>(
    () => DashboardDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<OrdersDataSource>(
    () => OrdersDataSourceImpl(firestore: sl()),
  );
  
  // =====================================================================
  //  Services (FREE Firebase plan)
  // =====================================================================
  sl.registerLazySingleton(() => OrderUpdateService());
  
  // =====================================================================
  // External Dependencies (Firebase)
  // =====================================================================
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
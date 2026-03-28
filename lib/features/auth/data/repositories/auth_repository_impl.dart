// lib/features/auth/data/repositories/auth_repository_impl.dart
import '../../../../domain/entities/user.dart';
import '../datasources/auth_datasource.dart';

/// Abstract repository interface for authentication
abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> login({required String email, required String password});
  Future<void> logout();
}

/// Implementation of authentication repository
/// Coordinates between domain layer and data sources
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;

  AuthRepositoryImpl({required this.authDataSource});

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await authDataSource.getCurrentUser();
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      return await authDataSource.login(email: email, password: password);
    } catch (e) {
      rethrow; // Rethrow to preserve original error message
    }
  }

  @override
  Future<void> logout() async {
    try {
      await authDataSource.logout();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
}
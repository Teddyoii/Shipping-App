// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// BLoC for authentication logic
/// Handles login, logout, and auth status checking
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Check if user is already logged in
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Failed to logout'));
    }
  }

  /// Convert exceptions to user-friendly messages
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('user-not-found')) {
      return 'No user found with this email';
    } else if (errorString.contains('wrong-password')) {
      return 'Incorrect password';
    } else if (errorString.contains('invalid-email')) {
      return 'Invalid email format';
    } else if (errorString.contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    } else if (errorString.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later';
    }
    
    return 'Login failed. Please try again';
  }
}
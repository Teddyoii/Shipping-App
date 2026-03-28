// lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user.dart';

/// Base class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when app starts
class AuthInitial extends AuthState {}

/// State while checking authentication status
class AuthLoading extends AuthState {}

/// State when user is authenticated
class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object> get props => [user];
}

/// State when user is not authenticated
class Unauthenticated extends AuthState {}

/// State when authentication fails
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
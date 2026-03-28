// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Event to check if user is already authenticated
class CheckAuthStatus extends AuthEvent {}

/// Event triggered when user attempts to login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Event triggered when user logs out
class LogoutRequested extends AuthEvent {}
// lib/domain/entities/user.dart
import 'package:equatable/equatable.dart';

/// User entity representing a merchant/business owner
/// This is a domain model that is independent of data sources
class User extends Equatable {
  final String id;
  final String email;
  final String merchantName;
  final String? logoUrl;

  const User({
    required this.id,
    required this.email,
    required this.merchantName,
    this.logoUrl,
  });

  @override
  List<Object?> get props => [id, email, merchantName, logoUrl];

  /// Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? email,
    String? merchantName,
    String? logoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      merchantName: merchantName ?? this.merchantName,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
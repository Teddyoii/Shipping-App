// lib/features/auth/data/datasources/auth_datasource.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../domain/entities/user.dart';

/// Abstract data source interface for authentication
abstract class AuthDataSource {
  Future<User?> getCurrentUser();
  Future<User> login({required String email, required String password});
  Future<void> logout();
}

/// Implementation of authentication data source using Firebase
class AuthDataSourceImpl implements AuthDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Fetch merchant details from Firestore
      final doc = await firestore
          .collection('merchants')
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        merchantName: data['merchantName'] ?? 'Merchant',
        logoUrl: data['logoUrl'],
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Login failed');
      }

      // Fetch merchant details from Firestore
      final doc = await firestore
          .collection('merchants')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception('Merchant profile not found');
      }

      final data = doc.data()!;
      return User(
        id: credential.user!.uid,
        email: credential.user!.email!,
        merchantName: data['merchantName'] ?? 'Merchant',
        logoUrl: data['logoUrl'],
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
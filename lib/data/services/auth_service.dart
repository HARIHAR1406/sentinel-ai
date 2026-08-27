import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import 'firebase_auth_service.dart';

abstract class AuthService {
  Future<UserModel?> signInWithEmail(String email, String password);
  Future<UserModel?> registerWithEmail(String email, String password, String name);
  Future<void> signOut();
  Stream<UserModel?> get authStateChanges;
}

final authServiceProvider = Provider<AuthService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return FirebaseAuthService(databaseService);
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

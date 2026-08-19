import '../models/user_model.dart';

/// Abstract class defining the required authentication methods.
/// Phase 7.1 Foundation: Only the interface is provided.
abstract class AuthService {
  Future<UserModel?> signInWithEmail(String email, String password);
  Future<UserModel?> registerWithEmail(String email, String password, String name);
  Future<void> signOut();
  Stream<UserModel?> get authStateChanges;
}

import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'auth_service.dart';
import 'database_service.dart';
import 'firestore_notification_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _databaseService;

  FirebaseAuthService(this._databaseService);

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) {
        return null;
      }
      return await _databaseService.getUserProfile(user.uid);
    });
  }

  Future<void> _registerFCMToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      if (!kIsWeb && Platform.isIOS) {
        await messaging.requestPermission();
      }
      // On Android 13+, permissions are handled by PermissionHandler in Settings,
      // but FCM token generation doesn't strictly require it to proceed for token generation.
      
      final token = await messaging.getToken();
      if (token != null) {
        await FirestoreNotificationService().saveDeviceToken(token, kIsWeb ? 'web' : Platform.operatingSystem);
      }
      
      messaging.onTokenRefresh.listen((newToken) {
        FirestoreNotificationService().saveDeviceToken(newToken, kIsWeb ? 'web' : Platform.operatingSystem);
      });
    } catch (e) {
      debugPrint('FCM Token registration failed: $e');
    }
  }

  @override
  Future<UserModel?> registerWithEmail(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          name: name,
          email: email,
          phone: '',
          role: 'user', // Default role
          preferences: {
            'incidentAlertsEnabled': true,
            'highRiskAlertsEnabled': true,
          },
        );
        
        await _databaseService.createUserProfile(userModel);
        await _registerFCMToken();
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        final profile = await _databaseService.getUserProfile(user.uid);
        await _registerFCMToken();
        return profile;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

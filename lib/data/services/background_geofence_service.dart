import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Initialize Firebase if not already initialized
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      
      // 2. Check permissions in the background
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return true; // Cannot proceed without permission
      }

      // 3. Fetch current location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // 4. Check for nearby verified incidents in Firestore
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('incidents')
          .where('verificationStatus', isEqualTo: 'verified')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      bool hasHighRisk = false;
      String? alertMessage;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final location = data['location'] as GeoPoint?;
        
        if (location != null) {
          final distance = Geolocator.distanceBetween(
            position.latitude, position.longitude,
            location.latitude, location.longitude,
          );

          // If within 2km and severity is high/critical
          if (distance <= 2000.0) {
            final severity = data['severity'] ?? 'medium';
            if (severity == 'high' || severity == 'critical') {
              hasHighRisk = true;
              alertMessage = data['title'] ?? 'Dangerous incident nearby!';
              break;
            }
          }
        }
      }

      if (hasHighRisk && alertMessage != null) {
        // Trigger local notification
        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
            
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const InitializationSettings initializationSettings =
            InitializationSettings(android: initializationSettingsAndroid);
            
        await flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
        );
        
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'sentinel_ai_geofence',
          'Sentinel Safety Alerts',
          channelDescription: 'Alerts you when you enter high risk zones',
          importance: Importance.max,
          priority: Priority.high,
        );
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
            
        await flutterLocalNotificationsPlugin.show(
          DateTime.now().millisecond,
          'Sentinel AI Geofence Alert',
          'High Risk Zone: $alertMessage',
          platformChannelSpecifics,
        );
      }
      
      return true;
    } catch (e) {
      debugPrint('Background Geofencing Error: $e');
      return false;
    }
  });
}

class BackgroundGeofenceService {
  static const String geofenceTask = "geofence_check_task";
  
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  static Future<void> registerGeofencingTask() async {
    await Workmanager().registerPeriodicTask(
      "sentinel_geofence_1",
      geofenceTask,
      frequency: const Duration(minutes: 15), // Minimum allowed by Android is 15 minutes
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> cancelGeofencingTask() async {
    await Workmanager().cancelByUniqueName("sentinel_geofence_1");
  }
}

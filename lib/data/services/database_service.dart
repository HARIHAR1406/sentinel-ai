import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_model.dart';
import '../models/user_model.dart';
import '../models/trusted_contact_model.dart';
import 'firestore_incident_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return FirestoreIncidentService();
});

final nearbyIncidentsStreamProvider = StreamProvider.autoDispose<List<IncidentModel>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  // Default values for nearby incidents until geospatial is fully implemented
  return dbService.getNearbyIncidents(0, 0, 10);
});

final trustedContactsStreamProvider = StreamProvider.autoDispose<List<TrustedContactModel>>((ref) {
  return ref.watch(databaseServiceProvider).getTrustedContactsStream();
});

/// Abstract class defining Firestore interactions.
abstract class DatabaseService {
  Future<void> createUserProfile(UserModel user);
  Future<UserModel?> getUserProfile(String uid);
  Future<void> reportIncident(IncidentModel incident);
  Stream<List<IncidentModel>> getNearbyIncidents(double lat, double lng, double radiusKm);
  
  Stream<List<TrustedContactModel>> getTrustedContactsStream();
  Future<void> addTrustedContact(TrustedContactModel contact);
  Future<void> updateTrustedContact(TrustedContactModel contact);
  Future<void> deleteTrustedContact(String contactId);
  
  Future<void> logEmergency(String emergencyMessage, double? lat, double? lng);
}

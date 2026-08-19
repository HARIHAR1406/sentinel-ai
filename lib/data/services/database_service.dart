import '../models/incident_model.dart';
import '../models/user_model.dart';

/// Abstract class defining Firestore interactions.
/// Phase 7.1 Foundation: Only the interface is provided.
abstract class DatabaseService {
  Future<void> createUserProfile(UserModel user);
  Future<UserModel?> getUserProfile(String uid);
  Future<void> reportIncident(IncidentModel incident);
  Stream<List<IncidentModel>> getNearbyIncidents(double lat, double lng, double radiusKm);
}

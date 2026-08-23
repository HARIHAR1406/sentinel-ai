import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/incident_model.dart';
import '../models/user_model.dart';
import '../models/trusted_contact_model.dart';
import 'database_service.dart';

class FirestoreIncidentService implements DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set({
      'email': user.email,
      'name': user.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      preferences: data['preferences'] ?? {},
    );
  }

  @override
  Future<void> reportIncident(IncidentModel incident) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Authentication required to report an incident');
    }
    
    // Ensure the reportedBy field matches the authenticated user
    if (incident.reportedBy != user.uid) {
        throw Exception('Mismatched reporter UID');
    }
    
    // Create document in incidents collection
    await _firestore.collection('incidents').doc(incident.id).set(
      incident.toFirestore()
    );
  }

  @override
  Stream<List<IncidentModel>> getNearbyIncidents(double lat, double lng, double radiusKm) {
    // For Phase 7.4, this uses a simple query fetching recent incidents.
    // Real geospatial queries require GeoFire or composite indexes.
    return _firestore
        .collection('incidents')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IncidentModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<TrustedContactModel>> getTrustedContactsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('trusted_contacts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TrustedContactModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> addTrustedContact(TrustedContactModel contact) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Authentication required');
    if (contact.ownerId != user.uid) throw Exception('Mismatched owner UID');
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('trusted_contacts')
        .doc(contact.id)
        .set(contact.toMap());
  }

  @override
  Future<void> updateTrustedContact(TrustedContactModel contact) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Authentication required');
    if (contact.ownerId != user.uid) throw Exception('Mismatched owner UID');
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('trusted_contacts')
        .doc(contact.id)
        .update(contact.toMap());
  }

  @override
  Future<void> deleteTrustedContact(String contactId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Authentication required');
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('trusted_contacts')
        .doc(contactId)
        .delete();
  }

  @override
  Future<void> logEmergency(String emergencyMessage, double? lat, double? lng) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Authentication required');
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('emergencies')
        .add({
      'message': emergencyMessage,
      'lat': lat,
      'lng': lng,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

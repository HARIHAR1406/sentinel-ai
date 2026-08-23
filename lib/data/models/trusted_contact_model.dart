import 'package:cloud_firestore/cloud_firestore.dart';

class TrustedContactModel {
  final String id;
  final String ownerId;
  final String name;
  final String phone;
  final String? email;
  final String relationship;
  final bool isEmergencyDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TrustedContactModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.phone,
    this.email,
    required this.relationship,
    required this.isEmergencyDefault,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
      'isEmergencyDefault': isEmergencyDefault,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory TrustedContactModel.fromMap(Map<String, dynamic> map, String docId) {
    return TrustedContactModel(
      id: docId,
      ownerId: map['ownerId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String?,
      relationship: map['relationship'] as String? ?? '',
      isEmergencyDefault: map['isEmergencyDefault'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  TrustedContactModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? phone,
    String? email,
    String? relationship,
    bool? isEmergencyDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrustedContactModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      isEmergencyDefault: isEmergencyDefault ?? this.isEmergencyDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

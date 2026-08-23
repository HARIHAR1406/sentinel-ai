import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceTokenModel {
  final String token;
  final String platform;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool enabled;

  const DeviceTokenModel({
    required this.token,
    required this.platform,
    required this.createdAt,
    required this.updatedAt,
    required this.enabled,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'token': token,
      'platform': platform,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'enabled': enabled,
    };
  }

  factory DeviceTokenModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    return DeviceTokenModel(
      token: data['token'] as String? ?? doc.id,
      platform: data['platform'] as String? ?? 'unknown',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      enabled: data['enabled'] as bool? ?? true,
    );
  }

  DeviceTokenModel copyWith({
    String? token,
    String? platform,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? enabled,
  }) {
    return DeviceTokenModel(
      token: token ?? this.token,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      enabled: enabled ?? this.enabled,
    );
  }
}

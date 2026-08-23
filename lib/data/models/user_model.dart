class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final Map<String, dynamic> preferences;

  bool get incidentAlertsEnabled => preferences['incidentAlertsEnabled'] ?? true;
  bool get highRiskAlertsEnabled => preferences['highRiskAlertsEnabled'] ?? true;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'preferences': preferences,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'user',
      preferences: map['preferences'] != null ? Map<String, dynamic>.from(map['preferences']) : {},
    );
  }
}

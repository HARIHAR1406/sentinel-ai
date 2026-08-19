class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final Map<String, dynamic> preferences;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.preferences,
  });

  // TODO(Phase 7.2): Add copyWith, toMap, fromMap, etc.
}

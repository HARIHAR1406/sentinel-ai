class TrustedContactModel {
  final String id;
  final String ownerId;
  final String name;
  final String phone;
  final bool isEmergencyDefault;

  const TrustedContactModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.phone,
    required this.isEmergencyDefault,
  });
}

class HealthCard {
  final String id;
  final String userId;
  final String bloodGroup;
  final String allergies;
  final String medications;
  final String emergencyContact;

  HealthCard({
    required this.id,
    required this.userId,
    required this.bloodGroup,
    required this.allergies,
    required this.medications,
    required this.emergencyContact,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'bloodGroup': bloodGroup,
        'allergies': allergies,
        'medications': medications,
        'emergencyContact': emergencyContact,
      };

  factory HealthCard.fromJson(Map<String, dynamic> json) => HealthCard(
        id: json['id'] as String,
        userId: json['userId'] as String,
        bloodGroup: json['bloodGroup'] as String,
        allergies: json['allergies'] as String,
        medications: json['medications'] as String,
        emergencyContact: json['emergencyContact'] as String,
      );
}

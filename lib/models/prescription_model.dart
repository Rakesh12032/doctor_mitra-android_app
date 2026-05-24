class Prescription {
  final String id;
  final String bookingId;
  final String doctorId;
  final String patientId;
  final String diagnosis;
  final String medicines;
  final String advice;
  final String createdAt;

  Prescription({
    required this.id,
    required this.bookingId,
    required this.doctorId,
    required this.patientId,
    required this.diagnosis,
    required this.medicines,
    required this.advice,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'doctorId': doctorId,
        'patientId': patientId,
        'diagnosis': diagnosis,
        'medicines': medicines,
        'advice': advice,
        'createdAt': createdAt,
      };

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        id: json['id'] as String,
        bookingId: json['bookingId'] as String,
        doctorId: json['doctorId'] as String,
        patientId: json['patientId'] as String,
        diagnosis: json['diagnosis'] as String,
        medicines: json['medicines'] as String,
        advice: json['advice'] as String,
        createdAt: json['createdAt'] as String,
      );
}

class Booking {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String patientMobile;
  final String type;
  final String date;
  final String time;
  final String symptoms;
  final double fee;
  final String status;
  final String createdAt;

  // Premium UI/UX bilingual fields
  final String doctorNameEn;
  final String doctorNameHi;
  final String specialtyEn;
  final String specialtyHi;

  Booking({
    required this.id,
    String? patientId,
    required this.doctorId,
    required this.patientName,
    String? patientMobile,
    String? type,
    required this.date,
    required this.time,
    required this.symptoms,
    required this.fee,
    required this.status,
    required this.createdAt,
    // Premium fields
    String? doctorNameEn,
    String? doctorNameHi,
    String? specialtyEn,
    String? specialtyHi,
    String? phoneNumber, // alias parameter
  })  : patientId = patientId ?? '',
        patientMobile = patientMobile ?? phoneNumber ?? '',
        type = type ?? 'clinic',
        doctorNameEn = doctorNameEn ?? '',
        doctorNameHi = doctorNameHi ?? '',
        specialtyEn = specialtyEn ?? '',
        specialtyHi = specialtyHi ?? '';

  String get phoneNumber => patientMobile;

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'doctorId': doctorId,
        'patientName': patientName,
        'patientMobile': patientMobile,
        'type': type,
        'date': date,
        'time': time,
        'symptoms': symptoms,
        'fee': fee,
        'status': status,
        'createdAt': createdAt,
        // Premium fields
        'doctorNameEn': doctorNameEn,
        'doctorNameHi': doctorNameHi,
        'specialtyEn': specialtyEn,
        'specialtyHi': specialtyHi,
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String? ?? '',
        patientId: json['patientId'] as String? ?? '',
        doctorId: json['doctorId'] as String? ?? '',
        patientName: json['patientName'] as String? ?? '',
        patientMobile: json['patientMobile'] as String? ?? json['phoneNumber'] as String? ?? '',
        type: json['type'] as String? ?? 'clinic',
        date: json['date'] as String? ?? '',
        time: json['time'] as String? ?? '',
        symptoms: json['symptoms'] as String? ?? '',
        fee: (json['fee'] as num? ?? 0.0).toDouble(),
        status: json['status'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? '',
        doctorNameEn: json['doctorNameEn'] as String?,
        doctorNameHi: json['doctorNameHi'] as String?,
        specialtyEn: json['specialtyEn'] as String?,
        specialtyHi: json['specialtyHi'] as String?,
      );

  Booking copyWith({
    String? status,
    String? date,
    String? time,
    double? fee,
    String? doctorNameEn,
    String? doctorNameHi,
    String? specialtyEn,
    String? specialtyHi,
  }) =>
      Booking(
        id: id,
        patientId: patientId,
        doctorId: doctorId,
        patientName: patientName,
        patientMobile: patientMobile,
        type: type,
        date: date ?? this.date,
        time: time ?? this.time,
        symptoms: symptoms,
        fee: fee ?? this.fee,
        status: status ?? this.status,
        createdAt: createdAt,
        doctorNameEn: doctorNameEn ?? this.doctorNameEn,
        doctorNameHi: doctorNameHi ?? this.doctorNameHi,
        specialtyEn: specialtyEn ?? this.specialtyEn,
        specialtyHi: specialtyHi ?? this.specialtyHi,
      );
}

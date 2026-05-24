import 'package:flutter/material.dart';

class Doctor {
  final String id;
  final String userId;
  final String name;
  final String specialty;
  final String degree;
  final int experience;
  final String registrationNumber;
  final String clinicName;
  final String address;
  final String district;
  final double fee;
  final double onlineFee;
  final double rating;
  final int reviews;
  final String status;
  final bool isOnlineAvailable;
  final List<String> slots;

  // Premium UI/UX bilingual and helper fields
  final String nameEn;
  final String nameHi;
  final String degreeEn;
  final String degreeHi;
  final String specialtyEn;
  final String specialtyHi;
  final String clinicEn;
  final String clinicHi;
  final String districtEn;
  final String districtHi;
  final bool isOnline;
  final Color specialtyColor;

  Doctor({
    required this.id,
    this.userId = '',
    String? name,
    String? specialty,
    String? degree,
    required this.experience,
    this.registrationNumber = '',
    String? clinicName,
    this.address = '',
    String? district,
    required this.fee,
    this.onlineFee = 0.0,
    required this.rating,
    required this.reviews,
    this.status = 'approved',
    bool? isOnlineAvailable,
    required this.slots,
    String? nameEn,
    String? nameHi,
    String? degreeEn,
    String? degreeHi,
    String? specialtyEn,
    String? specialtyHi,
    String? clinicEn,
    String? clinicHi,
    String? districtEn,
    String? districtHi,
    bool? isOnline,
    Color? specialtyColor,
  })  : name = name ?? nameEn ?? nameHi ?? '',
        specialty = specialty ?? specialtyEn ?? specialtyHi ?? '',
        degree = degree ?? degreeEn ?? degreeHi ?? '',
        clinicName = clinicName ?? clinicEn ?? clinicHi ?? '',
        district = district ?? districtEn ?? districtHi ?? '',
        isOnlineAvailable = isOnlineAvailable ?? isOnline ?? false,
        nameEn = nameEn ?? name ?? nameHi ?? '',
        nameHi = nameHi ?? name ?? nameEn ?? '',
        degreeEn = degreeEn ?? degree ?? degreeHi ?? '',
        degreeHi = degreeHi ?? degree ?? degreeEn ?? '',
        specialtyEn = specialtyEn ?? specialty ?? specialtyHi ?? '',
        specialtyHi = specialtyHi ?? specialty ?? specialtyEn ?? '',
        clinicEn = clinicEn ?? clinicName ?? clinicHi ?? '',
        clinicHi = clinicHi ?? clinicName ?? clinicEn ?? '',
        districtEn = districtEn ?? district ?? districtHi ?? '',
        districtHi = districtHi ?? district ?? districtEn ?? '',
        isOnline = isOnline ?? isOnlineAvailable ?? false,
        specialtyColor = specialtyColor ?? _getDefaultSpecialtyColor(specialty ?? specialtyEn ?? specialtyHi ?? '');

  static Color _getDefaultSpecialtyColor(String specialty) {
    final s = specialty.toLowerCase();
    if (s.contains('general') || s.contains('physician')) return Colors.blue;
    if (s.contains('gyne') || s.contains('women')) return Colors.pink;
    if (s.contains('cardio') || s.contains('heart')) return Colors.red;
    if (s.contains('derm') || s.contains('skin')) return Colors.teal;
    if (s.contains('neuro')) return Colors.purple;
    if (s.contains('dent') || s.contains('teeth')) return Colors.cyan;
    if (s.contains('pedi') || s.contains('child')) return Colors.lightGreen;
    if (s.contains('ortho') || s.contains('bone')) return Colors.orange;
    if (s.contains('ent')) return Colors.brown;
    if (s.contains('psych')) return Colors.deepPurple;
    return Colors.green;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'specialty': specialty,
        'degree': degree,
        'experience': experience,
        'registrationNumber': registrationNumber,
        'clinicName': clinicName,
        'address': address,
        'district': district,
        'fee': fee,
        'onlineFee': onlineFee,
        'rating': rating,
        'reviews': reviews,
        'status': status,
        'isOnlineAvailable': isOnlineAvailable,
        'slots': slots,
        // Premium fields
        'nameEn': nameEn,
        'nameHi': nameHi,
        'degreeEn': degreeEn,
        'degreeHi': degreeHi,
        'specialtyEn': specialtyEn,
        'specialtyHi': specialtyHi,
        'clinicEn': clinicEn,
        'clinicHi': clinicHi,
        'districtEn': districtEn,
        'districtHi': districtHi,
        'isOnline': isOnline,
      };

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final specialty = json['specialty'] as String? ?? '';
    return Doctor(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      specialty: specialty,
      degree: json['degree'] as String? ?? '',
      experience: json['experience'] as int? ?? 0,
      registrationNumber: json['registrationNumber'] as String? ?? '',
      clinicName: json['clinicName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      district: json['district'] as String? ?? '',
      fee: (json['fee'] as num? ?? 0.0).toDouble(),
      onlineFee: (json['onlineFee'] as num? ?? 0.0).toDouble(),
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      reviews: json['reviews'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      isOnlineAvailable: json['isOnlineAvailable'] as bool? ?? false,
      slots: json['slots'] != null ? List<String>.from(json['slots'] as List) : [],
      nameEn: json['nameEn'] as String?,
      nameHi: json['nameHi'] as String?,
      degreeEn: json['degreeEn'] as String?,
      degreeHi: json['degreeHi'] as String?,
      specialtyEn: json['specialtyEn'] as String?,
      specialtyHi: json['specialtyHi'] as String?,
      clinicEn: json['clinicEn'] as String?,
      clinicHi: json['clinicHi'] as String?,
      districtEn: json['districtEn'] as String?,
      districtHi: json['districtHi'] as String?,
      isOnline: json['isOnline'] as bool?,
    );
  }

  Doctor copyWith({
    String? name,
    String? specialty,
    String? degree,
    int? experience,
    String? registrationNumber,
    String? clinicName,
    String? address,
    String? district,
    double? fee,
    double? onlineFee,
    double? rating,
    int? reviews,
    String? status,
    bool? isOnlineAvailable,
    List<String>? slots,
  }) =>
      Doctor(
        id: id,
        userId: userId,
        name: name ?? this.name,
        specialty: specialty ?? this.specialty,
        degree: degree ?? this.degree,
        experience: experience ?? this.experience,
        registrationNumber: registrationNumber ?? this.registrationNumber,
        clinicName: clinicName ?? this.clinicName,
        address: address ?? this.address,
        district: district ?? this.district,
        fee: fee ?? this.fee,
        onlineFee: onlineFee ?? this.onlineFee,
        rating: rating ?? this.rating,
        reviews: reviews ?? this.reviews,
        status: status ?? this.status,
        isOnlineAvailable: isOnlineAvailable ?? this.isOnlineAvailable,
        slots: slots ?? this.slots,
      );
}


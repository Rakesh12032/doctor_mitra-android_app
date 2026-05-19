import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class AppUser {
  final String id;
  final String role;
  final String name;
  final String mobile;
  final String email;
  final String? password;
  final String district;
  final String createdAt;

  AppUser({
    required this.id,
    required this.role,
    required this.name,
    required this.mobile,
    required this.email,
    this.password,
    required this.district,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'name': name,
        'mobile': mobile,
        'email': email,
        'password': password,
        'district': district,
        'createdAt': createdAt,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        role: json['role'] as String,
        name: json['name'] as String,
        mobile: json['mobile'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String?,
        district: json['district'] as String? ?? 'Patna',
        createdAt: json['createdAt'] as String,
      );

  AppUser copyWith({String? name, String? mobile, String? district}) => AppUser(
        id: id,
        role: role,
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        email: email,
        password: password,
        district: district ?? this.district,
        createdAt: createdAt,
      );
}

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

  Doctor({
    required this.id,
    required this.userId,
    required this.name,
    required this.specialty,
    required this.degree,
    required this.experience,
    required this.registrationNumber,
    required this.clinicName,
    required this.address,
    required this.district,
    required this.fee,
    required this.onlineFee,
    required this.rating,
    required this.reviews,
    required this.status,
    required this.isOnlineAvailable,
    required this.slots,
  });

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
      };

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        id: json['id'] as String,
        userId: json['userId'] as String,
        name: json['name'] as String,
        specialty: json['specialty'] as String,
        degree: json['degree'] as String,
        experience: json['experience'] as int,
        registrationNumber: json['registrationNumber'] as String,
        clinicName: json['clinicName'] as String,
        address: json['address'] as String,
        district: json['district'] as String,
        fee: (json['fee'] as num).toDouble(),
        onlineFee: (json['onlineFee'] as num).toDouble(),
        rating: (json['rating'] as num).toDouble(),
        reviews: json['reviews'] as int,
        status: json['status'] as String,
        isOnlineAvailable: json['isOnlineAvailable'] as bool,
        slots: List<String>.from(json['slots'] as List),
      );

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

  Booking({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.patientMobile,
    required this.type,
    required this.date,
    required this.time,
    required this.symptoms,
    required this.fee,
    required this.status,
    required this.createdAt,
  });

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
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        doctorId: json['doctorId'] as String,
        patientName: json['patientName'] as String,
        patientMobile: json['patientMobile'] as String,
        type: json['type'] as String,
        date: json['date'] as String,
        time: json['time'] as String,
        symptoms: json['symptoms'] as String,
        fee: (json['fee'] as num).toDouble(),
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
      );

  Booking copyWith({String? status, String? date, String? time, double? fee}) =>
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
      );
}

class Hospital {
  final String id;
  final String name;
  final String district;
  final String address;
  final String phone;
  final String type;

  Hospital({
    required this.id,
    required this.name,
    required this.district,
    required this.address,
    required this.phone,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'district': district,
        'address': address,
        'phone': phone,
        'type': type,
      };

  factory Hospital.fromJson(Map<String, dynamic> json) => Hospital(
        id: json['id'] as String,
        name: json['name'] as String,
        district: json['district'] as String,
        address: json['address'] as String,
        phone: json['phone'] as String,
        type: json['type'] as String,
      );
}

class AmbulanceProviderModel {
  final String id;
  final String name;
  final String district;
  final String phone;
  final bool isAvailable;

  AmbulanceProviderModel({
    required this.id,
    required this.name,
    required this.district,
    required this.phone,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'district': district,
        'phone': phone,
        'isAvailable': isAvailable,
      };

  factory AmbulanceProviderModel.fromJson(Map<String, dynamic> json) =>
      AmbulanceProviderModel(
        id: json['id'] as String,
        name: json['name'] as String,
        district: json['district'] as String,
        phone: json['phone'] as String,
        isAvailable: json['isAvailable'] as bool,
      );
}

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

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'createdAt': createdAt,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: json['createdAt'] as String,
      );
}

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

class LocalStorageLayer {
  static const _stateKey = 'doctor_mitra_role_mvp_state_v1';

  Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_stateKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> write(Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, jsonEncode(value));
  }
}

class InternetApiLayer {
  static const String baseUrl = String.fromEnvironment('DOCTOR_MITRA_API_URL');
  static bool get isConfiguredStatic => baseUrl.trim().isNotEmpty;
  bool get isConfigured => baseUrl.trim().isNotEmpty;

  Uri _uri(String path) => Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');

  Future<Map<String, dynamic>?> readState() async {
    if (!isConfigured) return null;
    try {
      final response = await http.get(_uri('/api/state')).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> writeState(Map<String, dynamic> value) async {
    if (!isConfigured) return false;
    try {
      final response = await http
          .put(
            _uri('/api/state'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(value),
          )
          .timeout(const Duration(seconds: 8));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> runAction(
    String type,
    Map<String, dynamic> payload,
  ) async {
    if (!isConfigured) return null;
    try {
      final response = await http
          .post(
            _uri('/api/actions'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'type': type, 'payload': payload}),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return {'ok': false, 'error': decoded['error'] ?? 'Server error'};
      }
      return decoded;
    } catch (_) {
      return null;
    }
  }

  Future<bool> health() async {
    if (!isConfigured) return false;
    try {
      final response = await http.get(_uri('/health')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class SupabaseApiLayer {
  static const String projectUrl = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _stateId = 'singleton';

  static bool get isConfiguredStatic =>
      projectUrl.trim().isNotEmpty && anonKey.trim().isNotEmpty;
  bool get isConfigured => isConfiguredStatic;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = projectUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Map<String, String> get _headers => {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>?> readState() async {
    if (!isConfigured) return null;
    try {
      final response = await http
          .get(
            _uri('/rest/v1/doctor_mitra_state', {
              'id': 'eq.$_stateId',
              'select': 'state',
              'limit': '1',
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final rows = jsonDecode(response.body) as List<dynamic>;
      if (rows.isEmpty) return null;
      final state = (rows.first as Map<String, dynamic>)['state'];
      if (state is! Map<String, dynamic> || state['users'] is! List) return null;
      return state;
    } catch (_) {
      return null;
    }
  }

  Future<bool> writeState(Map<String, dynamic> value) async {
    if (!isConfigured) return false;
    try {
      final response = await http
          .post(
            _uri('/rest/v1/doctor_mitra_state', {'on_conflict': 'id'}),
            headers: {
              ..._headers,
              'Prefer': 'resolution=merge-duplicates,return=minimal',
            },
            body: jsonEncode({
              'id': _stateId,
              'state': value,
              'updated_at': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> health() async {
    if (!isConfigured) return false;
    try {
      final response = await http
          .get(
            _uri('/rest/v1/doctor_mitra_state', {
              'select': 'id',
              'limit': '1',
            }),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 6));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}

class CloudApiLayer {
  final SupabaseApiLayer _supabase = SupabaseApiLayer();
  final InternetApiLayer _internet = InternetApiLayer();

  static bool get isConfigured =>
      SupabaseApiLayer.isConfiguredStatic || InternetApiLayer.isConfiguredStatic;

  bool get isSupabase => _supabase.isConfigured;
  bool get isInternetActionApi => _internet.isConfigured;
  bool get isConfiguredInstance => _supabase.isConfigured || _internet.isConfigured;

  String get syncLabel => isSupabase ? 'Supabase sync' : 'Internet sync';

  String get endpointLabel {
    if (isSupabase) return 'Supabase: ${SupabaseApiLayer.projectUrl}';
    if (_internet.isConfigured) return 'API: ${InternetApiLayer.baseUrl}';
    return 'No cloud configured. Use SUPABASE_URL + SUPABASE_ANON_KEY, or DOCTOR_MITRA_API_URL.';
  }

  Future<Map<String, dynamic>?> readState() =>
      isSupabase ? _supabase.readState() : _internet.readState();

  Future<bool> writeState(Map<String, dynamic> value) =>
      isSupabase ? _supabase.writeState(value) : _internet.writeState(value);

  Future<bool> health() => isSupabase ? _supabase.health() : _internet.health();

  Future<Map<String, dynamic>?> runAction(String type, Map<String, dynamic> payload) =>
      _internet.runAction(type, payload);
}

class DoctorMitraStore extends ChangeNotifier {
  final LocalStorageLayer _storage = LocalStorageLayer();
  final CloudApiLayer _api = CloudApiLayer();

  bool isLoading = true;
  bool isInternetConnected = false;
  String syncMode = CloudApiLayer.isConfigured ? 'Connecting...' : 'Local demo';
  AppUser? currentUser;
  List<AppUser> users = [];
  List<Doctor> doctors = [];
  List<Booking> bookings = [];
  List<Hospital> hospitals = [];
  List<AmbulanceProviderModel> ambulances = [];
  List<HealthCard> healthCards = [];
  List<AppNotification> notifications = [];
  List<Prescription> prescriptions = [];
  List<String> specialties = [];
  List<String> healthTips = [];
  bool maintenanceMode = false;

  final AuthService authService;
  final PatientService patientService;
  final DoctorService doctorService;
  final AdminService adminService;
  final BookingService bookingService;
  final SlotService slotService;
  final HospitalService hospitalService;
  final AmbulanceService ambulanceService;
  final NotificationService notificationService;

  DoctorMitraStore()
      : authService = AuthService(),
        patientService = PatientService(),
        doctorService = DoctorService(),
        adminService = AdminService(),
        bookingService = BookingService(),
        slotService = SlotService(),
        hospitalService = HospitalService(),
        ambulanceService = AmbulanceService(),
        notificationService = NotificationService();

  Future<void> load() async {
    final raw = await _storage.read();
    if (raw == null) {
      _seed();
      await _save();
    } else {
      _hydrate(raw);
    }

    final remote = await _api.readState();
    if (remote != null && remote['users'] is List) {
      final localCurrentUserId = currentUser?.id;
      _hydrate(remote);
      if (localCurrentUserId != null) {
        currentUser = users.where((user) => user.id == localCurrentUserId).firstOrNull;
      }
      isInternetConnected = true;
      syncMode = _api.syncLabel;
      await _saveLocalOnly();
    } else {
      isInternetConnected = false;
      syncMode = _api.isConfiguredInstance ? 'Offline fallback' : 'Local demo';
    }
    isLoading = false;
    notifyListeners();
  }

  void _hydrate(Map<String, dynamic> raw) {
    users = (raw['users'] as List).map((e) => AppUser.fromJson(e)).toList();
    doctors = (raw['doctors'] as List).map((e) => Doctor.fromJson(e)).toList();
    bookings = (raw['bookings'] as List).map((e) => Booking.fromJson(e)).toList();
    hospitals = (raw['hospitals'] as List).map((e) => Hospital.fromJson(e)).toList();
    ambulances = (raw['ambulances'] as List)
        .map((e) => AmbulanceProviderModel.fromJson(e))
        .toList();
    healthCards =
        (raw['healthCards'] as List).map((e) => HealthCard.fromJson(e)).toList();
    notifications = (raw['notifications'] as List)
        .map((e) => AppNotification.fromJson(e))
        .toList();
    prescriptions = (raw['prescriptions'] as List)
        .map((e) => Prescription.fromJson(e))
        .toList();
    specialties = List<String>.from(raw['specialties'] as List);
    healthTips = List<String>.from(raw['healthTips'] as List);
    maintenanceMode = raw['maintenanceMode'] as bool? ?? false;
    final currentUserId = raw['currentUserId'] as String?;
    if (currentUserId != null) {
      currentUser = users.where((user) => user.id == currentUserId).firstOrNull;
    }
  }

  void _seed() {
    final now = DateTime.now().toIso8601String();
    users = [
      AppUser(
        id: 'admin-1',
        role: 'admin',
        name: 'Doctor Mitra Admin',
        mobile: '',
        email: 'admin@doctormitra.in',
        password: 'Rakesh@12032',
        district: 'Patna',
        createdAt: now,
      ),
      AppUser(
        id: 'patient-1',
        role: 'patient',
        name: 'Rakesh Kumar',
        mobile: '9876543210',
        email: '',
        district: 'Patna',
        createdAt: now,
      ),
      AppUser(
        id: 'doctor-user-1',
        role: 'doctor',
        name: 'Dr. Rajeev Kumar',
        mobile: '9000000001',
        email: 'rajeev@doctormitra.in',
        password: 'doctor123',
        district: 'Patna',
        createdAt: now,
      ),
      AppUser(
        id: 'doctor-user-2',
        role: 'doctor',
        name: 'Dr. Anjali Singh',
        mobile: '9000000002',
        email: 'anjali@doctormitra.in',
        password: 'doctor123',
        district: 'Patna',
        createdAt: now,
      ),
      AppUser(
        id: 'doctor-user-3',
        role: 'doctor',
        name: 'Dr. Vikash Jha',
        mobile: '9000000003',
        email: 'vikash@doctormitra.in',
        password: 'doctor123',
        district: 'Patna',
        createdAt: now,
      ),
      AppUser(
        id: 'doctor-user-4',
        role: 'doctor',
        name: 'Dr. Meena Kumari',
        mobile: '9000000004',
        email: 'meena@doctormitra.in',
        password: 'doctor123',
        district: 'Bhagalpur',
        createdAt: now,
      ),
    ];
    doctors = [
      Doctor(
        id: 'doctor-1',
        userId: 'doctor-user-1',
        name: 'Dr. Rajeev Kumar',
        specialty: 'General Physician',
        degree: 'MBBS, MD (Medicine)',
        experience: 15,
        registrationNumber: 'BRMC-10234',
        clinicName: 'Aarogya Clinic',
        address: 'Boring Road, Patna',
        district: 'Patna',
        fee: 400,
        onlineFee: 250,
        rating: 4.7,
        reviews: 312,
        status: 'approved',
        isOnlineAvailable: true,
        slots: ['09:00', '09:30', '10:00', '10:30', '17:00', '17:30'],
      ),
      Doctor(
        id: 'doctor-2',
        userId: 'doctor-user-2',
        name: 'Dr. Anjali Singh',
        specialty: 'Gynecologist',
        degree: 'MBBS, MS (Obs & Gyn)',
        experience: 12,
        registrationNumber: 'BRMC-11782',
        clinicName: 'Women Care',
        address: 'Kankarbagh, Patna',
        district: 'Patna',
        fee: 600,
        onlineFee: 400,
        rating: 4.8,
        reviews: 421,
        status: 'approved',
        isOnlineAvailable: true,
        slots: ['10:00', '10:30', '11:00', '16:00', '16:30'],
      ),
      Doctor(
        id: 'doctor-3',
        userId: 'doctor-user-3',
        name: 'Dr. Vikash Jha',
        specialty: 'Cardiologist',
        degree: 'MBBS, MD, DM (Cardiology)',
        experience: 20,
        registrationNumber: 'BRMC-12690',
        clinicName: 'Heart Hospital',
        address: 'Rajendra Nagar, Patna',
        district: 'Patna',
        fee: 800,
        onlineFee: 600,
        rating: 4.9,
        reviews: 512,
        status: 'approved',
        isOnlineAvailable: false,
        slots: ['11:00', '11:30', '12:00', '18:00'],
      ),
      Doctor(
        id: 'doctor-4',
        userId: 'doctor-user-4',
        name: 'Dr. Meena Kumari',
        specialty: 'Gynecologist',
        degree: 'MBBS, DGO',
        experience: 18,
        registrationNumber: 'BRMC-14403',
        clinicName: 'Mata Clinic',
        address: 'Adampur, Bhagalpur',
        district: 'Bhagalpur',
        fee: 600,
        onlineFee: 350,
        rating: 4.8,
        reviews: 312,
        status: 'pending',
        isOnlineAvailable: true,
        slots: ['09:00', '09:30', '17:00', '17:30'],
      ),
    ];
    bookings = [
      Booking(
        id: 'booking-1',
        patientId: 'patient-1',
        doctorId: 'doctor-1',
        patientName: 'Rakesh Kumar',
        patientMobile: '9876543210',
        type: 'clinic',
        date: DateFormat('dd MMM yyyy').format(DateTime.now()),
        time: '09:00',
        symptoms: 'Fever and body pain',
        fee: 400,
        status: 'pending',
        createdAt: now,
      ),
    ];
    hospitals = [
      Hospital(
        id: 'hospital-1',
        name: 'Patna City Hospital',
        district: 'Patna',
        address: 'Bailey Road, Patna',
        phone: '0612-2200001',
        type: 'Multispeciality',
      ),
      Hospital(
        id: 'hospital-2',
        name: 'Aarogya Hospital',
        district: 'Bhagalpur',
        address: 'Tilka Manjhi, Bhagalpur',
        phone: '0641-2300002',
        type: 'General',
      ),
    ];
    ambulances = [
      AmbulanceProviderModel(
        id: 'amb-1',
        name: 'Bihar Emergency 102',
        district: 'All Bihar',
        phone: '102',
        isAvailable: true,
      ),
      AmbulanceProviderModel(
        id: 'amb-2',
        name: 'Patna Rapid Ambulance',
        district: 'Patna',
        phone: '9800000102',
        isAvailable: true,
      ),
    ];
    healthCards = [
      HealthCard(
        id: 'hc-1',
        userId: 'patient-1',
        bloodGroup: 'O+',
        allergies: 'Dust, Penicillin',
        medications: 'None',
        emergencyContact: '9876543211',
      ),
    ];
    notifications = [];
    prescriptions = [];
    specialties = [
      'General Physician',
      'Gynecologist',
      'Cardiologist',
      'Dermatologist',
      'Neurologist',
      'Dentist',
    ];
    healthTips = [
      'Drink safe water and keep ORS at home.',
      'Book follow-ups early for chronic conditions.',
      'Use emergency number 102 for ambulance help.',
    ];
  }

  Map<String, dynamic> _toJson({bool includeSession = true}) {
    final Map<String, dynamic> state = {
      'users': users.map((e) => e.toJson()).toList(),
      'doctors': doctors.map((e) => e.toJson()).toList(),
      'bookings': bookings.map((e) => e.toJson()).toList(),
      'hospitals': hospitals.map((e) => e.toJson()).toList(),
      'ambulances': ambulances.map((e) => e.toJson()).toList(),
      'healthCards': healthCards.map((e) => e.toJson()).toList(),
      'notifications': notifications.map((e) => e.toJson()).toList(),
      'prescriptions': prescriptions.map((e) => e.toJson()).toList(),
      'specialties': specialties,
      'healthTips': healthTips,
      'maintenanceMode': maintenanceMode,
    };
    if (includeSession) {
      state['currentUserId'] = currentUser?.id;
    }
    return state;
  }

  Future<void> _saveLocalOnly() => _storage.write(_toJson());
  Future<void> _save() async {
    final state = _toJson();
    await _storage.write(state);
    final synced = await _api.writeState(_toJson(includeSession: false));
    if (_api.isConfiguredInstance) {
      isInternetConnected = synced;
      syncMode = synced ? _api.syncLabel : 'Offline fallback';
    }
  }

  Future<void> syncNow() async {
    final remote = await _api.readState();
    if (remote != null && remote['users'] is List) {
      final localCurrentUserId = currentUser?.id;
      _hydrate(remote);
      if (localCurrentUserId != null) {
        currentUser = users.where((user) => user.id == localCurrentUserId).firstOrNull;
      }
      isInternetConnected = true;
      syncMode = _api.syncLabel;
      await _saveLocalOnly();
    } else {
      final synced = await _api.writeState(_toJson(includeSession: false));
      isInternetConnected = synced;
      syncMode = _api.isConfiguredInstance ? (synced ? _api.syncLabel : 'Offline fallback') : 'Local demo';
    }
    notifyListeners();
  }

  Future<String?> runRemoteAction(
    String type,
    Map<String, dynamic> payload, {
    bool updateCurrentUser = false,
  }) async {
    if (!_api.isInternetActionApi) return 'API not configured';
    final response = await _api.runAction(type, payload);
    if (response == null) {
      isInternetConnected = false;
      syncMode = 'Offline fallback';
      return 'Internet API unavailable';
    }
    if (response['ok'] != true) {
      isInternetConnected = false;
      syncMode = 'Offline fallback';
      return response['error'] as String? ?? 'Server error';
    }

    final localCurrentUserId = currentUser?.id;
    _hydrate(response['state'] as Map<String, dynamic>);
    final nextUserId = updateCurrentUser
        ? response['currentUserId'] as String?
        : localCurrentUserId;
    if (nextUserId != null) {
      currentUser = users.where((user) => user.id == nextUserId).firstOrNull;
    }
    isInternetConnected = true;
    syncMode = _api.syncLabel;
    await _saveLocalOnly();
    notifyListeners();
    return null;
  }

  Future<void> persist() async {
    await _save();
    notifyListeners();
  }

  List<Doctor> get approvedDoctors =>
      doctors.where((doctor) => doctor.status == 'approved').toList();
  List<Doctor> get pendingDoctors =>
      doctors.where((doctor) => doctor.status == 'pending').toList();
  List<AppUser> get patients =>
      users.where((user) => user.role == 'patient').toList();
  Doctor? get currentDoctor => currentUser == null
      ? null
      : doctors.where((doctor) => doctor.userId == currentUser!.id).firstOrNull;
  HealthCard? get currentHealthCard => currentUser == null
      ? null
      : healthCards.where((card) => card.userId == currentUser!.id).firstOrNull;

  Doctor doctorById(String id) =>
      doctors.firstWhere((doctor) => doctor.id == id, orElse: () => doctors.first);
  AppUser userById(String id) =>
      users.firstWhere((user) => user.id == id, orElse: () => users.first);

  Future<void> loginAs(AppUser user) async {
    currentUser = user;
    await persist();
  }

  Future<void> logout() async {
    currentUser = null;
    await persist();
  }
}

class AuthService {
  Future<String?> patientOtpLogin(
    DoctorMitraStore store, {
    required String mobile,
    required String otp,
  }) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'auth.patientOtpLogin',
        {'mobile': mobile, 'otp': otp},
        updateCurrentUser: true,
      );
      if (error == null) return null;
      if (error != 'Internet API unavailable') return error;
    }
    if (otp != '123456') return 'Use demo OTP 123456';
    final normalized = mobile.replaceAll(RegExp(r'\D'), '');
    if (normalized.length != 10) return 'Enter a valid 10 digit mobile number';
    var user = store.users
        .where((item) => item.role == 'patient' && item.mobile == normalized)
        .firstOrNull;
    if (user == null) {
      user = AppUser(
        id: _uuid.v4(),
        role: 'patient',
        name: 'Patient $normalized',
        mobile: normalized,
        email: '',
        district: 'Patna',
        createdAt: DateTime.now().toIso8601String(),
      );
      store.users.add(user);
      store.healthCards.add(
        HealthCard(
          id: _uuid.v4(),
          userId: user.id,
          bloodGroup: 'Not set',
          allergies: 'Not set',
          medications: 'Not set',
          emergencyContact: normalized,
        ),
      );
    }
    await store.loginAs(user);
    return null;
  }

  Future<String?> adminLogin(
    DoctorMitraStore store, {
    required String email,
    required String password,
  }) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'auth.adminLogin',
        {'email': email, 'password': password},
        updateCurrentUser: true,
      );
      if (error == null) return null;
      if (error != 'Internet API unavailable') return error;
    }
    final user = store.users
        .where((item) =>
            item.role == 'admin' &&
            item.email.toLowerCase() == email.toLowerCase().trim() &&
            item.password == password)
        .firstOrNull;
    if (user == null) return 'Invalid admin credentials';
    await store.loginAs(user);
    return null;
  }

  Future<String?> doctorLogin(
    DoctorMitraStore store, {
    required String email,
    required String password,
  }) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'auth.doctorLogin',
        {'email': email, 'password': password},
        updateCurrentUser: true,
      );
      if (error == null) return null;
      if (error != 'Internet API unavailable') return error;
    }
    final user = store.users
        .where((item) =>
            item.role == 'doctor' &&
            item.email.toLowerCase() == email.toLowerCase().trim() &&
            item.password == password)
        .firstOrNull;
    if (user == null) return 'Doctor account not found';
    final doctor = store.doctors.where((item) => item.userId == user.id).firstOrNull;
    if (doctor == null) return 'Doctor profile missing';
    if (doctor.status != 'approved') {
      return doctor.status == 'pending'
          ? 'Registration pending admin approval'
          : 'Registration rejected by admin';
    }
    await store.loginAs(user);
    return null;
  }

  Future<String?> registerDoctor(
    DoctorMitraStore store, {
    required String name,
    required String email,
    required String password,
    required String mobile,
    required String specialty,
    required String degree,
    required String registrationNumber,
    required String clinicName,
    required String district,
    required double fee,
  }) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'auth.registerDoctor',
        {
          'name': name,
          'email': email,
          'password': password,
          'mobile': mobile,
          'specialty': specialty,
          'degree': degree,
          'registrationNumber': registrationNumber,
          'clinicName': clinicName,
          'district': district,
          'fee': fee,
        },
      );
      if (error == null) return null;
      if (error != 'Internet API unavailable') return error;
    }
    if (store.users.any((user) => user.email.toLowerCase() == email.toLowerCase())) {
      return 'Email already registered';
    }
    final user = AppUser(
      id: _uuid.v4(),
      role: 'doctor',
      name: name.trim(),
      mobile: mobile.replaceAll(RegExp(r'\D'), ''),
      email: email.trim(),
      password: password,
      district: district.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );
    store.users.add(user);
    store.doctors.add(
      Doctor(
        id: _uuid.v4(),
        userId: user.id,
        name: name.trim(),
        specialty: specialty,
        degree: degree.trim(),
        experience: 1,
        registrationNumber: registrationNumber.trim(),
        clinicName: clinicName.trim(),
        address: '$clinicName, $district',
        district: district.trim(),
        fee: fee,
        onlineFee: fee * 0.7,
        rating: 4.5,
        reviews: 0,
        status: 'pending',
        isOnlineAvailable: true,
        slots: ['10:00', '11:00', '17:00'],
      ),
    );
    await store.persist();
    return null;
  }
}

class PatientService {
  List<Doctor> searchDoctors(DoctorMitraStore store, String query) {
    final normalized = query.toLowerCase().trim();
    return store.approvedDoctors.where((doctor) {
      return doctor.name.toLowerCase().contains(normalized) ||
          doctor.specialty.toLowerCase().contains(normalized) ||
          doctor.district.toLowerCase().contains(normalized);
    }).toList();
  }

  List<Booking> bookingsForPatient(DoctorMitraStore store, String patientId) =>
      store.bookings.where((booking) => booking.patientId == patientId).toList();

  Future<void> updateProfile(
    DoctorMitraStore store, {
    required String name,
    required String mobile,
    required String district,
  }) async {
    final current = store.currentUser;
    if (current == null) return;
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'patient.updateProfile',
        {
          'userId': current.id,
          'name': name,
          'mobile': mobile,
          'district': district,
        },
      );
      if (error == null) return;
    }
    final index = store.users.indexWhere((user) => user.id == current.id);
    if (index == -1) return;
    store.users[index] = current.copyWith(name: name, mobile: mobile, district: district);
    store.currentUser = store.users[index];
    await store.persist();
  }

  Future<void> updateHealthCard(
    DoctorMitraStore store, {
    required String bloodGroup,
    required String allergies,
    required String medications,
    required String emergencyContact,
  }) async {
    final user = store.currentUser;
    if (user == null) return;
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'patient.updateHealthCard',
        {
          'userId': user.id,
          'bloodGroup': bloodGroup,
          'allergies': allergies,
          'medications': medications,
          'emergencyContact': emergencyContact,
        },
      );
      if (error == null) return;
    }
    final card = HealthCard(
      id: store.currentHealthCard?.id ?? _uuid.v4(),
      userId: user.id,
      bloodGroup: bloodGroup,
      allergies: allergies,
      medications: medications,
      emergencyContact: emergencyContact,
    );
    final index = store.healthCards.indexWhere((item) => item.userId == user.id);
    if (index == -1) {
      store.healthCards.add(card);
    } else {
      store.healthCards[index] = card;
    }
    await store.persist();
  }
}

class DoctorService {
  List<Booking> appointmentsForDoctor(DoctorMitraStore store, String doctorId) =>
      store.bookings.where((booking) => booking.doctorId == doctorId).toList();

  List<AppUser> patientsForDoctor(DoctorMitraStore store, String doctorId) {
    final ids = appointmentsForDoctor(store, doctorId).map((e) => e.patientId).toSet();
    return store.users.where((user) => ids.contains(user.id)).toList();
  }

  Future<void> updateDoctor(
    DoctorMitraStore store,
    Doctor doctor,
  ) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'doctor.update',
        {'doctorId': doctor.id, ...doctor.toJson()},
      );
      if (error == null) return;
    }
    final index = store.doctors.indexWhere((item) => item.id == doctor.id);
    if (index == -1) return;
    store.doctors[index] = doctor;
    await store.persist();
  }

  Future<void> savePrescription(
    DoctorMitraStore store, {
    required Booking booking,
    required String diagnosis,
    required String medicines,
    required String advice,
  }) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'doctor.savePrescription',
        {
          'bookingId': booking.id,
          'diagnosis': diagnosis,
          'medicines': medicines,
          'advice': advice,
        },
      );
      if (error == null) return;
    }
    store.prescriptions.add(Prescription(
      id: _uuid.v4(),
      bookingId: booking.id,
      doctorId: booking.doctorId,
      patientId: booking.patientId,
      diagnosis: diagnosis,
      medicines: medicines,
      advice: advice,
      createdAt: DateTime.now().toIso8601String(),
    ));
    await store.bookingService.updateStatus(store, booking.id, 'completed');
  }
}

class AdminService {
  Future<void> approveDoctor(DoctorMitraStore store, String doctorId) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction('admin.approveDoctor', {'doctorId': doctorId});
      if (error == null) return;
    }
    final doctor = store.doctorById(doctorId).copyWith(status: 'approved');
    await store.doctorService.updateDoctor(store, doctor);
  }

  Future<void> rejectDoctor(DoctorMitraStore store, String doctorId) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction('admin.rejectDoctor', {'doctorId': doctorId});
      if (error == null) return;
    }
    final doctor = store.doctorById(doctorId).copyWith(status: 'rejected');
    await store.doctorService.updateDoctor(store, doctor);
  }

  Future<void> deleteDoctor(DoctorMitraStore store, String doctorId) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction('admin.deleteDoctor', {'doctorId': doctorId});
      if (error == null) return;
    }
    store.doctors.removeWhere((doctor) => doctor.id == doctorId);
    store.bookings.removeWhere((booking) => booking.doctorId == doctorId);
    await store.persist();
  }

  Future<void> addOrUpdateDoctor(DoctorMitraStore store, Doctor doctor) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction('admin.upsertDoctor', {'doctor': doctor.toJson()});
      if (error == null) return;
    }
    final index = store.doctors.indexWhere((item) => item.id == doctor.id);
    if (index == -1) {
      store.doctors.add(doctor);
    } else {
      store.doctors[index] = doctor;
    }
    await store.persist();
  }

  Future<void> addSpecialty(DoctorMitraStore store, String specialty) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction('admin.addSpecialty', {'specialty': specialty});
      if (error == null) return;
    }
    if (specialty.trim().isEmpty || store.specialties.contains(specialty.trim())) return;
    store.specialties.add(specialty.trim());
    await store.persist();
  }

  Future<void> addHealthTip(DoctorMitraStore store, String tip) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction('admin.addHealthTip', {'tip': tip});
      if (error == null) return;
    }
    if (tip.trim().isEmpty) return;
    store.healthTips.insert(0, tip.trim());
    await store.persist();
  }

  Future<void> setMaintenanceMode(DoctorMitraStore store, bool value) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction('admin.setMaintenanceMode', {'value': value});
      if (error == null) return;
    }
    store.maintenanceMode = value;
    await store.persist();
  }
}

class BookingService {
  Future<Booking> createBooking(
    DoctorMitraStore store, {
    required Doctor doctor,
    required String type,
    required String date,
    required String time,
    required String symptoms,
  }) async {
    final user = store.currentUser!;
    final fee = type == 'online' ? doctor.onlineFee : doctor.fee;
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'booking.create',
        {
          'patientId': user.id,
          'doctorId': doctor.id,
          'type': type,
          'date': date,
          'time': time,
          'symptoms': symptoms,
        },
      );
      if (error == null) {
        return store.bookings.firstWhere(
          (booking) =>
              booking.patientId == user.id &&
              booking.doctorId == doctor.id &&
              booking.date == date &&
              booking.time == time &&
              booking.type == type,
        );
      }
    }
    final booking = Booking(
      id: _uuid.v4(),
      patientId: user.id,
      doctorId: doctor.id,
      patientName: user.name,
      patientMobile: user.mobile,
      type: type,
      date: date,
      time: time,
      symptoms: symptoms,
      fee: fee,
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
    );
    store.bookings.insert(0, booking);
    store.notifications.add(AppNotification(
      id: _uuid.v4(),
      userId: doctor.userId,
      title: 'New appointment',
      body: '${user.name} booked ${doctor.name} for $date at $time',
      createdAt: DateTime.now().toIso8601String(),
    ));
    await store.persist();
    return booking;
  }

  Future<void> updateStatus(
    DoctorMitraStore store,
    String bookingId,
    String status,
  ) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'booking.updateStatus',
        {'bookingId': bookingId, 'status': status},
      );
      if (error == null) return;
    }
    final index = store.bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) return;
    final booking = store.bookings[index].copyWith(status: status);
    store.bookings[index] = booking;
    store.notifications.add(AppNotification(
      id: _uuid.v4(),
      userId: booking.patientId,
      title: 'Booking ${status.toUpperCase()}',
      body: 'Your appointment status is now $status.',
      createdAt: DateTime.now().toIso8601String(),
    ));
    await store.persist();
  }
}

class SlotService {
  Future<void> addSlot(DoctorMitraStore store, Doctor doctor, String slot) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'slot.add',
        {'doctorId': doctor.id, 'slot': slot},
      );
      if (error == null) return;
    }
    if (slot.trim().isEmpty || doctor.slots.contains(slot.trim())) return;
    await store.doctorService.updateDoctor(
      store,
      doctor.copyWith(slots: [...doctor.slots, slot.trim()]..sort()),
    );
  }

  Future<void> removeSlot(DoctorMitraStore store, Doctor doctor, String slot) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'slot.remove',
        {'doctorId': doctor.id, 'slot': slot},
      );
      if (error == null) return;
    }
    await store.doctorService.updateDoctor(
      store,
      doctor.copyWith(slots: doctor.slots.where((item) => item != slot).toList()),
    );
  }
}

class HospitalService {
  Future<void> addHospital(DoctorMitraStore store, Hospital hospital) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction('hospital.add', hospital.toJson());
      if (error == null) return;
    }
    store.hospitals.add(hospital);
    await store.persist();
  }

  Future<void> deleteHospital(DoctorMitraStore store, String id) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction('hospital.delete', {'id': id});
      if (error == null) return;
    }
    store.hospitals.removeWhere((hospital) => hospital.id == id);
    await store.persist();
  }
}

class AmbulanceService {
  Future<void> callProvider(AmbulanceProviderModel provider) async {
    final uri = Uri.parse('tel:${provider.phone}');
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch dialer');
    }
  }

  Future<void> addAmbulance(DoctorMitraStore store, AmbulanceProviderModel ambulance) async {
    if (store.isInternetConnected) {
      final error = await store.runRemoteAction('ambulance.add', ambulance.toJson());
      if (error != null) return;
    } else {
      final index = store.ambulances.indexWhere((item) => item.id == ambulance.id);
      if (index == -1) {
        store.ambulances.insert(0, ambulance);
      } else {
        store.ambulances[index] = ambulance;
      }
      await store.persist();
    }
  }

  Future<void> deleteAmbulance(DoctorMitraStore store, String id) async {
    if (store.isInternetConnected) {
      final error = await store.runRemoteAction('ambulance.delete', {'id': id});
      if (error != null) return;
    }
    store.ambulances.removeWhere((ambulance) => ambulance.id == id);
    await store.persist();
  }
}

class NotificationService {
  List<AppNotification> forUser(DoctorMitraStore store, String userId) =>
      store.notifications.where((item) => item.userId == userId).toList();
}

class DoctorMitraRoleApp extends StatelessWidget {
  const DoctorMitraRoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DoctorMitraStore()..load(),
      child: MaterialApp(
        title: 'Doctor Mitra',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.green,
            primary: AppColors.green,
            secondary: AppColors.mint,
            surface: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        home: const AppGate(),
      ),
    );
  }
}

class AppColors {
  static const green = Color(0xFF087A55);
  static const deepGreen = Color(0xFF055A42);
  static const mint = Color(0xFFE6F7F0);
  static const bg = Color(0xFFF4FBF7);
  static const ink = Color(0xFF17201B);
  static const muted = Color(0xFF6C7A73);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFE5484D);
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    if (store.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final user = store.currentUser;
    if (user == null) return const SplashRoleScreen();
    return switch (user.role) {
      'doctor' => const DoctorShell(),
      'admin' => const AdminShell(),
      _ => const PatientShell(),
    };
  }
}

class SplashRoleScreen extends StatefulWidget {
  const SplashRoleScreen({super.key});

  @override
  State<SplashRoleScreen> createState() => _SplashRoleScreenState();
}

class _SplashRoleScreenState extends State<SplashRoleScreen> {
  bool showRoles = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => showRoles = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: showRoles ? const RoleSelectionScreen() : const BrandSplash(),
      ),
    );
  }
}

class BrandSplash extends StatelessWidget {
  const BrandSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.green, Color(0xFF0E9F76)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: Colors.white,
              child: Icon(Icons.health_and_safety, color: AppColors.green, size: 48),
            ),
            SizedBox(height: 22),
            Text(
              'Doctor Mitra',
              style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              'One connected healthcare platform',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const PremiumHeader(
              title: 'Welcome to Doctor Mitra',
              subtitle: 'Choose your panel. Same app, same connected data.',
              icon: Icons.local_hospital,
            ),
            const SizedBox(height: 18),
            RoleCard(
              title: 'Patient Login',
              subtitle: 'Book doctors, manage health card and consultations.',
              icon: Icons.person_search,
              onTap: () => push(context, const PatientOtpLoginScreen()),
            ),
            RoleCard(
              title: 'Doctor Login',
              subtitle: 'Appointments, slots, prescriptions and earnings.',
              icon: Icons.medical_information,
              onTap: () => push(context, const DoctorAuthScreen()),
            ),
            RoleCard(
              title: 'Admin Login',
              subtitle: 'Doctors, bookings, hospitals, reports and settings.',
              icon: Icons.admin_panel_settings,
              onTap: () => push(context, const AdminLoginScreen()),
            ),
            const SizedBox(height: 18),
            const InfoStrip(
              icon: Icons.lock,
              text: 'Demo OTP: 123456  •  Admin: admin@doctormitra.in / Rakesh@12032',
            ),
          ],
        ),
      ),
    );
  }
}

class PatientOtpLoginScreen extends StatefulWidget {
  const PatientOtpLoginScreen({super.key});

  @override
  State<PatientOtpLoginScreen> createState() => _PatientOtpLoginScreenState();
}

class _PatientOtpLoginScreenState extends State<PatientOtpLoginScreen> {
  final mobile = TextEditingController(text: '9876543210');
  final otp = TextEditingController(text: '123456');
  String? error;

  @override
  void dispose() {
    mobile.dispose();
    otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginScaffold(
      title: 'Patient OTP Login',
      subtitle: 'Patients use a fast OTP flow. Demo OTP is 123456.',
      icon: Icons.phone_android,
      children: [
        AppField(controller: mobile, label: 'Mobile number', icon: Icons.phone),
        AppField(controller: otp, label: 'OTP', icon: Icons.password),
        if (error != null) ErrorText(error!),
        PrimaryAction(
          label: 'Verify and continue',
          icon: Icons.verified,
          onPressed: () async {
            final store = context.read<DoctorMitraStore>();
            final result = await store.authService.patientOtpLogin(
              store,
              mobile: mobile.text,
              otp: otp.text,
            );
            if (!mounted) return;
            if (result != null) setState(() => error = result);
          },
        ),
      ],
    );
  }
}

class DoctorAuthScreen extends StatefulWidget {
  const DoctorAuthScreen({super.key});

  @override
  State<DoctorAuthScreen> createState() => _DoctorAuthScreenState();
}

class _DoctorAuthScreenState extends State<DoctorAuthScreen> {
  bool register = false;
  final email = TextEditingController(text: 'rajeev@doctormitra.in');
  final password = TextEditingController(text: 'doctor123');
  final name = TextEditingController(text: 'Dr. New Doctor');
  final mobile = TextEditingController(text: '9000000099');
  final degree = TextEditingController(text: 'MBBS');
  final regNo = TextEditingController(text: 'BRMC-NEW-01');
  final clinic = TextEditingController(text: 'New Care Clinic');
  final district = TextEditingController(text: 'Patna');
  final fee = TextEditingController(text: '500');
  String specialty = 'General Physician';
  String? message;

  @override
  void dispose() {
    for (final controller in [
      email,
      password,
      name,
      mobile,
      degree,
      regNo,
      clinic,
      district,
      fee,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    return LoginScaffold(
      title: register ? 'Doctor Registration' : 'Doctor Login',
      subtitle: register
          ? 'New doctors join as pending until admin approval.'
          : 'Approved doctors can access their connected dashboard.',
      icon: Icons.medical_services,
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Login'), icon: Icon(Icons.login)),
            ButtonSegment(value: true, label: Text('Register'), icon: Icon(Icons.app_registration)),
          ],
          selected: {register},
          onSelectionChanged: (value) => setState(() {
            register = value.first;
            message = null;
          }),
        ),
        const SizedBox(height: 14),
        if (register) ...[
          AppField(controller: name, label: 'Doctor name', icon: Icons.person),
          AppField(controller: mobile, label: 'Mobile', icon: Icons.phone),
          DropdownButtonFormField<String>(
            value: specialty,
            items: store.specialties
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => specialty = value ?? specialty),
            decoration: inputDecoration('Specialty', Icons.category),
          ),
          AppField(controller: degree, label: 'Degree', icon: Icons.school),
          AppField(controller: regNo, label: 'Registration number', icon: Icons.badge),
          AppField(controller: clinic, label: 'Clinic name', icon: Icons.business),
          AppField(controller: district, label: 'District', icon: Icons.location_on),
          AppField(controller: fee, label: 'Clinic fee', icon: Icons.currency_rupee),
        ],
        AppField(controller: email, label: 'Email', icon: Icons.email),
        AppField(controller: password, label: 'Password', icon: Icons.lock, obscure: true),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              message!,
              style: TextStyle(
                color: message!.contains('submitted') ? AppColors.green : AppColors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        PrimaryAction(
          label: register ? 'Submit for approval' : 'Enter doctor panel',
          icon: register ? Icons.outbox : Icons.dashboard,
          onPressed: () async {
            final store = context.read<DoctorMitraStore>();
            final result = register
                ? await store.authService.registerDoctor(
                    store,
                    name: name.text,
                    email: email.text,
                    password: password.text,
                    mobile: mobile.text,
                    specialty: specialty,
                    degree: degree.text,
                    registrationNumber: regNo.text,
                    clinicName: clinic.text,
                    district: district.text,
                    fee: double.tryParse(fee.text) ?? 500,
                  )
                : await store.authService.doctorLogin(
                    store,
                    email: email.text,
                    password: password.text,
                  );
            if (!mounted) return;
            setState(() {
              message = result ?? (register ? 'Registration submitted. Admin approval required.' : null);
            });
          },
        ),
      ],
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final email = TextEditingController(text: 'admin@doctormitra.in');
  final password = TextEditingController(text: 'Rakesh@12032');
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginScaffold(
      title: 'Admin Login',
      subtitle: 'Operations dashboard for Doctor Mitra.',
      icon: Icons.admin_panel_settings,
      children: [
        AppField(controller: email, label: 'Mobile or email', icon: Icons.email),
        AppField(controller: password, label: 'Password', icon: Icons.lock, obscure: true),
        if (error != null) ErrorText(error!),
        PrimaryAction(
          label: 'Enter admin panel',
          icon: Icons.analytics,
          onPressed: () async {
            final store = context.read<DoctorMitraStore>();
            final result = await store.authService.adminLogin(
              store,
              email: email.text,
              password: password.text,
            );
            if (!mounted) return;
            if (result != null) setState(() => error = result);
          },
        ),
      ],
    );
  }
}

class PatientShell extends StatefulWidget {
  const PatientShell({super.key});

  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const PatientHomeScreen(),
      const PatientDoctorsScreen(),
      const PatientBookingsScreen(),
      const PatientHealthCardScreen(),
      const PatientProfileScreen(),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavBar(
        index: index,
        onTap: (value) => setState(() => index = value),
        items: const [
          NavItem(Icons.home_rounded, 'Home'),
          NavItem(Icons.groups_rounded, 'Doctors'),
          NavItem(Icons.calendar_month_rounded, 'Bookings'),
          NavItem(Icons.credit_card_rounded, 'Health Card'),
          NavItem(Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }
}

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    return AppPage(
      title: 'Doctor Mitra',
      subtitle: 'Bihar ka apna doctor platform',
      actions: [
        IconButton(
          onPressed: () => showSyncSheet(context),
          icon: Icon(store.isInternetConnected ? Icons.cloud_done : Icons.cloud_off),
        ),
        IconButton(
          onPressed: () => showNotifications(context),
          icon: const Icon(Icons.notifications_none),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          HeroSearchCard(
            onTap: () => push(context, const PatientDoctorsScreen(showBack: true)),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: MetricTile('Doctors', '${store.approvedDoctors.length}+', Icons.medical_services)),
              Expanded(child: MetricTile('Districts', '${store.doctors.map((e) => e.district).toSet().length}', Icons.location_on)),
              const Expanded(child: MetricTile('Booking', 'Free', Icons.verified)),
            ],
          ),
          const SizedBox(height: 18),
          QuickGrid(
            items: [
              QuickItem(Icons.person_search, 'Find Doctor', () => push(context, const PatientDoctorsScreen(showBack: true))),
              QuickItem(Icons.video_call, 'Online Consult', () => push(context, const PatientDoctorsScreen(showBack: true, onlineOnly: true))),
              QuickItem(Icons.credit_card, 'Health Card', () => push(context, const PatientHealthCardScreen(showBack: true))),
              QuickItem(Icons.local_hospital, 'Hospitals', () => push(context, const HospitalsPatientScreen())),
              QuickItem(Icons.emergency, 'Ambulance', () => push(context, const AmbulancePatientScreen())),
              QuickItem(Icons.lightbulb, 'Health Tips', () => showTips(context)),
            ],
          ),
          SectionTitle('Top doctors', action: 'See all', onTap: () => push(context, const PatientDoctorsScreen(showBack: true))),
          ...store.approvedDoctors.take(3).map((doctor) => DoctorCardMvp(doctor: doctor)),
          const SectionTitle('Hospitals near you'),
          ...store.hospitals.take(2).map((hospital) => HospitalCard(hospital: hospital)),
        ],
      ),
    );
  }
}

class PatientDoctorsScreen extends StatefulWidget {
  final bool showBack;
  final bool onlineOnly;

  const PatientDoctorsScreen({
    super.key,
    this.showBack = false,
    this.onlineOnly = false,
  });

  @override
  State<PatientDoctorsScreen> createState() => _PatientDoctorsScreenState();
}

class _PatientDoctorsScreenState extends State<PatientDoctorsScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final doctors = store.patientService.searchDoctors(store, query).where((doctor) {
      return !widget.onlineOnly || doctor.isOnlineAvailable;
    }).toList();
    return AppPage(
      title: widget.onlineOnly ? 'Online Doctors' : 'Doctors',
      subtitle: 'Search approved doctors, fees and available slots.',
      showBack: widget.showBack,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: inputDecoration('Search doctor, specialty, district', Icons.search),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              itemCount: doctors.length,
              itemBuilder: (_, i) => DoctorCardMvp(
                doctor: doctors[i],
                onTap: () => push(context, DoctorProfileMvpScreen(doctor: doctors[i])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorProfileMvpScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorProfileMvpScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Doctor Profile',
      subtitle: doctor.specialty,
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          BigDoctorHeader(doctor: doctor),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: MetricTile('Experience', '${doctor.experience} yrs', Icons.work)),
              Expanded(child: MetricTile('Rating', doctor.rating.toStringAsFixed(1), Icons.star)),
              Expanded(child: MetricTile('Clinic fee', '₹${doctor.fee.toStringAsFixed(0)}', Icons.currency_rupee)),
            ],
          ),
          const SizedBox(height: 16),
          InfoStrip(icon: Icons.location_on, text: '${doctor.clinicName}, ${doctor.address}'),
          InfoStrip(icon: Icons.badge, text: 'Registration: ${doctor.registrationNumber}'),
          const SizedBox(height: 16),
          PrimaryAction(
            label: 'Book clinic appointment',
            icon: Icons.event_available,
            onPressed: () => push(context, BookingCreateScreen(doctor: doctor, type: 'clinic')),
          ),
          if (doctor.isOnlineAvailable)
            SecondaryAction(
              label: 'Book online consultation',
              icon: Icons.video_call,
              onPressed: () => push(context, BookingCreateScreen(doctor: doctor, type: 'online')),
            ),
        ],
      ),
    );
  }
}

class BookingCreateScreen extends StatefulWidget {
  final Doctor doctor;
  final String type;

  const BookingCreateScreen({super.key, required this.doctor, required this.type});

  @override
  State<BookingCreateScreen> createState() => _BookingCreateScreenState();
}

class _BookingCreateScreenState extends State<BookingCreateScreen> {
  late String slot = widget.doctor.slots.first;
  final symptoms = TextEditingController();
  late String date = DateFormat('dd MMM yyyy').format(DateTime.now());

  @override
  void dispose() {
    symptoms.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fee = widget.type == 'online' ? widget.doctor.onlineFee : widget.doctor.fee;
    return AppPage(
      title: 'Confirm booking',
      subtitle: widget.doctor.name,
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          DoctorCardMvp(doctor: widget.doctor),
          const SizedBox(height: 16),
          Text('Consultation type', style: sectionStyle),
          const SizedBox(height: 8),
          StatusChip(widget.type == 'online' ? 'Online consultation' : 'Clinic visit', AppColors.green),
          const SizedBox(height: 16),
          Text('Choose date', style: sectionStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(5, (i) {
              final value = DateFormat('dd MMM yyyy').format(DateTime.now().add(Duration(days: i)));
              return ChoiceChip(
                label: Text(i == 0 ? 'Today' : DateFormat('dd MMM').format(DateTime.now().add(Duration(days: i)))),
                selected: date == value,
                onSelected: (_) => setState(() => date = value),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text('Available slots', style: sectionStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.doctor.slots
                .map((item) => ChoiceChip(
                      label: Text(item),
                      selected: slot == item,
                      onSelected: (_) => setState(() => slot = item),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          AppField(controller: symptoms, label: 'Symptoms or problem', icon: Icons.notes, maxLines: 3),
          BillCard(rows: [
            ('Doctor fee', '₹${fee.toStringAsFixed(0)}'),
            ('Platform fee', 'FREE'),
            ('Total', '₹${fee.toStringAsFixed(0)}'),
          ]),
          PrimaryAction(
            label: 'Confirm appointment',
            icon: Icons.verified,
            onPressed: () async {
              final store = context.read<DoctorMitraStore>();
              final booking = await store.bookingService.createBooking(
                store,
                doctor: widget.doctor,
                type: widget.type,
                date: date,
                time: slot,
                symptoms: symptoms.text.trim().isEmpty ? 'General consultation' : symptoms.text.trim(),
              );
              if (!context.mounted) return;
              showSuccess(context, 'Booking created', 'Status is pending. Doctor and admin can see it now.');
              pushReplacement(context, BookingReceiptScreen(booking: booking));
            },
          ),
        ],
      ),
    );
  }
}

class BookingReceiptScreen extends StatelessWidget {
  final Booking booking;

  const BookingReceiptScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final doctor = store.doctorById(booking.doctorId);
    return AppPage(
      title: 'Booking confirmed',
      subtitle: 'Shared across patient, doctor and admin panels.',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Icon(Icons.check_circle, color: AppColors.green, size: 84),
          const SizedBox(height: 12),
          Center(child: Text('Appointment saved', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
          const SizedBox(height: 18),
          BookingCard(booking: booking, doctor: doctor),
          PrimaryAction(
            label: 'Go to my bookings',
            icon: Icons.calendar_month,
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const PatientShell()),
              (_) => false,
            ),
          ),
        ],
      ),
    );
  }
}

class PatientBookingsScreen extends StatelessWidget {
  const PatientBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final user = store.currentUser!;
    final bookings = store.patientService.bookingsForPatient(store, user.id);
    return AppPage(
      title: 'My Bookings',
      subtitle: 'Live status from doctor and admin actions.',
      child: bookings.isEmpty
          ? const EmptyState(icon: Icons.calendar_month, title: 'No bookings yet', text: 'Book a doctor to see it here.')
          : ListView(
              padding: const EdgeInsets.all(18),
              children: bookings
                  .map((booking) => BookingCard(
                        booking: booking,
                        doctor: store.doctorById(booking.doctorId),
                        actions: booking.status == 'pending' || booking.status == 'accepted'
                            ? [
                                TextButton.icon(
                                  onPressed: () => store.bookingService.updateStatus(store, booking.id, 'cancelled'),
                                  icon: const Icon(Icons.cancel, color: AppColors.red),
                                  label: const Text('Cancel', style: TextStyle(color: AppColors.red)),
                                ),
                              ]
                            : [],
                      ))
                  .toList(),
            ),
    );
  }
}

class PatientHealthCardScreen extends StatefulWidget {
  final bool showBack;
  const PatientHealthCardScreen({super.key, this.showBack = false});

  @override
  State<PatientHealthCardScreen> createState() => _PatientHealthCardScreenState();
}

class _PatientHealthCardScreenState extends State<PatientHealthCardScreen> {
  final blood = TextEditingController();
  final allergies = TextEditingController();
  final meds = TextEditingController();
  final emergency = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final card = context.read<DoctorMitraStore>().currentHealthCard;
    blood.text = card?.bloodGroup ?? '';
    allergies.text = card?.allergies ?? '';
    meds.text = card?.medications ?? '';
    emergency.text = card?.emergencyContact ?? '';
  }

  @override
  void dispose() {
    blood.dispose();
    allergies.dispose();
    meds.dispose();
    emergency.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<DoctorMitraStore>().currentUser!;
    return AppPage(
      title: 'Health Card',
      subtitle: 'Portable emergency medical profile.',
      showBack: widget.showBack,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF10A37F)]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('DOCTOR MITRA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    Icon(Icons.health_and_safety, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 24),
                Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                Text('ID: DM-${user.id.substring(0, 6).toUpperCase()}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: CardMini(label: 'Blood', value: blood.text.isEmpty ? 'Not set' : blood.text)),
                    Expanded(child: CardMini(label: 'Emergency', value: emergency.text.isEmpty ? 'Not set' : emergency.text)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppField(controller: blood, label: 'Blood group', icon: Icons.bloodtype),
          AppField(controller: allergies, label: 'Known allergies', icon: Icons.warning, maxLines: 2),
          AppField(controller: meds, label: 'Current medications', icon: Icons.medication, maxLines: 2),
          AppField(controller: emergency, label: 'Emergency contact', icon: Icons.phone),
          PrimaryAction(
            label: 'Save health card',
            icon: Icons.save,
            onPressed: () {
              context.read<DoctorMitraStore>().patientService.updateHealthCard(
                    context.read<DoctorMitraStore>(),
                    bloodGroup: blood.text,
                    allergies: allergies.text,
                    medications: meds.text,
                    emergencyContact: emergency.text,
                  );
              showSuccess(context, 'Saved', 'Health card updated.');
            },
          ),
        ],
      ),
    );
  }
}

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final user = store.currentUser!;
    return AppPage(
      title: 'Profile',
      subtitle: 'Patient account and saved data.',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ProfileHero(name: user.name, subtitle: '+91 ${user.mobile}', icon: Icons.person),
          ActionTile(icon: Icons.edit, title: 'Edit profile', subtitle: user.district, onTap: () => showPatientProfileEditor(context)),
          ActionTile(icon: Icons.health_and_safety, title: 'Health card', subtitle: 'Emergency profile', onTap: () => push(context, const PatientHealthCardScreen(showBack: true))),
          ActionTile(icon: Icons.notifications, title: 'Notifications', subtitle: '${store.notificationService.forUser(store, user.id).length} updates', onTap: () => showNotifications(context)),
          ActionTile(icon: Icons.logout, title: 'Logout', subtitle: 'Return to role selection', danger: true, onTap: () => store.logout()),
        ],
      ),
    );
  }
}

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DoctorDashboardScreen(),
      const DoctorAppointmentsScreen(),
      const DoctorSlotsScreen(),
      const DoctorPatientsScreen(),
      const DoctorProfileScreenMvp(),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavBar(
        index: index,
        onTap: (value) => setState(() => index = value),
        items: const [
          NavItem(Icons.dashboard, 'Dashboard'),
          NavItem(Icons.event_note, 'Appointments'),
          NavItem(Icons.schedule, 'Slots'),
          NavItem(Icons.group, 'Patients'),
          NavItem(Icons.person, 'Profile'),
        ],
      ),
    );
  }
}

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final doctor = store.currentDoctor!;
    final appointments = store.doctorService.appointmentsForDoctor(store, doctor.id);
    final pending = appointments.where((item) => item.status == 'pending').length;
    final accepted = appointments.where((item) => item.status == 'accepted').length;
    final revenue = appointments
        .where((item) => item.status != 'cancelled' && item.status != 'rejected')
        .fold<double>(0, (sum, item) => sum + item.fee);
    return AppPage(
      title: 'Doctor Dashboard',
      subtitle: doctor.name,
      actions: [
        IconButton(
          onPressed: () => showSyncSheet(context),
          icon: Icon(store.isInternetConnected ? Icons.cloud_done : Icons.cloud_off),
        ),
        IconButton(onPressed: () => showNotifications(context), icon: const Icon(Icons.notifications_none)),
      ],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          BigDoctorHeader(doctor: doctor),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: MetricTile('Today', '${appointments.length}', Icons.today)),
              Expanded(child: MetricTile('Pending', '$pending', Icons.pending_actions)),
              Expanded(child: MetricTile('Earnings', '₹${revenue.toStringAsFixed(0)}', Icons.account_balance_wallet)),
            ],
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Row(
              children: [
                const Icon(Icons.video_camera_front, color: AppColors.green),
                const SizedBox(width: 12),
                const Expanded(child: Text('Online consultation availability', style: TextStyle(fontWeight: FontWeight.w700))),
                Switch(
                  value: doctor.isOnlineAvailable,
                  onChanged: (value) => store.doctorService.updateDoctor(
                    store,
                    doctor.copyWith(isOnlineAvailable: value),
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle('Appointment summary'),
          MiniBarChart(values: {
            'Pending': pending.toDouble(),
            'Accepted': accepted.toDouble(),
            'Done': appointments.where((item) => item.status == 'completed').length.toDouble(),
          }),
          const SectionTitle('Next appointments'),
          ...appointments.take(4).map((booking) => BookingCard(
                booking: booking,
                doctor: doctor,
                showPatient: true,
                actions: doctorBookingActions(context, booking),
              )),
        ],
      ),
    );
  }
}

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final doctor = store.currentDoctor!;
    final appointments = store.doctorService.appointmentsForDoctor(store, doctor.id);
    return AppPage(
      title: 'Appointments',
      subtitle: 'Accept, reject, cancel or complete bookings.',
      child: appointments.isEmpty
          ? const EmptyState(icon: Icons.event_busy, title: 'No appointments', text: 'Patient bookings will appear here instantly.')
          : ListView(
              padding: const EdgeInsets.all(18),
              children: appointments
                  .map((booking) => BookingCard(
                        booking: booking,
                        doctor: doctor,
                        showPatient: true,
                        actions: doctorBookingActions(context, booking),
                      ))
                  .toList(),
            ),
    );
  }
}

class DoctorSlotsScreen extends StatefulWidget {
  const DoctorSlotsScreen({super.key});

  @override
  State<DoctorSlotsScreen> createState() => _DoctorSlotsScreenState();
}

class _DoctorSlotsScreenState extends State<DoctorSlotsScreen> {
  final slot = TextEditingController(text: '18:30');

  @override
  void dispose() {
    slot.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final doctor = store.currentDoctor!;
    return AppPage(
      title: 'Slot Management',
      subtitle: 'Changes update patient booking screens immediately.',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active slots', style: sectionStyle),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: doctor.slots
                      .map((item) => InputChip(
                            label: Text(item),
                            onDeleted: () => store.slotService.removeSlot(store, doctor, item),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          AppField(controller: slot, label: 'Add slot, e.g. 18:30', icon: Icons.schedule),
          PrimaryAction(
            label: 'Add slot',
            icon: Icons.add,
            onPressed: () => store.slotService.addSlot(store, doctor, slot.text),
          ),
        ],
      ),
    );
  }
}

class DoctorPatientsScreen extends StatelessWidget {
  const DoctorPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final doctor = store.currentDoctor!;
    final patients = store.doctorService.patientsForDoctor(store, doctor.id);
    return AppPage(
      title: 'Patients',
      subtitle: 'Patient history and prescriptions.',
      child: patients.isEmpty
          ? const EmptyState(icon: Icons.group_off, title: 'No patient history', text: 'Accepted and completed bookings create history.')
          : ListView(
              padding: const EdgeInsets.all(18),
              children: patients.map((patient) {
                final patientBookings = store.bookings
                    .where((booking) => booking.patientId == patient.id && booking.doctorId == doctor.id)
                    .toList();
                return PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(backgroundColor: AppColors.mint, child: Icon(Icons.person, color: AppColors.green)),
                        title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('+91 ${patient.mobile} • ${patientBookings.length} visits'),
                      ),
                      ...patientBookings.take(2).map((booking) => Text('• ${booking.date} ${booking.time} - ${booking.status}')),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class DoctorProfileScreenMvp extends StatefulWidget {
  const DoctorProfileScreenMvp({super.key});

  @override
  State<DoctorProfileScreenMvp> createState() => _DoctorProfileScreenMvpState();
}

class _DoctorProfileScreenMvpState extends State<DoctorProfileScreenMvp> {
  final fee = TextEditingController();
  final onlineFee = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final doctor = context.read<DoctorMitraStore>().currentDoctor!;
    fee.text = doctor.fee.toStringAsFixed(0);
    onlineFee.text = doctor.onlineFee.toStringAsFixed(0);
  }

  @override
  void dispose() {
    fee.dispose();
    onlineFee.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final doctor = store.currentDoctor!;
    return AppPage(
      title: 'Doctor Profile',
      subtitle: 'Manage fees and availability.',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          BigDoctorHeader(doctor: doctor),
          AppField(controller: fee, label: 'Clinic fee', icon: Icons.currency_rupee),
          AppField(controller: onlineFee, label: 'Online fee', icon: Icons.video_call),
          PrimaryAction(
            label: 'Update fees',
            icon: Icons.save,
            onPressed: () {
              store.doctorService.updateDoctor(
                store,
                doctor.copyWith(
                  fee: double.tryParse(fee.text) ?? doctor.fee,
                  onlineFee: double.tryParse(onlineFee.text) ?? doctor.onlineFee,
                ),
              );
              showSuccess(context, 'Updated', 'Patient side will show the new fee.');
            },
          ),
          ActionTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Return to role selection',
            danger: true,
            onTap: () => store.logout(),
          ),
        ],
      ),
    );
  }
}

List<Widget> doctorBookingActions(BuildContext context, Booking booking) {
  final store = context.read<DoctorMitraStore>();
  if (booking.status == 'pending') {
    return [
      TextButton.icon(
        onPressed: () => store.bookingService.updateStatus(store, booking.id, 'accepted'),
        icon: const Icon(Icons.check_circle, color: AppColors.green),
        label: const Text('Accept'),
      ),
      TextButton.icon(
        onPressed: () => store.bookingService.updateStatus(store, booking.id, 'rejected'),
        icon: const Icon(Icons.cancel, color: AppColors.red),
        label: const Text('Reject', style: TextStyle(color: AppColors.red)),
      ),
    ];
  }
  if (booking.status == 'accepted') {
    return [
      TextButton.icon(
        onPressed: () => push(context, PrescriptionScreen(booking: booking)),
        icon: const Icon(Icons.edit_note, color: AppColors.green),
        label: const Text('Prescription'),
      ),
      TextButton.icon(
        onPressed: () => store.bookingService.updateStatus(store, booking.id, 'cancelled'),
        icon: const Icon(Icons.cancel, color: AppColors.red),
        label: const Text('Cancel', style: TextStyle(color: AppColors.red)),
      ),
    ];
  }
  return [];
}

class PrescriptionScreen extends StatefulWidget {
  final Booking booking;

  const PrescriptionScreen({super.key, required this.booking});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final diagnosis = TextEditingController(text: 'Viral fever');
  final medicines = TextEditingController(text: 'Paracetamol 500mg twice daily for 3 days');
  final advice = TextEditingController(text: 'Hydration, rest, follow-up if fever persists.');

  @override
  void dispose() {
    diagnosis.dispose();
    medicines.dispose();
    advice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Write Prescription',
      subtitle: widget.booking.patientName,
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AppField(controller: diagnosis, label: 'Diagnosis', icon: Icons.medical_information, maxLines: 2),
          AppField(controller: medicines, label: 'Medicines', icon: Icons.medication, maxLines: 4),
          AppField(controller: advice, label: 'Advice', icon: Icons.fact_check, maxLines: 3),
          PrimaryAction(
            label: 'Save prescription and complete',
            icon: Icons.check_circle,
            onPressed: () async {
              final store = context.read<DoctorMitraStore>();
              await store.doctorService.savePrescription(
                store,
                booking: widget.booking,
                diagnosis: diagnosis.text,
                medicines: medicines.text,
                advice: advice.text,
              );
              if (!context.mounted) return;
              showSuccess(context, 'Prescription saved', 'Booking marked completed.');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AdminDashboardScreen(),
      const AdminDoctorsScreen(),
      const AdminBookingsScreen(),
      const AdminHospitalsScreen(),
      const AdminSettingsScreen(),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavBar(
        index: index,
        onTap: (value) => setState(() => index = value),
        items: const [
          NavItem(Icons.analytics, 'Dashboard'),
          NavItem(Icons.medical_services, 'Doctors'),
          NavItem(Icons.event_note, 'Bookings'),
          NavItem(Icons.local_hospital, 'Hospitals'),
          NavItem(Icons.settings, 'Settings'),
        ],
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final revenue = store.bookings
        .where((item) => item.status != 'cancelled' && item.status != 'rejected')
        .fold<double>(0, (sum, item) => sum + item.fee);
    return AppPage(
      title: 'Admin Dashboard',
      subtitle: 'Connected operations overview.',
      actions: [
        IconButton(
          onPressed: () => showSyncSheet(context),
          icon: Icon(store.isInternetConnected ? Icons.cloud_done : Icons.cloud_off),
        ),
        IconButton(onPressed: () => store.logout(), icon: const Icon(Icons.logout)),
      ],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.45,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              AdminMetric('Doctors', '${store.doctors.length}', Icons.medical_services, AppColors.green),
              AdminMetric('Patients', '${store.patients.length}', Icons.groups, Colors.blue),
              AdminMetric('Bookings', '${store.bookings.length}', Icons.event_note, AppColors.amber),
              AdminMetric('Revenue', '₹${revenue.toStringAsFixed(0)}', Icons.currency_rupee, Colors.purple),
            ],
          ),
          const SectionTitle('Booking status chart'),
          MiniBarChart(values: {
            'Pending': store.bookings.where((e) => e.status == 'pending').length.toDouble(),
            'Accepted': store.bookings.where((e) => e.status == 'accepted').length.toDouble(),
            'Done': store.bookings.where((e) => e.status == 'completed').length.toDouble(),
            'Cancel': store.bookings.where((e) => e.status == 'cancelled').length.toDouble(),
          }),
          const SectionTitle('Pending doctor approvals'),
          if (store.pendingDoctors.isEmpty)
            const EmptyState(icon: Icons.verified_user, title: 'No pending doctors', text: 'New registrations will appear here.')
          else
            ...store.pendingDoctors.map((doctor) => AdminDoctorCard(doctor: doctor)),
          const SectionTitle('Patients table'),
          PremiumCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Mobile')),
                  DataColumn(label: Text('District')),
                ],
                rows: store.patients
                    .map((user) => DataRow(cells: [
                          DataCell(Text(user.name)),
                          DataCell(Text(user.mobile)),
                          DataCell(Text(user.district)),
                        ]))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminDoctorsScreen extends StatelessWidget {
  const AdminDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    return AppPage(
      title: 'Manage Doctors',
      subtitle: 'Approve, edit fees and remove doctors.',
      actions: [
        IconButton(onPressed: () => showAdminDoctorEditor(context), icon: const Icon(Icons.add)),
      ],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: store.doctors.map((doctor) => AdminDoctorCard(doctor: doctor)).toList(),
      ),
    );
  }
}

class AdminDoctorCard extends StatelessWidget {
  final Doctor doctor;

  const AdminDoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final store = context.read<DoctorMitraStore>();
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: DoctorAvatar(doctor: doctor),
            title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${doctor.specialty} • ₹${doctor.fee.toStringAsFixed(0)} • ${doctor.district}'),
            trailing: StatusChip(doctor.status, statusColor(doctor.status)),
          ),
          Wrap(
            spacing: 8,
            children: [
              if (doctor.status == 'pending')
                TextButton(onPressed: () => store.adminService.approveDoctor(store, doctor.id), child: const Text('Approve')),
              if (doctor.status == 'pending')
                TextButton(onPressed: () => store.adminService.rejectDoctor(store, doctor.id), child: const Text('Reject', style: TextStyle(color: AppColors.red))),
              TextButton(onPressed: () => showAdminDoctorEditor(context, doctor: doctor), child: const Text('Edit')),
              TextButton(onPressed: () => store.adminService.deleteDoctor(store, doctor.id), child: const Text('Delete', style: TextStyle(color: AppColors.red))),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    return AppPage(
      title: 'All Bookings',
      subtitle: 'Every patient booking is visible here.',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: store.bookings
            .map((booking) => BookingCard(
                  booking: booking,
                  doctor: store.doctorById(booking.doctorId),
                  showPatient: true,
                  actions: [
                    PopupMenuButton<String>(
                      onSelected: (status) => store.bookingService.updateStatus(store, booking.id, status),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'pending', child: Text('Pending')),
                        PopupMenuItem(value: 'accepted', child: Text('Accepted')),
                        PopupMenuItem(value: 'rejected', child: Text('Rejected')),
                        PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
                        PopupMenuItem(value: 'completed', child: Text('Completed')),
                      ],
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class AdminHospitalsScreen extends StatelessWidget {
  const AdminHospitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    return AppPage(
      title: 'Hospitals',
      subtitle: 'Add, view and remove hospital partners.',
      actions: [
        IconButton(onPressed: () => showHospitalEditor(context), icon: const Icon(Icons.add_business)),
      ],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: store.hospitals
            .map((hospital) => HospitalCard(
                  hospital: hospital,
                  trailing: IconButton(
                    onPressed: () => store.hospitalService.deleteHospital(store, hospital.id),
                    icon: const Icon(Icons.delete, color: AppColors.red),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    return AppPage(
      title: 'Settings & Reports',
      subtitle: 'Specialties, banners, health tips and ambulance reports.',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          PremiumCard(
            child: SwitchListTile(
              value: store.maintenanceMode,
              onChanged: (value) => store.adminService.setMaintenanceMode(store, value),
              title: const Text('Maintenance mode', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Backend-ready app setting stored locally.'),
            ),
          ),
          SectionTitle('Manage specialties', action: 'Add', onTap: () => promptText(context, 'Add specialty', 'Specialty').then((value) {
                if (value != null) store.adminService.addSpecialty(store, value);
              })),
          Wrap(spacing: 8, runSpacing: 8, children: store.specialties.map((item) => Chip(label: Text(item))).toList()),
          SectionTitle('Manage banners / health tips', action: 'Add', onTap: () => promptText(context, 'Add health tip', 'Tip').then((value) {
                if (value != null) store.adminService.addHealthTip(store, value);
              })),
          ...store.healthTips.map((tip) => InfoStrip(icon: Icons.tips_and_updates, text: tip)),
          const SectionTitle('Ambulance requests'),
          ...store.ambulances.map((amb) => InfoStrip(icon: Icons.emergency, text: '${amb.name} • ${amb.district} • ${amb.phone}')),
          const SectionTitle('Reports'),
          ReportCard(label: 'Doctor approval conversion', value: '${store.doctors.where((e) => e.status == 'approved').length}/${store.doctors.length} approved'),
          ReportCard(label: 'Average booking value', value: '₹${averageBookingValue(store).toStringAsFixed(0)}'),
          ReportCard(label: 'Online availability', value: '${store.approvedDoctors.where((e) => e.isOnlineAvailable).length} doctors online'),
          ActionTile(icon: Icons.logout, title: 'Logout admin', subtitle: 'Return to role selection', danger: true, onTap: () => store.logout()),
        ],
      ),
    );
  }
}

class HospitalsPatientScreen extends StatelessWidget {
  const HospitalsPatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hospitals = context.watch<DoctorMitraStore>().hospitals;
    return AppPage(
      title: 'Hospitals',
      subtitle: 'Connected hospital directory.',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: hospitals.map((hospital) => HospitalCard(hospital: hospital)).toList(),
      ),
    );
  }
}

class AmbulancePatientScreen extends StatelessWidget {
  const AmbulancePatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    return AppPage(
      title: 'Ambulance',
      subtitle: 'Emergency providers and one-tap calling.',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const PremiumHeader(
            title: 'Emergency help',
            subtitle: 'For urgent care, call 102 or nearest provider.',
            icon: Icons.emergency,
          ),
          const SizedBox(height: 16),
          ...store.ambulances.map((amb) => PremiumCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: Color(0xFFFFEBEE), child: Icon(Icons.local_taxi, color: AppColors.red)),
                  title: Text(amb.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${amb.district} • ${amb.isAvailable ? 'Available' : 'Busy'}'),
                  trailing: IconButton(
                    onPressed: () => store.ambulanceService.callProvider(amb),
                    icon: const Icon(Icons.call, color: AppColors.green),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

TextStyle get sectionStyle => const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
    );

List<BoxShadow> get softShadow => [
      BoxShadow(
        color: AppColors.green.withOpacity(0.08),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ];

void push(BuildContext context, Widget screen) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (_, animation, __) => screen,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.04, 0.02), end: Offset.zero).animate(animation),
          child: child,
        ),
      );
    },
  ));
}

void pushReplacement(BuildContext context, Widget screen) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
}

InputDecoration inputDecoration(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.green.withOpacity(0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.green.withOpacity(0.12)),
      ),
    );

class LoginScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  const LoginScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            PremiumHeader(title: title, subtitle: subtitle, icon: icon),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;
  final List<Widget> actions;

  const AppPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: showBack ? const BackButton() : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: actions,
      ),
      body: child,
    );
  }
}

class AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final int maxLines;

  const AppField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        maxLines: obscure ? 1 : maxLines,
        decoration: inputDecoration(label, icon),
      ),
    );
  }
}

class ErrorText extends StatelessWidget {
  final String text;
  const ErrorText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
    );
  }
}

class PrimaryAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const PrimaryAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

class SecondaryAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const SecondaryAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.mint,
            child: Icon(icon, color: AppColors.green, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.green),
        ],
      ),
    );
  }
}

class PremiumHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const PremiumHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.deepGreen, AppColors.green]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(icon, color: AppColors.green, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.white70, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PremiumCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: softShadow,
        border: Border.all(color: AppColors.green.withOpacity(0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}

class InfoStrip extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoStrip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

class NavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const NavBar({super.key, required this.index, required this.onTap, required this.items});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onTap,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.mint,
      destinations: items
          .map((item) => NavigationDestination(icon: Icon(item.icon), label: item.label))
          .toList(),
    );
  }
}

class HeroSearchCard extends StatelessWidget {
  final VoidCallback onTap;
  const HeroSearchCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.green, Color(0xFF0CA678)]),
        borderRadius: BorderRadius.circular(32),
        boxShadow: softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Find trusted care', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Doctors, hospitals, ambulance and health card in one app.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 22),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.green),
                  SizedBox(width: 12),
                  Expanded(child: Text('Search doctor or specialty...', style: TextStyle(color: AppColors.muted))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const MetricTile(this.label, this.value, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          Icon(icon, color: AppColors.green),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class QuickItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  QuickItem(this.icon, this.label, this.onTap);
}

class QuickGrid extends StatelessWidget {
  final List<QuickItem> items;
  const QuickGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 0.86,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items
          .map((item) => InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.mint,
                      child: Icon(item.icon, color: AppColors.green, size: 30),
                    ),
                    const SizedBox(height: 10),
                    Text(item.label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;

  const SectionTitle(this.title, {super.key, this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: sectionStyle)),
          if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
        ],
      ),
    );
  }
}

class DoctorCardMvp extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onTap;

  const DoctorCardMvp({super.key, required this.doctor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      child: Row(
        children: [
          DoctorAvatar(doctor: doctor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(doctor.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
                    if (doctor.isOnlineAvailable) const StatusChip('Online', Colors.green),
                  ],
                ),
                const SizedBox(height: 5),
                Text(doctor.specialty, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)),
                Text(doctor.degree, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.amber, size: 18),
                    Text(' ${doctor.rating} (${doctor.reviews})', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('₹${doctor.fee.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorAvatar extends StatelessWidget {
  final Doctor doctor;
  const DoctorAvatar({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 34,
      backgroundColor: doctor.specialty.contains('Cardio')
          ? const Color(0xFFFFECEC)
          : doctor.specialty.contains('Gyne')
              ? const Color(0xFFFFE5F1)
              : AppColors.mint,
      child: const Icon(Icons.person, color: AppColors.green, size: 34),
    );
  }
}

class BigDoctorHeader extends StatelessWidget {
  final Doctor doctor;
  const BigDoctorHeader({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          DoctorAvatar(doctor: doctor),
          const SizedBox(height: 12),
          Text(doctor.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(doctor.specialty, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)),
          Text('${doctor.degree} • ${doctor.experience} yrs', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 12),
          StatusChip(doctor.status, statusColor(doctor.status)),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(40)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

Color statusColor(String status) {
  return switch (status) {
    'accepted' || 'approved' || 'completed' => AppColors.green,
    'pending' => AppColors.amber,
    'cancelled' || 'rejected' => AppColors.red,
    _ => AppColors.muted,
  };
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  final Doctor doctor;
  final bool showPatient;
  final List<Widget> actions;

  const BookingCard({
    super.key,
    required this.booking,
    required this.doctor,
    this.showPatient = false,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DoctorAvatar(doctor: doctor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    Text(doctor.specialty, style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
              StatusChip(booking.status, statusColor(booking.status)),
            ],
          ),
          const SizedBox(height: 14),
          if (showPatient) InfoLine(Icons.person, 'Patient', '${booking.patientName} • ${booking.patientMobile}'),
          InfoLine(Icons.event, 'Date & time', '${booking.date}, ${booking.time}'),
          InfoLine(Icons.video_call, 'Type', booking.type == 'online' ? 'Online consultation' : 'Clinic visit'),
          InfoLine(Icons.notes, 'Symptoms', booking.symptoms),
          InfoLine(Icons.currency_rupee, 'Fee', '₹${booking.fee.toStringAsFixed(0)}'),
          if (actions.isNotEmpty) Wrap(alignment: WrapAlignment.end, spacing: 8, children: actions),
        ],
      ),
    );
  }
}

class InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoLine(this.icon, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.muted, size: 19),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: AppColors.muted)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final Widget? trailing;

  const HospitalCard({super.key, required this.hospital, this.trailing});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(backgroundColor: AppColors.mint, child: Icon(Icons.local_hospital, color: AppColors.green)),
        title: Text(hospital.name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('${hospital.type} • ${hospital.address} • ${hospital.phone}'),
        trailing: trailing,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const EmptyState({super.key, required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 42, backgroundColor: AppColors.mint, child: Icon(icon, color: AppColors.green, size: 38)),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class BillCard extends StatelessWidget {
  final List<(String, String)> rows;
  const BillCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: rows
            .map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(row.$1, style: const TextStyle(color: AppColors.muted))),
                      Text(row.$2, style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class CardMini extends StatelessWidget {
  final String label;
  final String value;
  const CardMini({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class ProfileHero extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;

  const ProfileHero({super.key, required this.name, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          CircleAvatar(radius: 48, backgroundColor: AppColors.mint, child: Icon(icon, color: AppColors.green, size: 46)),
          const SizedBox(height: 14),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(subtitle, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.red : AppColors.green;
    return PremiumCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: danger ? AppColors.red : AppColors.ink)),
                Text(subtitle, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}

class AdminMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const AdminMetric(this.label, this.value, this.icon, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: softShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class MiniBarChart extends StatelessWidget {
  final Map<String, double> values;
  const MiniBarChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    final max = values.values.fold<double>(1, (a, b) => a > b ? a : b);
    return PremiumCard(
      child: Column(
        children: values.entries
            .map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      SizedBox(width: 78, child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: entry.value / max,
                            minHeight: 12,
                            color: statusColor(entry.key.toLowerCase()),
                            backgroundColor: AppColors.mint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(entry.value.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final String label;
  final String value;
  const ReportCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return InfoStrip(icon: Icons.insights, text: '$label: $value');
  }
}

double averageBookingValue(DoctorMitraStore store) {
  if (store.bookings.isEmpty) return 0;
  return store.bookings.fold<double>(0, (sum, item) => sum + item.fee) / store.bookings.length;
}

Future<String?> promptText(BuildContext context, String title, String label) async {
  final controller = TextEditingController();
  final value = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, decoration: inputDecoration(label, Icons.edit)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
      ],
    ),
  );
  controller.dispose();
  return value;
}

void showSuccess(BuildContext context, String title, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.green,
      content: Text('$title: $message'),
    ),
  );
}

void showTips(BuildContext context) {
  final store = context.read<DoctorMitraStore>();
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Health tips', style: sectionStyle),
        const SizedBox(height: 12),
        ...store.healthTips.map((tip) => InfoStrip(icon: Icons.tips_and_updates, text: tip)),
      ],
    ),
  );
}

void showNotifications(BuildContext context) {
  final store = context.read<DoctorMitraStore>();
  final user = store.currentUser;
  final notes = user == null ? <AppNotification>[] : store.notificationService.forUser(store, user.id);
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Notifications', style: sectionStyle),
        const SizedBox(height: 12),
        if (notes.isEmpty) const EmptyState(icon: Icons.notifications_off, title: 'No notifications', text: 'Important updates will arrive here.'),
        ...notes.map((note) => InfoStrip(icon: Icons.notifications, text: '${note.title}: ${note.body}')),
      ],
    ),
  );
}

void showSyncSheet(BuildContext context) {
  final store = context.read<DoctorMitraStore>();
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cloud sync', style: sectionStyle),
          const SizedBox(height: 12),
          InfoStrip(
            icon: store.isInternetConnected ? Icons.cloud_done : Icons.cloud_off,
            text: 'Mode: ${store.syncMode}',
          ),
          InfoStrip(
            icon: Icons.api,
            text: store._api.endpointLabel,
          ),
          PrimaryAction(
            label: 'Sync now',
            icon: Icons.sync,
            onPressed: () async {
              await store.syncNow();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

void showPatientProfileEditor(BuildContext context) {
  final store = context.read<DoctorMitraStore>();
  final user = store.currentUser!;
  final name = TextEditingController(text: user.name);
  final mobile = TextEditingController(text: user.mobile);
  final district = TextEditingController(text: user.district);
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Edit profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppField(controller: name, label: 'Name', icon: Icons.person),
            AppField(controller: mobile, label: 'Mobile', icon: Icons.phone),
            AppField(controller: district, label: 'District', icon: Icons.location_on),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            store.patientService.updateProfile(store, name: name.text, mobile: mobile.text, district: district.text);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  ).then((_) {
    name.dispose();
    mobile.dispose();
    district.dispose();
  });
}

void showAdminDoctorEditor(BuildContext context, {Doctor? doctor}) {
  final store = context.read<DoctorMitraStore>();
  final name = TextEditingController(text: doctor?.name ?? 'Dr. Added Doctor');
  final specialty = TextEditingController(text: doctor?.specialty ?? store.specialties.first);
  final degree = TextEditingController(text: doctor?.degree ?? 'MBBS');
  final fee = TextEditingController(text: (doctor?.fee ?? 500).toStringAsFixed(0));
  final district = TextEditingController(text: doctor?.district ?? 'Patna');
  final clinic = TextEditingController(text: doctor?.clinicName ?? 'Doctor Mitra Clinic');
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(doctor == null ? 'Add doctor' : 'Edit doctor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppField(controller: name, label: 'Name', icon: Icons.person),
            AppField(controller: specialty, label: 'Specialty', icon: Icons.category),
            AppField(controller: degree, label: 'Degree', icon: Icons.school),
            AppField(controller: fee, label: 'Fee', icon: Icons.currency_rupee),
            AppField(controller: district, label: 'District', icon: Icons.location_on),
            AppField(controller: clinic, label: 'Clinic', icon: Icons.business),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final userId = doctor?.userId ?? _uuid.v4();
            if (doctor == null) {
              store.users.add(AppUser(
                id: userId,
                role: 'doctor',
                name: name.text,
                mobile: '9000000000',
                email: '${name.text.toLowerCase().replaceAll(' ', '')}@doctormitra.in',
                password: 'doctor123',
                district: district.text,
                createdAt: DateTime.now().toIso8601String(),
              ));
            }
            store.adminService.addOrUpdateDoctor(
              store,
              Doctor(
                id: doctor?.id ?? _uuid.v4(),
                userId: userId,
                name: name.text,
                specialty: specialty.text,
                degree: degree.text,
                experience: doctor?.experience ?? 5,
                registrationNumber: doctor?.registrationNumber ?? 'BRMC-${DateTime.now().millisecondsSinceEpoch}',
                clinicName: clinic.text,
                address: doctor?.address ?? '${clinic.text}, ${district.text}',
                district: district.text,
                fee: double.tryParse(fee.text) ?? 500,
                onlineFee: (double.tryParse(fee.text) ?? 500) * 0.7,
                rating: doctor?.rating ?? 4.5,
                reviews: doctor?.reviews ?? 0,
                status: doctor?.status ?? 'approved',
                isOnlineAvailable: doctor?.isOnlineAvailable ?? true,
                slots: doctor?.slots ?? ['10:00', '11:00', '17:00'],
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  ).then((_) {
    name.dispose();
    specialty.dispose();
    degree.dispose();
    fee.dispose();
    district.dispose();
    clinic.dispose();
  });
}

void showHospitalEditor(BuildContext context) {
  final store = context.read<DoctorMitraStore>();
  final name = TextEditingController(text: 'New Hospital');
  final district = TextEditingController(text: 'Patna');
  final address = TextEditingController(text: 'Main Road, Patna');
  final phone = TextEditingController(text: '0612-2200000');
  final type = TextEditingController(text: 'Multispeciality');
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add hospital'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppField(controller: name, label: 'Hospital name', icon: Icons.local_hospital),
            AppField(controller: district, label: 'District', icon: Icons.location_on),
            AppField(controller: address, label: 'Address', icon: Icons.map),
            AppField(controller: phone, label: 'Phone', icon: Icons.phone),
            AppField(controller: type, label: 'Type', icon: Icons.category),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            store.hospitalService.addHospital(
              store,
              Hospital(
                id: _uuid.v4(),
                name: name.text,
                district: district.text,
                address: address.text,
                phone: phone.text,
                type: type.text,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  ).then((_) {
    name.dispose();
    district.dispose();
    address.dispose();
    phone.dispose();
    type.dispose();
  });
}

import 'dart:async';
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

class AmbulanceRequest {
  final String id;
  final String patientId;
  final String patientName;
  final String patientMobile;
  final String district;
  final String pickupAddress;
  final String emergencyType;
  final String providerId;
  final String status;
  final String createdAt;

  AmbulanceRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientMobile,
    required this.district,
    required this.pickupAddress,
    required this.emergencyType,
    required this.providerId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'patientName': patientName,
        'patientMobile': patientMobile,
        'district': district,
        'pickupAddress': pickupAddress,
        'emergencyType': emergencyType,
        'providerId': providerId,
        'status': status,
        'createdAt': createdAt,
      };

  factory AmbulanceRequest.fromJson(Map<String, dynamic> json) =>
      AmbulanceRequest(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        patientName: json['patientName'] as String,
        patientMobile: json['patientMobile'] as String,
        district: json['district'] as String,
        pickupAddress: json['pickupAddress'] as String,
        emergencyType: json['emergencyType'] as String,
        providerId: json['providerId'] as String? ?? '',
        status: json['status'] as String,
        createdAt: json['createdAt'] as String,
      );

  AmbulanceRequest copyWith({String? status}) => AmbulanceRequest(
        id: id,
        patientId: patientId,
        patientName: patientName,
        patientMobile: patientMobile,
        district: district,
        pickupAddress: pickupAddress,
        emergencyType: emergencyType,
        providerId: providerId,
        status: status ?? this.status,
        createdAt: createdAt,
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

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
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

  Uri _uri(String path) =>
      Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');

  Future<Map<String, dynamic>?> readState() async {
    if (!isConfigured) return null;
    try {
      final response = await http
          .get(_uri('/api/state'))
          .timeout(const Duration(seconds: 8));
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
      final response =
          await http.get(_uri('/health')).timeout(const Duration(seconds: 5));
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
      if (state is! Map<String, dynamic> || state['users'] is! List) {
        return null;
      }
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

class SupabaseAuthLayer {
  static bool get isConfigured => SupabaseApiLayer.isConfiguredStatic;

  static Uri _uri(String path, [Map<String, String>? query]) {
    final base = SupabaseApiLayer.projectUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  static Map<String, String> get _headers => {
        'apikey': SupabaseApiLayer.anonKey,
        'Authorization': 'Bearer ${SupabaseApiLayer.anonKey}',
        'Content-Type': 'application/json',
      };

  static String phoneForIndia(String mobile) {
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    final tenDigit =
        digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    return '+91$tenDigit';
  }

  static String _authError(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['msg'] as String? ??
          body['message'] as String? ??
          body['error_description'] as String? ??
          body['error'] as String? ??
          fallback;
    } catch (_) {
      return fallback;
    }
  }

  static Future<String?> sendPhoneOtp(String mobile) async {
    if (!isConfigured) return 'Supabase Auth is not configured';
    try {
      final response = await http
          .post(
            _uri('/auth/v1/otp'),
            headers: _headers,
            body: jsonEncode({
              'phone': phoneForIndia(mobile),
              'create_user': true,
              'data': {'role': 'patient'},
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      return _authError(response, 'Could not send Supabase OTP');
    } catch (_) {
      return 'Supabase Auth unavailable. Demo OTP 123456 still works.';
    }
  }

  static Future<String?> verifyPhoneOtp({
    required String mobile,
    required String otp,
  }) async {
    if (!isConfigured) return 'Supabase Auth is not configured';
    try {
      final response = await http
          .post(
            _uri('/auth/v1/verify'),
            headers: _headers,
            body: jsonEncode({
              'phone': phoneForIndia(mobile),
              'token': otp.trim(),
              'type': 'sms',
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      return _authError(response, 'Invalid Supabase OTP');
    } catch (_) {
      return 'Supabase Auth unavailable. Use demo OTP 123456.';
    }
  }

  static Future<String?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) return 'Supabase Auth is not configured';
    try {
      final response = await http
          .post(
            _uri('/auth/v1/token', {'grant_type': 'password'}),
            headers: _headers,
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      return _authError(response, 'Invalid Supabase login credentials');
    } catch (_) {
      return 'Supabase Auth unavailable';
    }
  }

  static Future<String?> signUpWithPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    if (!isConfigured) return 'Supabase Auth is not configured';
    try {
      final response = await http
          .post(
            _uri('/auth/v1/signup'),
            headers: _headers,
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
              'data': {
                'name': name.trim(),
                'role': role,
              },
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) return null;
      return _authError(response, 'Could not create Supabase Auth user');
    } catch (_) {
      return 'Supabase Auth unavailable. Check internet and Supabase settings.';
    }
  }
}

class CloudApiLayer {
  final SupabaseApiLayer _supabase = SupabaseApiLayer();
  final InternetApiLayer _internet = InternetApiLayer();

  static bool get isConfigured =>
      SupabaseApiLayer.isConfiguredStatic ||
      InternetApiLayer.isConfiguredStatic;

  bool get isSupabase => _supabase.isConfigured;
  bool get isInternetActionApi => _internet.isConfigured;
  bool get isConfiguredInstance =>
      _supabase.isConfigured || _internet.isConfigured;

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

  Future<Map<String, dynamic>?> runAction(
          String type, Map<String, dynamic> payload) =>
      _internet.runAction(type, payload);
}

class DoctorMitraStore extends ChangeNotifier {
  final LocalStorageLayer _storage = LocalStorageLayer();
  final CloudApiLayer _api = CloudApiLayer();
  Timer? _autoSyncTimer;
  bool _pullInFlight = false;
  bool _writeInFlight = false;

  bool isLoading = true;
  bool isInternetConnected = false;
  String syncMode = CloudApiLayer.isConfigured ? 'Connecting...' : 'Local demo';
  DateTime? lastSyncedAt;
  AppUser? currentUser;
  List<AppUser> users = [];
  List<Doctor> doctors = [];
  List<Booking> bookings = [];
  List<Hospital> hospitals = [];
  List<AmbulanceProviderModel> ambulances = [];
  List<AmbulanceRequest> ambulanceRequests = [];
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
        currentUser =
            users.where((user) => user.id == localCurrentUserId).firstOrNull;
      }
      isInternetConnected = true;
      syncMode = _api.syncLabel;
      await _saveLocalOnly();
    } else {
      isInternetConnected = false;
      syncMode = _api.isConfiguredInstance ? 'Offline fallback' : 'Local demo';
    }
    isLoading = false;
    _startAutoSync();
    notifyListeners();
  }

  void _startAutoSync() {
    if (!_api.isConfiguredInstance || _autoSyncTimer != null) return;
    _autoSyncTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => refreshFromCloud(),
    );
  }

  Future<bool> refreshFromCloud({bool notify = true}) async {
    if (!_api.isConfiguredInstance || _pullInFlight || _writeInFlight) {
      return false;
    }
    _pullInFlight = true;
    try {
      final remote = await _api.readState();
      if (remote != null && remote['users'] is List) {
        final localCurrentUserId = currentUser?.id;
        _hydrate(remote);
        if (localCurrentUserId != null) {
          currentUser =
              users.where((user) => user.id == localCurrentUserId).firstOrNull;
        }
        isInternetConnected = true;
        syncMode = _api.syncLabel;
        lastSyncedAt = DateTime.now();
        await _saveLocalOnly();
        if (notify && !isLoading) notifyListeners();
        return true;
      }
      isInternetConnected = false;
      syncMode = 'Offline fallback';
      if (notify && !isLoading) notifyListeners();
      return false;
    } finally {
      _pullInFlight = false;
    }
  }

  void _hydrate(Map<String, dynamic> raw) {
    users = (raw['users'] as List).map((e) => AppUser.fromJson(e)).toList();
    doctors = (raw['doctors'] as List).map((e) => Doctor.fromJson(e)).toList();
    bookings =
        (raw['bookings'] as List).map((e) => Booking.fromJson(e)).toList();
    hospitals =
        (raw['hospitals'] as List).map((e) => Hospital.fromJson(e)).toList();
    ambulances = (raw['ambulances'] as List)
        .map((e) => AmbulanceProviderModel.fromJson(e))
        .toList();
    ambulanceRequests = ((raw['ambulanceRequests'] as List?) ?? [])
        .map((e) => AmbulanceRequest.fromJson(e))
        .toList();
    healthCards = (raw['healthCards'] as List)
        .map((e) => HealthCard.fromJson(e))
        .toList();
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

  void _addPendingDoctorQueue(String createdAt) {
    const names = [
      'Dr. Amit Prakash',
      'Dr. Neha Sinha',
      'Dr. Saurabh Kumar',
      'Dr. Priya Kumari',
      'Dr. Alok Ranjan',
      'Dr. Shweta Jha',
      'Dr. Manish Kumar',
      'Dr. Pooja Singh',
      'Dr. Sanjay Verma',
      'Dr. Kavita Kumari',
      'Dr. Arvind Mishra',
      'Dr. Nidhi Sharma',
      'Dr. Deepak Yadav',
      'Dr. Ritu Raj',
      'Dr. Pramod Singh',
      'Dr. Anupama Kumari',
      'Dr. Rakesh Ranjan',
      'Dr. Swati Priya',
      'Dr. Ashok Kumar',
      'Dr. Garima Sinha',
      'Dr. Pankaj Jha',
      'Dr. Sneha Kumari',
      'Dr. Vivek Anand',
      'Dr. Madhu Bala',
      'Dr. Nilesh Kumar',
      'Dr. Aparna Singh',
      'Dr. Rahul Raj',
      'Dr. Monika Kumari',
      'Dr. Ajay Prasad',
      'Dr. Sarita Jha',
      'Dr. Umesh Kumar',
      'Dr. Kiran Kumari',
      'Dr. Dinesh Chandra',
      'Dr. Jyoti Singh',
      'Dr. Abhishek Kumar',
      'Dr. Renu Sinha',
      'Dr. Harishankar Prasad',
      'Dr. Pallavi Kumari',
      'Dr. Gaurav Kumar',
      'Dr. Mamta Singh',
      'Dr. Om Prakash',
      'Dr. Suman Kumari',
      'Dr. Niraj Kumar',
      'Dr. Rekha Rani',
      'Dr. Chandan Singh',
      'Dr. Vandana Jha',
      'Dr. Rajesh Kumar',
      'Dr. Archana Kumari',
      'Dr. Mukesh Pandey',
      'Dr. Seema Singh',
    ];
    const specialties = [
      'General Physician',
      'Gynecologist',
      'Cardiologist',
      'Dermatologist',
      'Neurologist',
      'Dentist',
      'Pediatrician',
      'Orthopedic',
      'ENT Specialist',
      'Psychiatrist',
    ];
    const districts = [
      'Patna',
      'Gaya',
      'Bhagalpur',
      'Muzaffarpur',
      'Darbhanga',
      'Purnea',
      'Munger',
      'Nalanda',
      'Saran',
      'Bhojpur',
    ];
    const degrees = ['MBBS', 'MBBS, MD', 'MBBS, MS', 'BDS', 'MBBS, DNB'];

    for (var i = 0; i < names.length; i++) {
      final number = (i + 1).toString().padLeft(2, '0');
      final specialty = specialties[i % specialties.length];
      final district = districts[i % districts.length];
      final fee = 300 + (i % 6) * 100;
      final userId = 'pending-doctor-user-$number';
      users.add(AppUser(
        id: userId,
        role: 'doctor',
        name: names[i],
        mobile: '91${(7000000000 + i + 1).toString().substring(2)}',
        email: 'pending.doctor$number@doctormitra.in',
        password: 'doctor123',
        district: district,
        createdAt: createdAt,
      ));
      doctors.add(Doctor(
        id: 'pending-doctor-$number',
        userId: userId,
        name: names[i],
        specialty: specialty,
        degree: degrees[i % degrees.length],
        experience: 2 + (i % 24),
        registrationNumber: 'BRMC-PENDING-$number',
        clinicName: '$district Health Clinic $number',
        address: 'Main Road, $district',
        district: district,
        fee: fee.toDouble(),
        onlineFee: (fee * 0.7).roundToDouble(),
        rating: 4.4,
        reviews: 0,
        status: 'pending',
        isOnlineAvailable: i % 3 != 0,
        slots: const ['10:00', '11:00', '17:00'],
      ));
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
    _addPendingDoctorQueue(now);
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
    ambulanceRequests = [];
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
      'ambulanceRequests': ambulanceRequests.map((e) => e.toJson()).toList(),
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
    _writeInFlight = true;
    bool synced;
    try {
      synced = await _api.writeState(_toJson(includeSession: false));
    } finally {
      _writeInFlight = false;
    }
    if (_api.isConfiguredInstance) {
      isInternetConnected = synced;
      syncMode = synced ? _api.syncLabel : 'Offline fallback';
      if (synced) lastSyncedAt = DateTime.now();
    }
  }

  Future<void> syncNow() async {
    final pulled = await refreshFromCloud(notify: false);
    if (!pulled) {
      final synced = await _api.writeState(_toJson(includeSession: false));
      isInternetConnected = synced;
      syncMode = _api.isConfiguredInstance
          ? (synced ? _api.syncLabel : 'Offline fallback')
          : 'Local demo';
      if (synced) lastSyncedAt = DateTime.now();
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

  String? get adminUserId =>
      users.where((user) => user.role == 'admin').firstOrNull?.id;

  void addNotification({
    required String userId,
    required String title,
    required String body,
  }) {
    notifications.insert(
      0,
      AppNotification(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        body: body,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
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

  Doctor doctorById(String id) => doctors
      .firstWhere((doctor) => doctor.id == id, orElse: () => doctors.first);
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

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }
}

class AuthService {
  Future<String?> sendPatientOtp({
    required String mobile,
  }) async {
    final normalized = mobile.replaceAll(RegExp(r'\D'), '');
    if (normalized.length < 10) return 'Enter a valid 10 digit mobile number';
    if (!SupabaseAuthLayer.isConfigured) {
      return 'Supabase Auth is not configured. Use demo OTP 123456.';
    }
    return SupabaseAuthLayer.sendPhoneOtp(normalized);
  }

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
    final normalized = mobile.replaceAll(RegExp(r'\D'), '');
    if (normalized.length != 10) return 'Enter a valid 10 digit mobile number';
    if (otp.trim() != '123456') {
      if (!SupabaseAuthLayer.isConfigured) return 'Use demo OTP 123456';
      final otpError = await SupabaseAuthLayer.verifyPhoneOtp(
        mobile: normalized,
        otp: otp,
      );
      if (otpError != null) return otpError;
    }
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
    if (SupabaseAuthLayer.isConfigured) {
      final authError = await SupabaseAuthLayer.signInWithPassword(
        email: email,
        password: password,
      );
      if (authError != null) return authError;
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
    final doctor =
        store.doctors.where((item) => item.userId == user.id).firstOrNull;
    if (doctor == null) return 'Doctor profile missing';
    if (doctor.status != 'approved') {
      return doctor.status == 'pending'
          ? 'Registration pending admin approval'
          : 'Registration rejected by admin';
    }
    if (SupabaseAuthLayer.isConfigured && !user.id.startsWith('doctor-user-')) {
      final authError = await SupabaseAuthLayer.signInWithPassword(
        email: email,
        password: password,
      );
      if (authError != null) return authError;
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
    if (store.users
        .any((user) => user.email.toLowerCase() == email.toLowerCase())) {
      return 'Email already registered';
    }
    if (SupabaseAuthLayer.isConfigured) {
      final authError = await SupabaseAuthLayer.signUpWithPassword(
        email: email,
        password: password,
        name: name,
        role: 'doctor',
      );
      if (authError != null) return authError;
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
    final adminId = store.adminUserId;
    if (adminId != null) {
      store.addNotification(
        userId: adminId,
        title: 'Doctor approval pending',
        body: '${name.trim()} submitted registration.',
      );
    }
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
      store.bookings
          .where((booking) => booking.patientId == patientId)
          .toList();

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
    store.users[index] =
        current.copyWith(name: name, mobile: mobile, district: district);
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
    final index =
        store.healthCards.indexWhere((item) => item.userId == user.id);
    if (index == -1) {
      store.healthCards.add(card);
    } else {
      store.healthCards[index] = card;
    }
    await store.persist();
  }
}

class DoctorService {
  List<Booking> appointmentsForDoctor(
          DoctorMitraStore store, String doctorId) =>
      store.bookings.where((booking) => booking.doctorId == doctorId).toList();

  List<AppUser> patientsForDoctor(DoctorMitraStore store, String doctorId) {
    final ids =
        appointmentsForDoctor(store, doctorId).map((e) => e.patientId).toSet();
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
      final error = await store
          .runRemoteAction('admin.approveDoctor', {'doctorId': doctorId});
      if (error == null) return;
    }
    final current = store.doctorById(doctorId);
    store.addNotification(
      userId: current.userId,
      title: 'Registration approved',
      body: 'Your Doctor Mitra profile is approved.',
    );
    final doctor = current.copyWith(status: 'approved');
    await store.doctorService.updateDoctor(store, doctor);
  }

  Future<void> rejectDoctor(DoctorMitraStore store, String doctorId) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store
          .runRemoteAction('admin.rejectDoctor', {'doctorId': doctorId});
      if (error == null) return;
    }
    final current = store.doctorById(doctorId);
    store.addNotification(
      userId: current.userId,
      title: 'Registration rejected',
      body: 'Your Doctor Mitra profile is rejected.',
    );
    final doctor = current.copyWith(status: 'rejected');
    await store.doctorService.updateDoctor(store, doctor);
  }

  Future<void> deleteDoctor(DoctorMitraStore store, String doctorId) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store
          .runRemoteAction('admin.deleteDoctor', {'doctorId': doctorId});
      if (error == null) return;
    }
    store.doctors.removeWhere((doctor) => doctor.id == doctorId);
    store.bookings.removeWhere((booking) => booking.doctorId == doctorId);
    await store.persist();
  }

  Future<void> addOrUpdateDoctor(DoctorMitraStore store, Doctor doctor) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store
          .runRemoteAction('admin.upsertDoctor', {'doctor': doctor.toJson()});
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
      final error = await store
          .runRemoteAction('admin.addSpecialty', {'specialty': specialty});
      if (error == null) return;
    }
    if (specialty.trim().isEmpty ||
        store.specialties.contains(specialty.trim())) return;
    store.specialties.add(specialty.trim());
    await store.persist();
  }

  Future<void> addHealthTip(DoctorMitraStore store, String tip) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error =
          await store.runRemoteAction('admin.addHealthTip', {'tip': tip});
      if (error == null) return;
    }
    if (tip.trim().isEmpty) return;
    store.healthTips.insert(0, tip.trim());
    await store.persist();
  }

  Future<void> setMaintenanceMode(DoctorMitraStore store, bool value) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store
          .runRemoteAction('admin.setMaintenanceMode', {'value': value});
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
    store.addNotification(
      userId: doctor.userId,
      title: 'New appointment',
      body: '${user.name} booked ${doctor.name} for $date at $time',
    );
    final adminId = store.adminUserId;
    if (adminId != null) {
      store.addNotification(
        userId: adminId,
        title: 'New booking',
        body: '${user.name} booked ${doctor.name}.',
      );
    }
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
    final index =
        store.bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) return;
    final booking = store.bookings[index].copyWith(status: status);
    store.bookings[index] = booking;
    final doctor = store.doctorById(booking.doctorId);
    store.addNotification(
      userId: booking.patientId,
      title: 'Booking ${status.toUpperCase()}',
      body: 'Your appointment with ${doctor.name} is now $status.',
    );
    store.addNotification(
      userId: doctor.userId,
      title: 'Booking ${status.toUpperCase()}',
      body: '${booking.patientName} appointment is now $status.',
    );
    final adminId = store.adminUserId;
    if (adminId != null) {
      store.addNotification(
        userId: adminId,
        title: 'Booking ${status.toUpperCase()}',
        body:
            '${booking.patientName} appointment with ${doctor.name} is now $status.',
      );
    }
    await store.persist();
  }
}

class SlotService {
  Future<void> addSlot(
      DoctorMitraStore store, Doctor doctor, String slot) async {
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

  Future<void> removeSlot(
      DoctorMitraStore store, Doctor doctor, String slot) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'slot.remove',
        {'doctorId': doctor.id, 'slot': slot},
      );
      if (error == null) return;
    }
    await store.doctorService.updateDoctor(
      store,
      doctor.copyWith(
          slots: doctor.slots.where((item) => item != slot).toList()),
    );
  }
}

class HospitalService {
  Future<void> addHospital(DoctorMitraStore store, Hospital hospital) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error =
          await store.runRemoteAction('hospital.add', hospital.toJson());
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

  Future<void> addAmbulance(
      DoctorMitraStore store, AmbulanceProviderModel ambulance) async {
    if (store.isInternetConnected) {
      final error =
          await store.runRemoteAction('ambulance.add', ambulance.toJson());
      if (error != null) return;
    } else {
      final index =
          store.ambulances.indexWhere((item) => item.id == ambulance.id);
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

  Future<AmbulanceRequest> requestAmbulance(
    DoctorMitraStore store, {
    required AmbulanceProviderModel provider,
    required String pickupAddress,
    required String emergencyType,
  }) async {
    final user = store.currentUser!;
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'ambulance.request',
        {
          'patientId': user.id,
          'providerId': provider.id,
          'pickupAddress': pickupAddress,
          'emergencyType': emergencyType,
        },
      );
      if (error == null) {
        return store.ambulanceRequests.firstWhere(
          (request) =>
              request.patientId == user.id &&
              request.providerId == provider.id &&
              request.pickupAddress == pickupAddress,
        );
      }
    }
    final request = AmbulanceRequest(
      id: _uuid.v4(),
      patientId: user.id,
      patientName: user.name,
      patientMobile: user.mobile,
      district: user.district,
      pickupAddress: pickupAddress.trim(),
      emergencyType: emergencyType.trim().isEmpty
          ? 'Emergency ambulance'
          : emergencyType.trim(),
      providerId: provider.id,
      status: 'requested',
      createdAt: DateTime.now().toIso8601String(),
    );
    store.ambulanceRequests.insert(0, request);
    final adminId = store.adminUserId;
    if (adminId != null) {
      store.addNotification(
        userId: adminId,
        title: 'Ambulance request',
        body:
            '${user.name} requested ${provider.name} from ${request.pickupAddress}.',
      );
    }
    await store.persist();
    return request;
  }

  Future<void> updateRequestStatus(
    DoctorMitraStore store,
    String requestId,
    String status,
  ) async {
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final error = await store.runRemoteAction(
        'ambulance.updateRequest',
        {'requestId': requestId, 'status': status},
      );
      if (error == null) return;
    }
    final index = store.ambulanceRequests
        .indexWhere((request) => request.id == requestId);
    if (index == -1) return;
    final request = store.ambulanceRequests[index].copyWith(status: status);
    store.ambulanceRequests[index] = request;
    store.addNotification(
      userId: request.patientId,
      title: 'Ambulance ${status.toUpperCase()}',
      body: 'Your ambulance request is now $status.',
    );
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
            error: AppColors.red,
          ),
          textTheme: GoogleFonts.poppinsTextTheme().copyWith(
            headlineSmall: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
            titleLarge: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
            titleMedium: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink),
            bodyLarge: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.muted),
            bodyMedium: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.ink),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.ink,
            elevation: 0,
            centerTitle: false,
            iconTheme: IconThemeData(color: AppColors.green, size: 24),
            titleTextStyle: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.black.withOpacity(0.02), width: 1),
            ),
            margin: EdgeInsets.zero,
            shadowColor: Colors.black.withOpacity(0.08),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.green, width: 1.5),
            ),
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
            prefixIconColor: AppColors.green,
          ),
        ),
        home: const AppGate(),
      ),
    );
  }
}

class AppColors {
  static const green = Color(0xFF0B6E4F); // deep medical green (#0B6E4F)
  static const deepGreen = Color(0xFF054F37); // deeper medical green
  static const mint = Color(0xFFE8F5F0); // Primary Light (#E8F5F0)
  static const accent = Color(0xFF00A878); // Accent CTA (#00A878)
  static const bg = Color(
      0xFFF4F6F9); // Background (#F4F6F9 - soft grey-white, NOT mint green)
  static const ink = Color(0xFF1A1A2E); // Text Primary (#1A1A2E)
  static const muted = Color(0xFF6B7280); // Text Secondary (#6B7280)
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
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
          colors: [AppColors.green, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/logo.jpg',
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Doctor Mitra',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'One connected healthcare platform',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontFamily: 'Poppins',
                letterSpacing: 0.2,
              ),
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
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
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
              text:
                  'Demo OTP: 123456  •  Admin: admin@doctormitra.in / Rakesh@12032',
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
  String? notice;
  bool sendingOtp = false;

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
      subtitle: 'Supabase phone OTP is active when SMS is configured.',
      icon: Icons.phone_android,
      children: [
        AppField(controller: mobile, label: 'Mobile number', icon: Icons.phone),
        AppField(controller: otp, label: 'OTP', icon: Icons.password),
        SecondaryAction(
          label: sendingOtp ? 'Sending OTP...' : 'Send Supabase OTP',
          icon: Icons.sms,
          onPressed: sendingOtp
              ? () {}
              : () async {
                  setState(() {
                    sendingOtp = true;
                    error = null;
                    notice = null;
                  });
                  final result = await context
                      .read<DoctorMitraStore>()
                      .authService
                      .sendPatientOtp(mobile: mobile.text);
                  if (!mounted) return;
                  setState(() {
                    sendingOtp = false;
                    if (result == null) {
                      notice = 'OTP sent through Supabase.';
                    } else {
                      error = result;
                    }
                  });
                },
        ),
        if (notice != null) InfoStrip(icon: Icons.check_circle, text: notice!),
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
            ButtonSegment(
                value: false, label: Text('Login'), icon: Icon(Icons.login)),
            ButtonSegment(
                value: true,
                label: Text('Register'),
                icon: Icon(Icons.app_registration)),
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
            onChanged: (value) =>
                setState(() => specialty = value ?? specialty),
            decoration: inputDecoration('Specialty', Icons.category),
          ),
          AppField(controller: degree, label: 'Degree', icon: Icons.school),
          AppField(
              controller: regNo,
              label: 'Registration number',
              icon: Icons.badge),
          AppField(
              controller: clinic, label: 'Clinic name', icon: Icons.business),
          AppField(
              controller: district, label: 'District', icon: Icons.location_on),
          AppField(
              controller: fee, label: 'Clinic fee', icon: Icons.currency_rupee),
        ],
        AppField(controller: email, label: 'Email', icon: Icons.email),
        AppField(
            controller: password,
            label: 'Password',
            icon: Icons.lock,
            obscure: true),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              message!,
              style: TextStyle(
                color: message!.contains('submitted')
                    ? AppColors.green
                    : AppColors.red,
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
              message = result ??
                  (register
                      ? 'Registration submitted. Admin approval required.'
                      : null);
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
        AppField(
            controller: email, label: 'Mobile or email', icon: Icons.email),
        AppField(
            controller: password,
            label: 'Password',
            icon: Icons.lock,
            obscure: true),
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
          icon: Icon(
              store.isInternetConnected ? Icons.cloud_done : Icons.cloud_off),
        ),
        const NotificationBell(),
      ],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          HeroSearchCard(
            onTap: () =>
                push(context, const PatientDoctorsScreen(showBack: true)),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                  child: MetricTile(
                      'Doctors',
                      '${store.approvedDoctors.length}+',
                      Icons.medical_services)),
              Expanded(
                  child: MetricTile(
                      'Districts',
                      '${store.doctors.map((e) => e.district).toSet().length}',
                      Icons.location_on)),
              const Expanded(
                  child: MetricTile('Booking', 'Free', Icons.verified)),
            ],
          ),
          const SizedBox(height: 18),
          QuickGrid(
            items: [
              QuickItem(
                  Icons.person_search,
                  'Find Doctor',
                  () => push(
                      context, const PatientDoctorsScreen(showBack: true))),
              QuickItem(
                  Icons.video_call,
                  'Online Consult',
                  () => push(
                      context,
                      const PatientDoctorsScreen(
                          showBack: true, onlineOnly: true))),
              QuickItem(
                  Icons.credit_card,
                  'Health Card',
                  () => push(
                      context, const PatientHealthCardScreen(showBack: true))),
              QuickItem(Icons.local_hospital, 'Hospitals',
                  () => push(context, const HospitalsPatientScreen())),
              QuickItem(Icons.emergency, 'Ambulance',
                  () => push(context, const AmbulancePatientScreen())),
              QuickItem(
                  Icons.lightbulb, 'Health Tips', () => showTips(context)),
            ],
          ),
          SectionTitle('Top doctors',
              action: 'See all',
              onTap: () =>
                  push(context, const PatientDoctorsScreen(showBack: true))),
          ...store.approvedDoctors
              .take(3)
              .map((doctor) => DoctorCardMvp(doctor: doctor)),
          const SectionTitle('Hospitals near you'),
          ...store.hospitals
              .take(2)
              .map((hospital) => HospitalCard(hospital: hospital)),
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
    final doctors =
        store.patientService.searchDoctors(store, query).where((doctor) {
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
              decoration: inputDecoration(
                  'Search doctor, specialty, district', Icons.search),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              itemCount: doctors.length,
              itemBuilder: (_, i) => DoctorCardMvp(
                doctor: doctors[i],
                onTap: () =>
                    push(context, DoctorProfileMvpScreen(doctor: doctors[i])),
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
              Expanded(
                  child: MetricTile(
                      'Experience', '${doctor.experience} yrs', Icons.work)),
              Expanded(
                  child: MetricTile(
                      'Rating', doctor.rating.toStringAsFixed(1), Icons.star)),
              Expanded(
                  child: MetricTile(
                      'Clinic fee',
                      '₹${doctor.fee.toStringAsFixed(0)}',
                      Icons.currency_rupee)),
            ],
          ),
          const SizedBox(height: 16),
          InfoStrip(
              icon: Icons.location_on,
              text: '${doctor.clinicName}, ${doctor.address}'),
          InfoStrip(
              icon: Icons.badge,
              text: 'Registration: ${doctor.registrationNumber}'),
          const SizedBox(height: 16),
          PrimaryAction(
            label: 'Book clinic appointment',
            icon: Icons.event_available,
            onPressed: () => push(
                context, BookingCreateScreen(doctor: doctor, type: 'clinic')),
          ),
          if (doctor.isOnlineAvailable)
            SecondaryAction(
              label: 'Book online consultation',
              icon: Icons.video_call,
              onPressed: () => push(
                  context, BookingCreateScreen(doctor: doctor, type: 'online')),
            ),
        ],
      ),
    );
  }
}

class BookingCreateScreen extends StatefulWidget {
  final Doctor doctor;
  final String type;

  const BookingCreateScreen(
      {super.key, required this.doctor, required this.type});

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
    final fee =
        widget.type == 'online' ? widget.doctor.onlineFee : widget.doctor.fee;
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
          StatusChip(
              widget.type == 'online' ? 'Online consultation' : 'Clinic visit',
              AppColors.green),
          const SizedBox(height: 16),
          Text('Choose date', style: sectionStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(5, (i) {
              final value = DateFormat('dd MMM yyyy')
                  .format(DateTime.now().add(Duration(days: i)));
              return ChoiceChip(
                label: Text(i == 0
                    ? 'Today'
                    : DateFormat('dd MMM')
                        .format(DateTime.now().add(Duration(days: i)))),
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
          AppField(
              controller: symptoms,
              label: 'Symptoms or problem',
              icon: Icons.notes,
              maxLines: 3),
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
                symptoms: symptoms.text.trim().isEmpty
                    ? 'General consultation'
                    : symptoms.text.trim(),
              );
              if (!context.mounted) return;
              showSuccess(context, 'Booking created',
                  'Status is pending. Doctor and admin can see it now.');
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
          Center(
              child: Text('Appointment saved',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800))),
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
          ? const EmptyState(
              icon: Icons.calendar_month,
              title: 'No bookings yet',
              text: 'Book a doctor to see it here.')
          : ListView(
              padding: const EdgeInsets.all(18),
              children: bookings
                  .map((booking) => BookingCard(
                        booking: booking,
                        doctor: store.doctorById(booking.doctorId),
                        actions: booking.status == 'pending' ||
                                booking.status == 'accepted'
                            ? [
                                if (booking.type == 'online' &&
                                    booking.status == 'accepted')
                                  FilledButton.icon(
                                    onPressed: () => push(
                                        context,
                                        OnlineConsultationScreen(
                                            booking: booking)),
                                    icon: const Icon(Icons.video_call,
                                        color: Colors.white, size: 16),
                                    label: const Text('Join',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.green,
                                      minimumSize: const Size(80, 36),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                OutlinedButton.icon(
                                  onPressed: () => store.bookingService
                                      .updateStatus(
                                          store, booking.id, 'cancelled'),
                                  icon: const Icon(Icons.cancel,
                                      color: AppColors.red, size: 16),
                                  label: const Text('Cancel',
                                      style: TextStyle(
                                          color: AppColors.red,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  style: OutlinedButton.styleFrom(
                                    side:
                                        const BorderSide(color: AppColors.red),
                                    foregroundColor: AppColors.red,
                                    minimumSize: const Size(80, 36),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
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
  State<PatientHealthCardScreen> createState() =>
      _PatientHealthCardScreenState();
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: softShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.green, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'DOCTOR MITRA',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 2,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.verified_user,
                                  color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: DM-${user.id.substring(0, 6).toUpperCase()}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            letterSpacing: 1.0,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: CardMini(
                                label: 'Blood Group',
                                value:
                                    blood.text.isEmpty ? 'Not set' : blood.text,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CardMini(
                                label: 'Emergency Contact',
                                value: emergency.text.isEmpty
                                    ? 'Not set'
                                    : emergency.text,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -25,
                    top: -25,
                    child: Icon(
                      Icons.health_and_safety,
                      size: 160,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppField(
            controller: blood,
            label: 'Blood group',
            icon: Icons.bloodtype,
          ),
          const SizedBox(height: 16),
          AppField(
            controller: allergies,
            label: 'Known allergies',
            icon: Icons.warning,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          AppField(
            controller: meds,
            label: 'Current medications',
            icon: Icons.medication,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          AppField(
            controller: emergency,
            label: 'Emergency contact',
            icon: Icons.phone,
          ),
          const SizedBox(height: 24),
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
          ProfileHero(
              name: user.name,
              subtitle: '+91 ${user.mobile}',
              icon: Icons.person),
          ActionTile(
              icon: Icons.edit,
              title: 'Edit profile',
              subtitle: user.district,
              onTap: () => showPatientProfileEditor(context)),
          ActionTile(
              icon: Icons.health_and_safety,
              title: 'Health card',
              subtitle: 'Emergency profile',
              onTap: () =>
                  push(context, const PatientHealthCardScreen(showBack: true))),
          ActionTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle:
                  '${store.notificationService.forUser(store, user.id).length} updates',
              onTap: () => showNotifications(context)),
          ActionTile(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Return to role selection',
              danger: true,
              onTap: () => store.logout()),
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
    final appointments =
        store.doctorService.appointmentsForDoctor(store, doctor.id);
    final pending =
        appointments.where((item) => item.status == 'pending').length;
    final accepted =
        appointments.where((item) => item.status == 'accepted').length;
    final revenue = appointments
        .where(
            (item) => item.status != 'cancelled' && item.status != 'rejected')
        .fold<double>(0, (sum, item) => sum + item.fee);
    return AppPage(
      title: 'Doctor Dashboard',
      subtitle: doctor.name,
      actions: [
        IconButton(
          onPressed: () => showSyncSheet(context),
          icon: Icon(
              store.isInternetConnected ? Icons.cloud_done : Icons.cloud_off),
        ),
        const NotificationBell(),
      ],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          BigDoctorHeader(doctor: doctor),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: MetricTile(
                      'Today', '${appointments.length}', Icons.today)),
              Expanded(
                  child:
                      MetricTile('Pending', '$pending', Icons.pending_actions)),
              Expanded(
                  child: MetricTile(
                      'Earnings',
                      '₹${revenue.toStringAsFixed(0)}',
                      Icons.account_balance_wallet)),
            ],
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Row(
              children: [
                const Icon(Icons.video_camera_front, color: AppColors.green),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Online consultation availability',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Switch(
                  activeColor: AppColors.green,
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
            'Done': appointments
                .where((item) => item.status == 'completed')
                .length
                .toDouble(),
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
    final appointments =
        store.doctorService.appointmentsForDoctor(store, doctor.id);
    return AppPage(
      title: 'Appointments',
      subtitle: 'Accept, reject, cancel or complete bookings.',
      child: appointments.isEmpty
          ? const EmptyState(
              icon: Icons.event_busy,
              title: 'No appointments',
              text: 'Patient bookings will appear here instantly.')
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
                      .map((item) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => store.slotService
                                      .removeSlot(store, doctor, item),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          AppField(
              controller: slot,
              label: 'Add slot, e.g. 18:30',
              icon: Icons.schedule),
          PrimaryAction(
            label: 'Add slot',
            icon: Icons.add,
            onPressed: () =>
                store.slotService.addSlot(store, doctor, slot.text),
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
          ? const EmptyState(
              icon: Icons.group_off,
              title: 'No patient history',
              text: 'Accepted and completed bookings create history.')
          : ListView(
              padding: const EdgeInsets.all(18),
              children: patients.map((patient) {
                final patientBookings = store.bookings
                    .where((booking) =>
                        booking.patientId == patient.id &&
                        booking.doctorId == doctor.id)
                    .toList();
                return PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                            backgroundColor: AppColors.mint,
                            child: Icon(Icons.person, color: AppColors.green)),
                        title: Text(patient.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(
                            '+91 ${patient.mobile} • ${patientBookings.length} visits'),
                      ),
                      ...patientBookings.take(2).map((booking) => Text(
                          '• ${booking.date} ${booking.time} - ${booking.status}')),
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
          AppField(
              controller: fee, label: 'Clinic fee', icon: Icons.currency_rupee),
          AppField(
              controller: onlineFee,
              label: 'Online fee',
              icon: Icons.video_call),
          PrimaryAction(
            label: 'Update fees',
            icon: Icons.save,
            onPressed: () {
              store.doctorService.updateDoctor(
                store,
                doctor.copyWith(
                  fee: double.tryParse(fee.text) ?? doctor.fee,
                  onlineFee:
                      double.tryParse(onlineFee.text) ?? doctor.onlineFee,
                ),
              );
              showSuccess(
                  context, 'Updated', 'Patient side will show the new fee.');
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
      FilledButton.icon(
        onPressed: () =>
            store.bookingService.updateStatus(store, booking.id, 'accepted'),
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 16),
        label: const Text('Accept',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          minimumSize: const Size(100, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      OutlinedButton.icon(
        onPressed: () =>
            store.bookingService.updateStatus(store, booking.id, 'rejected'),
        icon: const Icon(Icons.cancel, color: AppColors.red, size: 16),
        label: const Text('Reject',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.red),
          foregroundColor: AppColors.red,
          minimumSize: const Size(100, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ];
  }
  if (booking.status == 'accepted') {
    return [
      if (booking.type == 'online')
        FilledButton.icon(
          onPressed: () =>
              push(context, OnlineConsultationScreen(booking: booking)),
          icon: const Icon(Icons.video_call, color: Colors.white, size: 16),
          label: const Text('Start call',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
            minimumSize: const Size(100, 36),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      FilledButton.icon(
        onPressed: () => push(context, PrescriptionScreen(booking: booking)),
        icon: const Icon(Icons.edit_note, color: Colors.white, size: 16),
        label: const Text('Prescription',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          minimumSize: const Size(100, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      OutlinedButton.icon(
        onPressed: () =>
            store.bookingService.updateStatus(store, booking.id, 'cancelled'),
        icon: const Icon(Icons.cancel, color: AppColors.red, size: 16),
        label: const Text('Cancel',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.red),
          foregroundColor: AppColors.red,
          minimumSize: const Size(100, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ];
  }
  return [];
}

class OnlineConsultationScreen extends StatefulWidget {
  final Booking booking;

  const OnlineConsultationScreen({super.key, required this.booking});

  @override
  State<OnlineConsultationScreen> createState() =>
      _OnlineConsultationScreenState();
}

class _OnlineConsultationScreenState extends State<OnlineConsultationScreen> {
  bool muted = false;
  bool cameraOn = true;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final doctor = store.doctorById(widget.booking.doctorId);
    return AppPage(
      title: 'Online Consultation',
      subtitle: '${widget.booking.date}, ${widget.booking.time}',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            height: 360,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(28),
              boxShadow: softShadow,
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.medical_services,
                            color: Colors.white, size: 54),
                      ),
                      const SizedBox(height: 16),
                      Text(doctor.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                      Text(widget.booking.patientName,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    width: 108,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Icon(
                      cameraOn ? Icons.person : Icons.videocam_off,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filled(
                  onPressed: () => setState(() => muted = !muted),
                  icon: Icon(muted ? Icons.mic_off : Icons.mic),
                ),
                IconButton.filled(
                  onPressed: () => setState(() => cameraOn = !cameraOn),
                  icon: Icon(cameraOn ? Icons.videocam : Icons.videocam_off),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppColors.red),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.call_end),
                ),
              ],
            ),
          ),
          const InfoStrip(
              icon: Icons.security,
              text:
                  'Secure demo room for this booking. Prescription can be written after consultation.'),
        ],
      ),
    );
  }
}

class PrescriptionScreen extends StatefulWidget {
  final Booking booking;

  const PrescriptionScreen({super.key, required this.booking});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final diagnosis = TextEditingController(text: 'Viral fever');
  final medicines =
      TextEditingController(text: 'Paracetamol 500mg twice daily for 3 days');
  final advice = TextEditingController(
      text: 'Hydration, rest, follow-up if fever persists.');

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
          AppField(
              controller: diagnosis,
              label: 'Diagnosis',
              icon: Icons.medical_information,
              maxLines: 2),
          AppField(
              controller: medicines,
              label: 'Medicines',
              icon: Icons.medication,
              maxLines: 4),
          AppField(
              controller: advice,
              label: 'Advice',
              icon: Icons.fact_check,
              maxLines: 3),
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
              showSuccess(
                  context, 'Prescription saved', 'Booking marked completed.');
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
        .where(
            (item) => item.status != 'cancelled' && item.status != 'rejected')
        .fold<double>(0, (sum, item) => sum + item.fee);
    return AppPage(
      title: 'Admin Dashboard',
      subtitle: 'Connected operations overview.',
      useGradientAppBar: true,
      actions: [
        IconButton(
          onPressed: () => showSyncSheet(context),
          icon: Icon(
              store.isInternetConnected ? Icons.cloud_done : Icons.cloud_off),
        ),
        const NotificationBell(),
        IconButton(
            onPressed: () => store.logout(), icon: const Icon(Icons.logout)),
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
              AdminMetric('Doctors', '${store.doctors.length}',
                  Icons.medical_services, AppColors.green),
              AdminMetric('Patients', '${store.patients.length}', Icons.groups,
                  const Color(0xFF2563EB)),
              AdminMetric('Bookings', '${store.bookings.length}',
                  Icons.event_note, AppColors.amber),
              AdminMetric('Revenue', '₹${revenue.toStringAsFixed(0)}',
                  Icons.currency_rupee, const Color(0xFF7C3AED)),
            ],
          ),
          const SectionTitle('Booking status chart'),
          MiniBarChart(values: {
            'Pending': store.bookings
                .where((e) => e.status == 'pending')
                .length
                .toDouble(),
            'Accepted': store.bookings
                .where((e) => e.status == 'accepted')
                .length
                .toDouble(),
            'Done': store.bookings
                .where((e) => e.status == 'completed')
                .length
                .toDouble(),
            'Cancel': store.bookings
                .where((e) => e.status == 'cancelled')
                .length
                .toDouble(),
          }),
          const SectionTitle('Pending doctor approvals'),
          if (store.pendingDoctors.isEmpty)
            const EmptyState(
                icon: Icons.verified_user,
                title: 'No pending doctors',
                text: 'New registrations will appear here.')
          else
            ...store.pendingDoctors
                .map((doctor) => AdminDoctorCard(doctor: doctor)),
          const SectionTitle('Patients list'),
          PremiumCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(AppColors.mint.withOpacity(0.4)),
                horizontalMargin: 12,
                columnSpacing: 24,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Mobile',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'District',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
                rows: store.patients
                    .map((user) => DataRow(cells: [
                          DataCell(
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              user.mobile,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              user.district,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
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
    final doctors = [...store.doctors]..sort((a, b) {
        const priority = {'pending': 0, 'approved': 1, 'rejected': 2};
        final statusCompare =
            (priority[a.status] ?? 9).compareTo(priority[b.status] ?? 9);
        if (statusCompare != 0) return statusCompare;
        return a.name.compareTo(b.name);
      });
    return AppPage(
      title: 'Manage Doctors',
      subtitle:
          '${store.pendingDoctors.length} pending approvals - ${store.approvedDoctors.length} approved doctors.',
      actions: [
        IconButton(
            onPressed: () => showAdminDoctorEditor(context),
            icon: const Icon(Icons.add)),
      ],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children:
            doctors.map((doctor) => AdminDoctorCard(doctor: doctor)).toList(),
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
            title: Text(
              doctor.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                fontFamily: 'Poppins',
                color: AppColors.ink,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${doctor.specialty} • ₹${doctor.fee.toStringAsFixed(0)} • ${doctor.district}',
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  color: AppColors.muted,
                ),
              ),
            ),
            trailing: StatusChip(doctor.status, statusColor(doctor.status)),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              if (doctor.status == 'pending')
                TextButton(
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () =>
                      store.adminService.approveDoctor(store, doctor.id),
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                  ),
                ),
              if (doctor.status == 'pending')
                TextButton(
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () =>
                      store.adminService.rejectDoctor(store, doctor.id),
                  child: const Text(
                    'Reject',
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                  ),
                ),
              TextButton(
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => showAdminDoctorEditor(context, doctor: doctor),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () =>
                    store.adminService.deleteDoctor(store, doctor.id),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
              ),
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
                      onSelected: (status) => store.bookingService
                          .updateStatus(store, booking.id, status),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'pending', child: Text('Pending')),
                        PopupMenuItem(
                            value: 'accepted', child: Text('Accepted')),
                        PopupMenuItem(
                            value: 'rejected', child: Text('Rejected')),
                        PopupMenuItem(
                            value: 'cancelled', child: Text('Cancelled')),
                        PopupMenuItem(
                            value: 'completed', child: Text('Completed')),
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
        IconButton(
            onPressed: () => showHospitalEditor(context),
            icon: const Icon(Icons.add_business)),
      ],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: store.hospitals
            .map((hospital) => HospitalCard(
                  hospital: hospital,
                  trailing: IconButton(
                    onPressed: () => store.hospitalService
                        .deleteHospital(store, hospital.id),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        children: [
          PremiumCard(
            child: SwitchListTile(
              activeColor: AppColors.green,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              value: store.maintenanceMode,
              onChanged: (value) =>
                  store.adminService.setMaintenanceMode(store, value),
              title: const Text(
                'Maintenance mode',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: AppColors.ink,
                ),
              ),
              subtitle: const Text(
                'Backend-ready app setting stored locally.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SectionTitle('Manage specialties',
              action: 'Add',
              onTap: () => promptText(context, 'Add specialty', 'Specialty')
                      .then((value) {
                    if (value != null) {
                      store.adminService.addSpecialty(store, value);
                    }
                  })),
          const SizedBox(height: 8),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: store.specialties
                  .map((item) => Chip(
                        label: Text(
                          item,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: AppColors.mint,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              color: AppColors.green, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                      ))
                  .toList()),
          const SizedBox(height: 16),
          SectionTitle('Manage banners / health tips',
              action: 'Add',
              onTap: () =>
                  promptText(context, 'Add health tip', 'Tip').then((value) {
                    if (value != null) {
                      store.adminService.addHealthTip(store, value);
                    }
                  })),
          const SizedBox(height: 8),
          ...store.healthTips
              .map((tip) => InfoStrip(icon: Icons.tips_and_updates, text: tip)),
          const SizedBox(height: 16),
          const SectionTitle('Ambulance requests'),
          const SizedBox(height: 8),
          ...store.ambulances.map((amb) => InfoStrip(
              icon: Icons.emergency,
              text: '${amb.name} • ${amb.district} • ${amb.phone}')),
          const SizedBox(height: 16),
          const SectionTitle('Patient ambulance requests'),
          const SizedBox(height: 8),
          if (store.ambulanceRequests.isEmpty)
            const EmptyState(
                icon: Icons.emergency,
                title: 'No ambulance requests',
                text: 'Patient emergency requests will appear here.')
          else
            ...store.ambulanceRequests.map((request) => AmbulanceRequestCard(
                  request: request,
                  actions: [
                    TextButton.icon(
                      onPressed: () => store.ambulanceService
                          .updateRequestStatus(store, request.id, 'dispatched'),
                      icon: const Icon(Icons.check_circle,
                          color: AppColors.green),
                      label: const Text('Dispatch'),
                    ),
                    TextButton.icon(
                      onPressed: () => store.ambulanceService
                          .updateRequestStatus(store, request.id, 'closed'),
                      icon: const Icon(Icons.done_all, color: AppColors.green),
                      label: const Text('Close'),
                    ),
                  ],
                )),
          const SizedBox(height: 16),
          const SectionTitle('Reports'),
          const SizedBox(height: 8),
          ReportCard(
              label: 'Doctor approval conversion',
              value:
                  '${store.doctors.where((e) => e.status == 'approved').length}/${store.doctors.length} approved'),
          ReportCard(
              label: 'Average booking value',
              value: '₹${averageBookingValue(store).toStringAsFixed(0)}'),
          ReportCard(
              label: 'Online availability',
              value:
                  '${store.approvedDoctors.where((e) => e.isOnlineAvailable).length} doctors online'),
          const SizedBox(height: 16),
          ActionTile(
              icon: Icons.logout,
              title: 'Logout admin',
              subtitle: 'Return to role selection',
              danger: true,
              onTap: () => store.logout()),
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
        children: hospitals
            .map((hospital) => HospitalCard(hospital: hospital))
            .toList(),
      ),
    );
  }
}

class AmbulancePatientScreen extends StatelessWidget {
  const AmbulancePatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final myRequests = store.ambulanceRequests
        .where((request) => request.patientId == store.currentUser?.id)
        .toList();
    return AppPage(
      title: 'Ambulance',
      subtitle: 'Emergency providers, request tracking and one-tap calling.',
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
          if (store.ambulances.isNotEmpty)
            PrimaryAction(
              label: 'Request nearest ambulance',
              icon: Icons.emergency_share,
              onPressed: () => push(context,
                  AmbulanceRequestScreen(provider: store.ambulances.first)),
            ),
          if (myRequests.isNotEmpty) ...[
            const SectionTitle('My ambulance requests'),
            ...myRequests
                .map((request) => AmbulanceRequestCard(request: request)),
          ],
          ...store.ambulances.map((amb) => PremiumCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEBEE),
                      child: Icon(Icons.local_taxi, color: AppColors.red)),
                  title: Text(amb.name,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                      '${amb.district} • ${amb.isAvailable ? 'Available' : 'Busy'}'),
                  trailing: IconButton(
                    onPressed: () => store.ambulanceService.callProvider(amb),
                    icon: const Icon(Icons.call, color: AppColors.green),
                  ),
                  onTap: () =>
                      push(context, AmbulanceRequestScreen(provider: amb)),
                ),
              )),
        ],
      ),
    );
  }
}

class AmbulanceRequestScreen extends StatefulWidget {
  final AmbulanceProviderModel provider;

  const AmbulanceRequestScreen({super.key, required this.provider});

  @override
  State<AmbulanceRequestScreen> createState() => _AmbulanceRequestScreenState();
}

class _AmbulanceRequestScreenState extends State<AmbulanceRequestScreen> {
  final address = TextEditingController();
  final emergency = TextEditingController(text: 'Emergency pickup');

  @override
  void dispose() {
    address.dispose();
    emergency.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final user = store.currentUser!;
    return AppPage(
      title: 'Request Ambulance',
      subtitle: widget.provider.name,
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          PremiumHeader(
            title: widget.provider.name,
            subtitle: '${widget.provider.district} - ${widget.provider.phone}',
            icon: Icons.local_taxi,
          ),
          const SizedBox(height: 16),
          InfoStrip(
              icon: Icons.person,
              text: '${user.name} - +91 ${user.mobile} - ${user.district}'),
          AppField(
            controller: address,
            label: 'Pickup address / landmark',
            icon: Icons.location_on,
            maxLines: 2,
          ),
          AppField(
            controller: emergency,
            label: 'Emergency type',
            icon: Icons.emergency,
          ),
          PrimaryAction(
            label: 'Send ambulance request',
            icon: Icons.send,
            onPressed: () async {
              if (address.text.trim().isEmpty) {
                showSuccess(context, 'Address needed',
                    'Please enter pickup address or landmark.');
                return;
              }
              final request = await store.ambulanceService.requestAmbulance(
                store,
                provider: widget.provider,
                pickupAddress: address.text,
                emergencyType: emergency.text,
              );
              if (!context.mounted) return;
              showSuccess(context, 'Request sent',
                  'Admin can see this ambulance request now.');
              pushReplacement(
                  context, AmbulanceRequestReceiptScreen(request: request));
            },
          ),
          SecondaryAction(
            label: 'Call provider now',
            icon: Icons.call,
            onPressed: () =>
                store.ambulanceService.callProvider(widget.provider),
          ),
        ],
      ),
    );
  }
}

class AmbulanceRequestReceiptScreen extends StatelessWidget {
  final AmbulanceRequest request;

  const AmbulanceRequestReceiptScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Ambulance requested',
      subtitle: 'Live status from admin panel.',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Icon(Icons.check_circle, color: AppColors.green, size: 84),
          const SizedBox(height: 16),
          AmbulanceRequestCard(request: request),
          PrimaryAction(
            label: 'Back to ambulance',
            icon: Icons.local_taxi,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class AmbulanceRequestCard extends StatelessWidget {
  final AmbulanceRequest request;
  final List<Widget> actions;

  const AmbulanceRequestCard({
    super.key,
    required this.request,
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
              const CircleAvatar(
                backgroundColor: Color(0xFFFFEBEE),
                child: Icon(Icons.local_taxi, color: AppColors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(request.patientName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 17)),
              ),
              StatusChip(request.status, statusColor(request.status)),
            ],
          ),
          const SizedBox(height: 12),
          InfoLine(Icons.phone, 'Mobile', '+91 ${request.patientMobile}'),
          InfoLine(Icons.location_on, 'Pickup', request.pickupAddress),
          InfoLine(Icons.emergency, 'Emergency', request.emergencyType),
          InfoLine(Icons.map, 'District', request.district),
          if (actions.isNotEmpty)
            Wrap(alignment: WrapAlignment.end, spacing: 8, children: actions),
        ],
      ),
    );
  }
}

TextStyle get sectionStyle => const TextStyle(
      fontSize: 17, // Section heading: FontWeight.w700, size 17
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    );

List<BoxShadow> get softShadow => const [
      BoxShadow(
        color: Color(0x14000000), // shadow: 0px 2px 12px rgba(0,0,0,0.08)
        blurRadius: 12,
        offset: Offset(0, 2),
        spreadRadius: 0,
      ),
    ];

void push(BuildContext context, Widget screen) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (_, animation, __) => screen,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.04, 0.02), end: Offset.zero)
              .animate(animation),
          child: child,
        ),
      );
    },
  ));
}

void pushReplacement(BuildContext context, Widget screen) {
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => screen));
}

InputDecoration inputDecoration(String label, IconData icon) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.green), // leading icon green
      filled: true,
      fillColor: Colors.white, // white bg
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // border radius 10px
        borderSide:
            const BorderSide(color: Color(0xFFE0E0E0)), // grey border #E0E0E0
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
            color: AppColors.green, width: 1.5), // focus border green
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
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
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
  final bool useGradientAppBar;

  const AppPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
    this.actions = const [],
    this.useGradientAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = useGradientAppBar ? Colors.white : AppColors.ink;
    final subtitleColor = useGradientAppBar ? Colors.white70 : AppColors.muted;
    final leadingColor = useGradientAppBar ? Colors.white : AppColors.green;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: showBack ? BackButton(color: leadingColor) : null,
        backgroundColor: Colors.transparent,
        flexibleSpace: useGradientAppBar
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.green, AppColors.deepGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              )
            : Container(color: Colors.white),
        elevation: 0,
        titleSpacing: showBack ? 0 : 16,
        bottom: useGradientAppBar
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: Colors.black.withOpacity(0.04),
                  height: 1.0,
                ),
              ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: titleColor,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        actions: actions.map((w) {
          if (useGradientAppBar) {
            return Theme(
              data: Theme.of(context).copyWith(
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              child: w,
            );
          }
          return w;
        }).toList(),
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
      child: Text(text,
          style: const TextStyle(
              color: AppColors.red, fontWeight: FontWeight.w700)),
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
      child: Container(
        height: 52, // height 52px
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.green,
              AppColors.accent
            ], // gradient linear from #0B6E4F to #00A878
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12), // border radius 12px
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.2), // slight shadow
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ],
          ),
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
      child: SizedBox(
        height: 52, // height 52px
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.green,
            backgroundColor: Colors.white, // white bg
            side: const BorderSide(
                color: AppColors.green, width: 1.5), // green border
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // border radius 12px
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.green),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green), // green text
              ),
            ],
          ),
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
            child: Icon(icon, color: AppColors.green, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepGreen, AppColors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, color: AppColors.green, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
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
      margin: const EdgeInsets.only(bottom: 12), // Between cards gap: 12px
      decoration: BoxDecoration(
        color: Colors.white, // Card BG: #FFFFFF
        borderRadius: BorderRadius.circular(16), // Card border radius: 16px
        boxShadow: softShadow, // shadow: 0px 2px 12px rgba(0,0,0,0.08)
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16), // Inner card padding: 16px
            child: child,
          ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Poppins',
                color: AppColors.green,
              ),
            ),
          ),
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

  const NavBar({
    super.key,
    required this.index,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = index == i;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 70,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppColors.mint : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected ? AppColors.green : AppColors.muted,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 10.5,
                          color: isSelected ? AppColors.green : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
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
        gradient:
            const LinearGradient(colors: [AppColors.green, Color(0xFF0CA678)]),
        borderRadius: BorderRadius.circular(32),
        boxShadow: softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Find trusted care',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text(
              'Doctors, hospitals, ambulance and health card in one app.',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 22),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(22)),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.green),
                  SizedBox(width: 12),
                  Expanded(
                      child: Text('Search doctor or specialty...',
                          style: TextStyle(color: AppColors.muted))),
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
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 4), // Spacing between cards
      child: PremiumCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.green, size: 24), // green icon on top
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700, // bold number
                fontFamily: 'Poppins',
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted, // grey label
                fontSize: 11,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
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
      childAspectRatio: 0.85,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: items
          .map((item) => InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.green,
                            AppColors.accent
                          ], // green bg gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.green.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(item.icon,
                            color: Colors.white, size: 28), // icon size 28
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600, // semibold label below
                        fontSize: 13,
                        color: AppColors.ink,
                      ),
                    ),
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
          if (action != null)
            TextButton(onPressed: onTap, child: Text(action!)),
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
                    Expanded(
                        child: Text(doctor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                color: AppColors.ink))),
                    if (doctor.isOnlineAvailable)
                      const StatusChip('Online', AppColors.green),
                  ],
                ),
                const SizedBox(height: 4),
                Text(doctor.specialty,
                    style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Poppins')),
                Text(doctor.degree,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.amber, size: 18),
                    Text(' ${doctor.rating} (${doctor.reviews})',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            color: AppColors.amber)),
                    const Spacer(),
                    Text('₹${doctor.fee.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            fontSize: 18)),
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
    final isCardio = doctor.specialty.contains('Cardio') ||
        doctor.specialty.contains('हृदय');
    final isGyne = doctor.specialty.contains('Gyne') ||
        doctor.specialty.contains('स्त्री');
    return CircleAvatar(
      radius: 32,
      backgroundColor: isCardio
          ? const Color(0xFFFFECEC)
          : isGyne
              ? const Color(0xFFFFE5F1)
              : AppColors.mint,
      child: Icon(Icons.person,
          color: isCardio
              ? const Color(0xFFEF4444)
              : isGyne
                  ? const Color(0xFFEC4899)
                  : AppColors.green,
          size: 32),
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
          Text(
            doctor.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            doctor.specialty,
            style: const TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${doctor.degree} • ${doctor.experience} yrs experience',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
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
    Color textCol = color;
    Color bgCol = color.withOpacity(0.12);

    switch (label.toLowerCase()) {
      case 'pending':
      case 'requested':
        textCol = const Color(0xFFE65100);
        bgCol = const Color(0xFFFFF3E0);
        break;
      case 'accepted':
      case 'upcoming':
      case 'approved':
        textCol = const Color(0xFF1565C0);
        bgCol = const Color(0xFFE3F2FD);
        break;
      case 'completed':
      case 'closed':
      case 'dispatched':
        textCol = const Color(0xFF2E7D32);
        bgCol = const Color(0xFFE8F5E9);
        break;
      case 'cancelled':
      case 'rejected':
        textCol = const Color(0xFFC62828);
        bgCol = const Color(0xFFFFEBEE);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textCol,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

Color statusColor(String status) {
  return switch (status) {
    'accepted' ||
    'approved' ||
    'completed' ||
    'dispatched' ||
    'closed' =>
      AppColors.green,
    'pending' || 'requested' => AppColors.amber,
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
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(booking.status, statusColor(booking.status)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                if (showPatient)
                  InfoLine(Icons.person_outline, 'Patient',
                      '${booking.patientName} • ${booking.patientMobile}'),
                InfoLine(Icons.event_outlined, 'Date & time',
                    '${booking.date}, ${booking.time}'),
                InfoLine(
                    Icons.video_call_outlined,
                    'Type',
                    booking.type == 'online'
                        ? 'Online consultation'
                        : 'Clinic visit'),
                if (booking.symptoms.isNotEmpty)
                  InfoLine(Icons.notes_outlined, 'Symptoms', booking.symptoms),
                InfoLine(Icons.currency_rupee_outlined, 'Fee',
                    '₹${booking.fee.toStringAsFixed(0)}'),
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: a,
                );
              }).toList(),
            ),
          ],
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
          Icon(icon, color: AppColors.muted, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Poppins',
                color: AppColors.ink,
              ),
            ),
          ),
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
        leading: const CircleAvatar(
            backgroundColor: AppColors.mint,
            child: Icon(Icons.local_hospital, color: AppColors.green)),
        title: Text(hospital.name,
            style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle:
            Text('${hospital.type} • ${hospital.address} • ${hospital.phone}'),
        trailing: trailing,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const EmptyState(
      {super.key, required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.mint,
                child: Icon(icon, color: AppColors.green, size: 38)),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted)),
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
                      Expanded(
                          child: Text(row.$1,
                              style: const TextStyle(color: AppColors.muted))),
                      Text(row.$2,
                          style: const TextStyle(fontWeight: FontWeight.w900)),
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
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHero extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;

  const ProfileHero(
      {super.key,
      required this.name,
      required this.subtitle,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.mint,
              child: Icon(icon, color: AppColors.green, size: 46)),
          const SizedBox(height: 14),
          Text(name,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
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
          CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: danger ? AppColors.red : AppColors.ink)),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
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
        children: values.entries.map((entry) {
          final percentage = max > 0 ? (entry.value / max) : 0.0;
          final color = statusColor(entry.key.toLowerCase());
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 10,
                              width: constraints.maxWidth * percentage,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color, color.withOpacity(0.7)],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 24,
                  child: Text(
                    entry.value.toStringAsFixed(0),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
    return PremiumCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: AppColors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

double averageBookingValue(DoctorMitraStore store) {
  if (store.bookings.isEmpty) return 0;
  return store.bookings.fold<double>(0, (sum, item) => sum + item.fee) /
      store.bookings.length;
}

Future<String?> promptText(
    BuildContext context, String title, String label) async {
  final controller = TextEditingController();
  final value = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
          controller: controller,
          decoration: inputDecoration(label, Icons.edit)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save')),
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
        ...store.healthTips
            .map((tip) => InfoStrip(icon: Icons.tips_and_updates, text: tip)),
      ],
    ),
  );
}

void showNotifications(BuildContext context) {
  final store = context.read<DoctorMitraStore>();
  final user = store.currentUser;
  final notes = user == null
      ? <AppNotification>[]
      : store.notificationService.forUser(store, user.id);
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Notifications', style: sectionStyle),
        const SizedBox(height: 12),
        if (notes.isEmpty)
          const EmptyState(
              icon: Icons.notifications_off,
              title: 'No notifications',
              text: 'Important updates will arrive here.'),
        ...notes.map((note) => InfoStrip(
            icon: Icons.notifications, text: '${note.title}: ${note.body}')),
      ],
    ),
  );
}

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DoctorMitraStore>();
    final user = store.currentUser;
    final count = user == null
        ? 0
        : store.notificationService.forUser(store, user.id).length;
    return IconButton(
      onPressed: () => showNotifications(context),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none),
          if (count > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
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
            icon:
                store.isInternetConnected ? Icons.cloud_done : Icons.cloud_off,
            text: 'Mode: ${store.syncMode}',
          ),
          InfoStrip(
            icon: Icons.api,
            text: store._api.endpointLabel,
          ),
          InfoStrip(
            icon: Icons.schedule,
            text: store.lastSyncedAt == null
                ? 'Auto sync: every 12 seconds'
                : 'Last sync: ${DateFormat('dd MMM, hh:mm a').format(store.lastSyncedAt!)}',
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
            AppField(
                controller: district,
                label: 'District',
                icon: Icons.location_on),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            store.patientService.updateProfile(store,
                name: name.text, mobile: mobile.text, district: district.text);
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
  final specialty =
      TextEditingController(text: doctor?.specialty ?? store.specialties.first);
  final degree = TextEditingController(text: doctor?.degree ?? 'MBBS');
  final fee =
      TextEditingController(text: (doctor?.fee ?? 500).toStringAsFixed(0));
  final district = TextEditingController(text: doctor?.district ?? 'Patna');
  final clinic =
      TextEditingController(text: doctor?.clinicName ?? 'Doctor Mitra Clinic');
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(doctor == null ? 'Add doctor' : 'Edit doctor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppField(controller: name, label: 'Name', icon: Icons.person),
            AppField(
                controller: specialty,
                label: 'Specialty',
                icon: Icons.category),
            AppField(controller: degree, label: 'Degree', icon: Icons.school),
            AppField(controller: fee, label: 'Fee', icon: Icons.currency_rupee),
            AppField(
                controller: district,
                label: 'District',
                icon: Icons.location_on),
            AppField(controller: clinic, label: 'Clinic', icon: Icons.business),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final userId = doctor?.userId ?? _uuid.v4();
            if (doctor == null) {
              store.users.add(AppUser(
                id: userId,
                role: 'doctor',
                name: name.text,
                mobile: '9000000000',
                email:
                    '${name.text.toLowerCase().replaceAll(' ', '')}@doctormitra.in',
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
                registrationNumber: doctor?.registrationNumber ??
                    'BRMC-${DateTime.now().millisecondsSinceEpoch}',
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
            AppField(
                controller: name,
                label: 'Hospital name',
                icon: Icons.local_hospital),
            AppField(
                controller: district,
                label: 'District',
                icon: Icons.location_on),
            AppField(controller: address, label: 'Address', icon: Icons.map),
            AppField(controller: phone, label: 'Phone', icon: Icons.phone),
            AppField(controller: type, label: 'Type', icon: Icons.category),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
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

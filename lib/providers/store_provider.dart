import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ambulance_model.dart';
import '../models/booking_model.dart';
import '../models/doctor_model.dart';
import '../models/health_card_model.dart';
import '../models/hospital_model.dart';
import '../models/notification_model.dart';
import '../models/prescription_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/business_services.dart';
import '../services/local_storage.dart';

const _uuid = Uuid();

class DoctorMitraStore extends ChangeNotifier {
  final LocalStorageLayer _storage = LocalStorageLayer();
  final CloudApiLayer _api = CloudApiLayer();
  CloudApiLayer get api => _api;
  Timer? _autoSyncTimer;
  bool _pullInFlight = false;
  bool _writeInFlight = false;

  bool isLoading = true;
  bool isInternetConnected = false;
  String syncMode = CloudApiLayer.isConfigured ? 'Connecting...' : 'Local demo';
  DateTime? lastSyncedAt;
  AppUser? currentUser;
  String? token;
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

    final remote = await _api.readState(token: token);
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

    // Auto-login from Firebase Auth if session is active
    if (!AuthService.isMockMode) {
      try {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null && firebaseUser.phoneNumber != null) {
          final phone = AuthService.normalizeMobile(firebaseUser.phoneNumber!);
          var user = users
              .where((u) => u.role == 'patient' && u.mobile == phone)
              .firstOrNull;
          if (user == null) {
            user = AppUser(
              id: firebaseUser.uid,
              role: 'patient',
              name: 'Patient $phone',
              mobile: phone,
              email: '',
              district: 'Patna',
              createdAt: DateTime.now().toIso8601String(),
            );
            users.add(user);
            healthCards.add(
              HealthCard(
                id: _uuid.v4(),
                userId: user.id,
                bloodGroup: 'Not set',
                allergies: 'Not set',
                medications: 'Not set',
                emergencyContact: phone,
              ),
            );
          }
          currentUser = user;
          await _saveLocalOnly();
        }
      } catch (e) {
        debugPrint("store_provider: Firebase auto-login check failed: $e");
      }
    }

    isLoading = false;
    _startAutoSync();
    
    // Initialize notification service listeners
    notificationService.init(this);
    
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
      final remote = await _api.readState(token: token);
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
    if (raw.containsKey('token')) {
      token = raw['token'] as String?;
    }
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
      state['token'] = token;
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
    final response = await _api.runAction(type, payload, token: token);
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
    notificationService.init(this);
  }

  Future<void> logout() async {
    currentUser = null;
    token = null;
    await persist();
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }
}

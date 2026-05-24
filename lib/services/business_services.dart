import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/ambulance_model.dart';
import '../models/booking_model.dart';
import '../models/doctor_model.dart';
import '../models/health_card_model.dart';
import '../models/hospital_model.dart';
import '../models/notification_model.dart';
import '../models/prescription_model.dart';
import '../models/user_model.dart';
import '../providers/store_provider.dart';
import '../services/api_service.dart';

const _uuid = Uuid();

class AuthService {
  static String? _verificationId;

  static String normalizeMobile(String mobile) =>
      mobile.replaceAll(RegExp(r'\D'), '');

  static bool get isMockMode => Firebase.apps.isEmpty;

  Future<String?> sendPatientOtp({
    required String mobile,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onFailed,
  }) async {
    final normalized = normalizeMobile(mobile);
    if (normalized.length < 10) return 'Enter a valid 10 digit mobile number';

    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final response = await CloudApiLayer().sendOtp(normalized);
      if (response != null) {
        if (response['success'] == true) {
          _verificationId = 'api_verification_id';
          onCodeSent('api_verification_id');
          return null;
        } else {
          onFailed(response['error'] as String? ?? 'Failed to send OTP code');
          return response['error'] as String?;
        }
      }
    }

    if (isMockMode || normalized == '9876543210' || normalized == '1234567890') {
      debugPrint("AuthService: Using local mock mode.");
      _verificationId = 'mock_verification_id';
      onCodeSent('mock_verification_id');
      return null;
    }

    try {
      final phone = '+91$normalized';
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint("verifyPhoneNumber: verificationCompleted instantly.");
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("verifyPhoneNumber: failed: ${e.message}");
          onFailed(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint("verifyPhoneNumber: codeSent successfully.");
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> verifyPatientOtp({
    required String mobile,
    required String otp,
    String? verificationId,
  }) async {
    final normalized = normalizeMobile(mobile);
    if (normalized.length != 10) return 'Enter a valid 10 digit mobile number';

    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final response = await CloudApiLayer().verifyOtp(normalized, otp);
      if (response != null) {
        if (response['success'] == true) {
          return null;
        } else {
          return response['error'] as String? ?? 'Invalid verification code';
        }
      }
    }

    if (isMockMode || normalized == '9876543210' || normalized == '1234567890') {
      if (otp.trim() == '123456') {
        return null;
      }
      return 'Invalid verification code. Use 123456 in mock mode.';
    }

    try {
      final effectiveVerificationId = verificationId ?? _verificationId;
      if (effectiveVerificationId == null) {
        return 'Verification ID is missing. Send OTP first.';
      }
      final credential = PhoneAuthProvider.credential(
        verificationId: effectiveVerificationId,
        smsCode: otp.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Invalid OTP code';
    } catch (e) {
      return 'Verification failed: ${e.toString()}';
    }
  }

  AppUser? patientByMobile(DoctorMitraStore store, String mobile) {
    final normalized = normalizeMobile(mobile);
    return store.users
        .where((item) => item.role == 'patient' && item.mobile == normalized)
        .firstOrNull;
  }

  Future<String?> patientOtpLogin(
    DoctorMitraStore store, {
    required String mobile,
    required String otp,
    String? verificationId,
  }) async {
    final normalized = normalizeMobile(mobile);
    if (InternetApiLayer.baseUrl.trim().isNotEmpty) {
      final response = await store.api.verifyOtp(normalized, otp);
      if (response != null) {
        if (response['success'] == true) {
          final isNewUser = response['isNewUser'] == true;
          final token = response['token'] as String?;
          store.token = token;
          if (isNewUser) {
            // New user: register dynamically on backend using setup-profile REST API
            final registerResponse = await store.api.setupProfile(
              tempToken: token!,
              name: 'Patient $normalized',
              district: 'Patna',
              emergencyContact: normalized,
            );
            if (registerResponse != null && registerResponse['success'] == true) {
              final finalToken = registerResponse['token'] as String?;
              store.token = finalToken;
              final userJson = registerResponse['user'];
              if (userJson != null) {
                final user = AppUser.fromJson(userJson);
                if (store.users.where((u) => u.id == user.id).isEmpty) {
                  store.users.add(user);
                }
                await store.loginAs(user);
                return null;
              }
            } else {
              return registerResponse?['error'] as String? ?? 'Profile setup failed';
            }
          } else {
            // Existing user
            final userJson = response['user'];
            if (userJson != null) {
              final user = AppUser.fromJson(userJson);
              if (store.users.where((u) => u.id == user.id).isEmpty) {
                store.users.add(user);
              }
              await store.loginAs(user);
              return null;
            }
          }
        } else {
          return response['error'] as String? ?? 'Invalid verification code';
        }
      }
    }

    final otpError = await verifyPatientOtp(
      mobile: mobile,
      otp: otp,
      verificationId: verificationId,
    );
    if (otpError != null) return otpError;
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

  Future<String?> registerPatient(
    DoctorMitraStore store, {
    required String name,
    required String mobile,
    required String district,
    required String emergencyContact,
  }) async {
    final normalized = normalizeMobile(mobile);
    final normalizedEmergency = normalizeMobile(emergencyContact);
    if (name.trim().length < 2) return 'Enter patient full name';
    if (normalized.length != 10) return 'Enter a valid 10 digit mobile number';
    if (district.trim().isEmpty) return 'Enter district';
    if (normalizedEmergency.isNotEmpty && normalizedEmergency.length != 10) {
      return 'Enter a valid emergency contact';
    }

    if (InternetApiLayer.baseUrl.trim().isNotEmpty && store.token != null) {
      final error = await store.runRemoteAction(
        'UPDATE_PROFILE',
        {
          'name': name.trim(),
          'district': district.trim(),
        },
      );
      if (error == null) {
        await store.patientService.updateHealthCard(
          store,
          bloodGroup: store.currentHealthCard?.bloodGroup ?? 'Not set',
          allergies: store.currentHealthCard?.allergies ?? 'Not set',
          medications: store.currentHealthCard?.medications ?? 'Not set',
          emergencyContact: normalizedEmergency.isEmpty ? normalized : normalizedEmergency,
        );
        return null;
      }
    }

    var user = patientByMobile(store, normalized);
    if (user == null) {
      user = AppUser(
        id: _uuid.v4(),
        role: 'patient',
        name: name.trim(),
        mobile: normalized,
        email: '',
        district: district.trim(),
        createdAt: DateTime.now().toIso8601String(),
      );
      store.users.add(user);
    } else {
      final index = store.users.indexWhere((item) => item.id == user!.id);
      user = user.copyWith(
        name: name.trim(),
        mobile: normalized,
        district: district.trim(),
      );
      store.users[index] = user;
    }

    if (store.healthCards.where((card) => card.userId == user!.id).isEmpty) {
      store.healthCards.add(
        HealthCard(
          id: _uuid.v4(),
          userId: user.id,
          bloodGroup: 'Not set',
          allergies: 'Not set',
          medications: 'Not set',
          emergencyContact:
              normalizedEmergency.isEmpty ? normalized : normalizedEmergency,
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
      final response = await store.api.adminLogin(email, password);
      if (response != null) {
        if (response['success'] == true) {
          store.token = response['token'] as String?;
          final userJson = response['admin'];
          if (userJson != null) {
            final user = AppUser(
              id: 'admin-12032',
              role: 'admin',
              name: userJson['name'] ?? 'Super Admin Mitra',
              mobile: '',
              email: userJson['email'] ?? email,
              district: 'Patna',
              createdAt: DateTime.now().toIso8601String(),
            );
            await store.loginAs(user);
            return null;
          }
        } else {
          return response['error'] as String? ?? 'Invalid admin credentials';
        }
      }
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
      final response = await store.api.doctorLogin(email, password);
      if (response != null) {
        if (response['success'] == true) {
          store.token = response['token'] as String?;
          final doctorJson = response['doctor'];
          if (doctorJson != null) {
            final user = AppUser(
              id: doctorJson['_id'] ?? doctorJson['id'],
              role: 'doctor',
              name: doctorJson['name'],
              mobile: doctorJson['phone'] ?? '',
              email: doctorJson['email'] ?? email,
              district: 'Patna',
              createdAt: DateTime.now().toIso8601String(),
            );
            final doctorObj = Doctor.fromJson({
              ...doctorJson,
              'id': doctorJson['_id'] ?? doctorJson['id'],
              'userId': doctorJson['_id'] ?? doctorJson['id'],
            });
            if (store.doctors.where((d) => d.id == doctorObj.id).isEmpty) {
              store.doctors.add(doctorObj);
            }
            await store.loginAs(user);
            return null;
          }
        } else {
          return response['error'] as String? ?? 'Doctor account not found';
        }
      }
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
      final response = await store.api.doctorRegister({
        'name': name,
        'email': email,
        'password': password,
        'phone': mobile.replaceAll(RegExp(r'\D'), ''),
        'speciality': specialty,
        'degree': degree,
        'registrationNumber': registrationNumber,
        'clinicName': clinicName,
        'district': district,
        'fee': fee,
      });
      if (response != null) {
        if (response['success'] == true) {
          return null;
        } else {
          return response['error'] as String? ?? 'Registration failed';
        }
      }
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

  static bool get isMockMode => Firebase.apps.isEmpty;

  Future<void> init(DoctorMitraStore store) async {
    if (isMockMode) {
      debugPrint("NotificationService: Operating in local mock mode.");
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        _scheduleMockNotification(store);
      }
      return;
    }

    try {
      // 1. Request notifications permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('NotificationService: Permission status: ${settings.authorizationStatus}');

      // 2. Fetch FCM device token
      final token = await messaging.getToken();
      if (token != null) {
        debugPrint("NotificationService: Registered FCM Device Token: $token");
      }

      // 3. Listen to token refresh
      messaging.onTokenRefresh.listen((newToken) {
        debugPrint("NotificationService: FCM Token Refreshed: $newToken");
      });

      // 4. Foreground notification listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('NotificationService: Received foreground push message');
        if (message.notification != null) {
          final title = message.notification!.title ?? 'New Notification';
          final body = message.notification!.body ?? '';
          debugPrint('NotificationService: Push: $title - $body');
          
          if (store.currentUser != null) {
            store.addNotification(
              userId: store.currentUser!.id,
              title: title,
              body: body,
            );
            store.persist();
          }
        }
      });

      // 5. Background message click listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('NotificationService: App opened via background push message click');
      });

    } catch (e) {
      debugPrint("NotificationService: Initialization failed: $e");
    }
  }

  // Simulated push helper in mock mode
  void _scheduleMockNotification(DoctorMitraStore store) {
    // Schedule a simulated delayed push notification to trigger 15s after initialization
    Future.delayed(const Duration(seconds: 15), () {
      if (store.currentUser == null) return;
      
      final currentUserId = store.currentUser!.id;
      final mockPushs = [
        {
          'title': 'Welcome to Doctor Mitra! 🏥',
          'body': 'Discover Bihar\'s premium custom-care booking and video consultation tools.',
        },
        {
          'title': 'Daily Health Tip 🍎',
          'body': 'Stay hydrated! Make sure to drink at least 8-10 glasses of clean water today.',
        }
      ];

      // Only add if not already added to avoid spamming on reload
      final alreadyWelcomed = store.notifications.any(
        (n) => n.userId == currentUserId && n.title.contains('Welcome to Doctor Mitra'),
      );
      
      if (!alreadyWelcomed) {
        final mockPush = mockPushs[0];
        store.addNotification(
          userId: currentUserId,
          title: mockPush['title']!,
          body: mockPush['body']!,
        );
        store.persist();
        debugPrint("NotificationService: Simulated background mock push delivered to Notification Center.");
      }
    });
  }
}

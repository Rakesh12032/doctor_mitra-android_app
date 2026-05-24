import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:doctor_mitra/main.dart';
import 'package:doctor_mitra/providers/store_provider.dart';

void main() {
  test('local bridge keeps booking and notifications connected across roles',
      () async {
    SharedPreferences.setMockInitialValues({});
    final store = DoctorMitraStore();
    await store.load();

    final admin = store.users.firstWhere((user) => user.role == 'admin');
    final patient = store.users.firstWhere((user) => user.role == 'patient');
    final doctor = store.approvedDoctors.first;

    await store.loginAs(patient);
    final booking = await store.bookingService.createBooking(
      store,
      doctor: doctor,
      type: 'clinic',
      date: '20 May 2026',
      time: doctor.slots.first,
      symptoms: 'Fever',
    );

    expect(
      store.notificationService
          .forUser(store, doctor.userId)
          .any((note) => note.title == 'New appointment'),
      isTrue,
    );
    expect(
      store.notificationService
          .forUser(store, admin.id)
          .any((note) => note.title == 'New booking'),
      isTrue,
    );

    await store.bookingService.updateStatus(store, booking.id, 'accepted');
    expect(store.bookings.firstWhere((item) => item.id == booking.id).status,
        'accepted');
    expect(
      store.notificationService
          .forUser(store, patient.id)
          .any((note) => note.title == 'Booking ACCEPTED'),
      isTrue,
    );
    expect(
      store.notificationService
          .forUser(store, doctor.userId)
          .any((note) => note.title == 'Booking ACCEPTED'),
      isTrue,
    );

    await store.loginAs(admin);
    final pendingDoctor = store.pendingDoctors.first;
    await store.adminService.approveDoctor(store, pendingDoctor.id);
    expect(store.doctorById(pendingDoctor.id).status, 'approved');
    expect(
      store.notificationService
          .forUser(store, pendingDoctor.userId)
          .any((note) => note.title == 'Registration approved'),
      isTrue,
    );

    await store.loginAs(patient);
    final ambulanceRequest = await store.ambulanceService.requestAmbulance(
      store,
      provider: store.ambulances.first,
      pickupAddress: 'Boring Road, Patna',
      emergencyType: 'Emergency pickup',
    );
    expect(ambulanceRequest.status, 'requested');
    expect(
      store.notificationService
          .forUser(store, admin.id)
          .any((note) => note.title == 'Ambulance request'),
      isTrue,
    );
    await store.ambulanceService
        .updateRequestStatus(store, ambulanceRequest.id, 'dispatched');
    expect(
      store.ambulanceRequests
          .firstWhere((request) => request.id == ambulanceRequest.id)
          .status,
      'dispatched',
    );

    store.dispose();
  });

  testWidgets('Doctor Mitra app shows role selection',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = DoctorMitraStore();
    await store.load();

    await tester.pumpWidget(DoctorMitraApp(store: store));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Doctor Mitra'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Doctor'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('admin login opens dashboard without needing back',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = DoctorMitraStore();
    await store.load();

    await tester.pumpWidget(DoctorMitraApp(store: store));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Admin Email / ID'),
      'admin@doctormitra.in',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'Rakesh@12032',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login Now'));
    await tester.pumpAndSettle();

    expect(find.text('Admin Dashboard'), findsOneWidget);
  });

  testWidgets('new patient completes registration after OTP',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = DoctorMitraStore();
    await store.load();

    await tester.pumpWidget(DoctorMitraApp(store: store));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Enter Phone Number'),
      '9998887776',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Enter 6-digit OTP'),
      '123456',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Verify & Login'));
    await tester.pumpAndSettle();

    expect(find.text('Doctor Mitra'), findsOneWidget);
    expect(find.text('Find Doctor'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:doctor_mitra/mvp_app.dart';

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

    store.dispose();
  });

  testWidgets('Doctor Mitra app shows role selection',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const DoctorMitraRoleApp());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Doctor Mitra'), findsOneWidget);
    expect(find.text('Patient Login'), findsOneWidget);
    expect(find.text('Doctor Login'), findsOneWidget);
    expect(find.text('Admin Login'), findsOneWidget);
  });
}

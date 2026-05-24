import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../providers/store_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/language_provider.dart';
import '../models/doctor_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../models/hospital_model.dart';

import '../widgets/custom_ui.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/language_toggle.dart';

import 'home_screen.dart';
import 'doctors_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';
import 'health_card_screen.dart';
import 'hospitals_screen.dart';
import 'teleconsult_screen.dart';
import 'doctor_earnings_screen.dart';

// ==========================================
// DYNAMIC DASHBOARD SWITCHER BY ROLE
// ==========================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DoctorMitraStore>(context);
    final role = store.currentUser?.role ?? 'patient';

    if (role == 'admin') {
      return const AdminShell();
    } else if (role == 'doctor') {
      return const DoctorShell();
    } else {
      return const PatientShell();
    }
  }
}

// ==========================================
// PATIENT SHELL
// ==========================================

class PatientShell extends StatefulWidget {
  const PatientShell({super.key});

  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DoctorsScreen(),
    const BookingsScreen(),
    const HealthCardScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    final List<CustomNavbarItem> items = [
      CustomNavbarItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: lang.t('home'),
      ),
      CustomNavbarItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people_rounded,
        label: lang.t('doctors'),
      ),
      CustomNavbarItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today_rounded,
        label: lang.t('my_bookings'),
      ),
      CustomNavbarItem(
        icon: Icons.badge_outlined,
        activeIcon: Icons.badge,
        label: lang.t('health_card'),
      ),
      CustomNavbarItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person_rounded,
        label: lang.t('profile'),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavbar(
        currentIndex: _currentIndex,
        items: items,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// ==========================================
// ADMIN SHELL
// ==========================================

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminDoctorsScreen(),
    const AdminBookingsScreen(),
    const HospitalsScreen(),
    const AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    final List<CustomNavbarItem> items = [
      CustomNavbarItem(
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics,
        label: lang.isHindi ? 'डैशबोर्ड' : 'Dashboard',
      ),
      CustomNavbarItem(
        icon: Icons.medical_services_outlined,
        activeIcon: Icons.medical_services,
        label: lang.isHindi ? 'डॉक्टर' : 'Doctors',
      ),
      CustomNavbarItem(
        icon: Icons.event_note_outlined,
        activeIcon: Icons.event_note,
        label: lang.isHindi ? 'बुकिंग्स' : 'Bookings',
      ),
      CustomNavbarItem(
        icon: Icons.local_hospital_outlined,
        activeIcon: Icons.local_hospital,
        label: lang.isHindi ? 'अस्पताल' : 'Hospitals',
      ),
      CustomNavbarItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: lang.isHindi ? 'सेटिंग्स' : 'Settings',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavbar(
        currentIndex: _currentIndex,
        items: items,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// ==========================================
// ADMIN DASHBOARD SCREEN
// ==========================================

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DoctorMitraStore>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final revenue = store.bookings
        .where((b) => b.status != 'cancelled')
        .fold<double>(0, (sum, b) => sum + b.fee);

    final pendingAppr = store.pendingDoctors;

    return AppPage(
      title: isHi ? 'एडमिन डैशबोर्ड' : 'Admin Dashboard',
      subtitle: isHi ? 'सभी कनेक्टेड ऑपरेशन्स का विवरण' : 'Overview of connected operations',
      useGradientAppBar: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.sync_outlined, color: Colors.white),
          onPressed: () async {
            await store.syncNow();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isHi ? "डेटा सिंक हो गया!" : "Data synced successfully!"),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () async {
            await store.logout();
          },
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Stats Grid 2x2
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.35,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildAdminStatCard(
                label: isHi ? 'कुल डॉक्टर' : 'Doctors',
                value: '${store.doctors.length}',
                icon: Icons.medical_services_outlined,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
              ),
              _buildAdminStatCard(
                label: isHi ? 'कुल मरीज़' : 'Patients',
                value: '${store.patients.length}',
                icon: Icons.people_outline,
                iconBg: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0284C7),
              ),
              _buildAdminStatCard(
                label: isHi ? 'कुल बुकिंग्स' : 'Bookings',
                value: '${store.bookings.length}',
                icon: Icons.calendar_today_outlined,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
              ),
              _buildAdminStatCard(
                label: isHi ? 'कुल रेवेन्यू' : 'Revenue',
                value: '₹${revenue.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_outlined,
                iconBg: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Booking Status Chart
          _buildChartSection(context, store, lang),
          const SizedBox(height: 24),

          // Pending Doctor Approvals Queue
          _buildPendingApprovals(context, store, lang),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAdminStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: Colors.black.withOpacity(0.01)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, DoctorMitraStore store, LanguageProvider lang) {
    final isHi = lang.isHindi;
    final total = store.bookings.isEmpty ? 1 : store.bookings.length;

    final pending = store.bookings.where((e) => e.status == 'pending').length;
    final accepted = store.bookings.where((e) => e.status == 'accepted' || e.status == 'upcoming').length;
    final completed = store.bookings.where((e) => e.status == 'completed').length;
    final cancelled = store.bookings.where((e) => e.status == 'cancelled').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: Colors.black.withOpacity(0.01)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isHi ? 'बुकिंग स्थिति चार्ट' : 'Booking Status Chart',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildChartBar(isHi ? 'लंबित' : 'Pending', pending, total, const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          _buildChartBar(isHi ? 'स्वीकृत' : 'Accepted', accepted, total, const Color(0xFF3B82F6)),
          const SizedBox(height: 12),
          _buildChartBar(isHi ? 'पूरा हुआ' : 'Completed', completed, total, const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _buildChartBar(isHi ? 'रद्द' : 'Cancelled', cancelled, total, const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, int value, int total, Color color) {
    final percentage = value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium, fontFamily: 'Nunito'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$value',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, fontFamily: 'Nunito'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingApprovals(BuildContext context, DoctorMitraStore store, LanguageProvider lang) {
    final isHi = lang.isHindi;
    final pendingList = store.pendingDoctors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isHi ? 'लंबित डॉक्टर स्वीकृतियां' : 'Pending Doctor Approvals',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (pendingList.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                isHi ? 'कोई लंबित डॉक्टर पंजीकरण नहीं हैं।' : 'No pending doctor registrations.',
                style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Nunito'),
              ),
            ),
          )
        else
          ...pendingList.take(3).map((doctor) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.premiumShadow,
                border: Border.all(color: Colors.black.withOpacity(0.015)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: doctor.specialtyColor.withOpacity(0.12),
                    child: Icon(Icons.person, color: doctor.specialtyColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${doctor.specialty} • ${doctor.degree}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 28),
                        onPressed: () async {
                          await store.adminService.approveDoctor(store, doctor.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.highlight_off_rounded, color: AppColors.error, size: 28),
                        onPressed: () async {
                          await store.adminService.rejectDoctor(store, doctor.id);
                        },
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
      ],
    );
  }
}

// ==========================================
// ADMIN MANAGE DOCTORS SCREEN
// ==========================================

class AdminDoctorsScreen extends StatelessWidget {
  const AdminDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DoctorMitraStore>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final list = store.doctors;

    return AppPage(
      title: isHi ? 'डॉक्टर प्रबंधन' : 'Manage Doctors',
      subtitle: isHi 
          ? '${store.pendingDoctors.length} लंबित - ${store.approvedDoctors.length} स्वीकृत' 
          : '${store.pendingDoctors.length} pending - ${store.approvedDoctors.length} approved',
      useGradientAppBar: true,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final doctor = list[index];
          final isPending = doctor.status == 'pending';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.015)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: doctor.specialtyColor.withOpacity(0.12),
                      child: Icon(Icons.person, color: doctor.specialtyColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${doctor.specialty} • Fee: ₹${doctor.fee.toStringAsFixed(0)} • ${doctor.district}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPillBadge(doctor.status),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.border.withOpacity(0.5), height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isPending) ...[
                      TextButton.icon(
                        icon: const Icon(Icons.check, size: 16, color: AppColors.success),
                        label: Text(isHi ? 'स्वीकृत' : 'Approve', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          await store.adminService.approveDoctor(store, doctor.id);
                        },
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                        label: Text(isHi ? 'अस्वीकृत' : 'Reject', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          await store.adminService.rejectDoctor(store, doctor.id);
                        },
                      ),
                    ] else ...[
                      TextButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                        label: Text(isHi ? 'हटाएं' : 'Delete', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          await store.adminService.deleteDoctor(store, doctor.id);
                        },
                      ),
                    ]
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPillBadge(String status) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'pending':
        color = const Color(0xFFE65100);
        bgColor = const Color(0xFFFFF3E0);
        break;
      case 'approved':
        color = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        break;
      default:
        color = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}

// ==========================================
// ADMIN BOOKINGS SCREEN
// ==========================================

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DoctorMitraStore>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final bookings = store.bookings;

    return AppPage(
      title: isHi ? 'सभी अपॉइंटमेंट्स' : 'All Bookings',
      subtitle: isHi ? 'कुल ${bookings.length} बुकिंग्स का रिकॉर्ड' : 'Record of total ${bookings.length} bookings',
      useGradientAppBar: true,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: bookings.isEmpty ? 1 : bookings.length,
        itemBuilder: (context, index) {
          if (bookings.isEmpty) {
            return EmptyState(
              icon: Icons.calendar_today_outlined,
              title: isHi ? 'कोई बुकिंग नहीं मिली' : 'No Bookings Found',
              subtitle: isHi ? 'सिस्टम में अभी कोई बुकिंग उपलब्ध नहीं है।' : 'No bookings are currently present in the system.',
            );
          }

          final booking = bookings[index];
          final doctor = store.doctorById(booking.doctorId);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.015)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.patientName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
                    ),
                    _buildPillBadge(booking.status, lang),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Doctor: ${doctor.name} (${doctor.specialty})',
                  style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoLine(Icons.schedule, 'Time', '${booking.date}, ${booking.time}'),
                      const SizedBox(height: 8),
                      _buildInfoLine(Icons.account_balance_wallet_outlined, 'FeePaid', '₹${booking.fee.toStringAsFixed(0)}'),
                      if (booking.symptoms.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildInfoLine(Icons.medical_information_outlined, 'Symptoms', booking.symptoms),
                      ]
                    ],
                  ),
                ),
                if (booking.status == 'pending') ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.check, size: 16, color: AppColors.success),
                        label: Text(isHi ? 'स्वीकार करें' : 'Accept', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          await store.bookingService.updateStatus(store, booking.id, 'accepted');
                        },
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                        label: Text(isHi ? 'रद्द करें' : 'Cancel', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          await store.bookingService.updateStatus(store, booking.id, 'cancelled');
                        },
                      ),
                    ],
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPillBadge(String status, LanguageProvider lang) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'pending':
        color = const Color(0xFFE65100);
        bgColor = const Color(0xFFFFF3E0);
        break;
      case 'accepted':
      case 'upcoming':
        color = const Color(0xFF1565C0);
        bgColor = const Color(0xFFE3F2FD);
        break;
      case 'completed':
        color = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        break;
      default:
        color = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        lang.t(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }

  Widget _buildInfoLine(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'Nunito'),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Nunito'),
        ),
      ],
    );
  }
}

// ==========================================
// ADMIN SETTINGS SCREEN
// ==========================================

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();

  @override
  void dispose() {
    _specialtyController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DoctorMitraStore>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    return AppPage(
      title: isHi ? 'एडमिन सेटिंग्स' : 'Settings Panel',
      subtitle: isHi ? 'सिस्टम कॉन्फ़िगरेशन विवरण' : 'Configure system-wide settings',
      useGradientAppBar: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // Maintenance Mode Switch
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.01)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFFEE2E2),
                  child: Icon(Icons.construction_outlined, color: AppColors.error, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHi ? 'मेंटेनेंस मोड' : 'Maintenance Mode',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
                      ),
                      Text(
                        isHi ? 'सभी यूजर पैनल को ब्लॉक करें' : 'Block client app dashboards',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Nunito'),
                      ),
                    ],
                  ),
                ),
                Switch(
                  activeColor: AppColors.primary,
                  value: store.maintenanceMode,
                  onChanged: (val) async {
                    await store.adminService.setMaintenanceMode(store, val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Manage Specialties Wrap
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.01)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHi ? 'डॉक्टर विशिष्टताएं' : 'Manage Specialties',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _specialtyController,
                        decoration: InputDecoration(
                          hintText: isHi ? 'नया क्षेत्र जोड़ें' : 'Add specialty (e.g. ENT)',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 36),
                      onPressed: () async {
                        final val = _specialtyController.text.trim();
                        if (val.isNotEmpty) {
                          await store.adminService.addSpecialty(store, val);
                          _specialtyController.clear();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: store.specialties.map((spec) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        spec,
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Manage Health Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.01)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHi ? 'स्वास्थ्य सुझाव' : 'Manage Health Tips',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tipController,
                        decoration: InputDecoration(
                          hintText: isHi ? 'नया स्वास्थ्य सुझाव लिखें' : 'Write new health tip',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 36),
                      onPressed: () async {
                        final val = _tipController.text.trim();
                        if (val.isNotEmpty) {
                          await store.adminService.addHealthTip(store, val);
                          _tipController.clear();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: store.healthTips.map((tip) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tips_and_updates_outlined, color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMedium, fontFamily: 'Nunito'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// DOCTOR SHELL
// ==========================================

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DoctorDashboardScreen(),
    const DoctorAppointmentsScreen(),
    const DoctorSlotsScreen(),
    const DoctorPatientsScreen(),
    const DoctorProfileViewScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    final List<CustomNavbarItem> items = [
      CustomNavbarItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: lang.isHindi ? 'डैशबोर्ड' : 'Dashboard',
      ),
      CustomNavbarItem(
        icon: Icons.event_note_outlined,
        activeIcon: Icons.event_note,
        label: lang.isHindi ? 'अपॉइंटमेंट्स' : 'Appointments',
      ),
      CustomNavbarItem(
        icon: Icons.schedule_outlined,
        activeIcon: Icons.schedule,
        label: lang.isHindi ? 'स्लॉट्स' : 'Slots',
      ),
      CustomNavbarItem(
        icon: Icons.group_outlined,
        activeIcon: Icons.group,
        label: lang.isHindi ? 'मरीज' : 'Patients',
      ),
      CustomNavbarItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person_rounded,
        label: lang.isHindi ? 'प्रोफाइल' : 'Profile',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavbar(
        currentIndex: _currentIndex,
        items: items,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// ==========================================
// DOCTOR DASHBOARD SCREEN
// ==========================================

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DoctorMitraStore>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final doctor = store.currentDoctor;
    if (doctor == null) {
      return Scaffold(
        body: Center(
          child: Text(isHi ? 'डॉक्टर प्रोफाइल लोड हो रही है...' : 'Loading doctor details...'),
        ),
      );
    }

    final appointments = store.doctorService.appointmentsForDoctor(store, doctor.id);
    final todayStr = DateFormat('dd MMM yyyy').format(DateTime.now());
    final todayBookings = appointments.where((b) => b.date == todayStr).toList();
    final pendingBookings = appointments.where((b) => b.status == 'pending').toList();

    final earnings = appointments
        .where((b) => b.status == 'completed')
        .fold<double>(0, (sum, b) => sum + b.fee);

    return AppPage(
      title: isHi ? 'डॉक्टर पैनल' : 'Doctor Panel',
      subtitle: isHi ? 'आज का अपॉइंटमेंट शेड्यूल' : 'Your medical consultation schedule',
      useGradientAppBar: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.sync_outlined, color: Colors.white),
          onPressed: () async {
            await store.syncNow();
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () async {
            await store.logout();
          },
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Doctor Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.015)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: doctor.specialtyColor.withOpacity(0.12),
                  child: Icon(Icons.person, color: doctor.specialtyColor, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${doctor.specialty} • ${doctor.degree}',
                        style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isHi ? '${doctor.experience} वर्ष का अनुभव' : '${doctor.experience} years experience',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Nunito'),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doctor.status.toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 10, fontFamily: 'Nunito'),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildDocStatCard(isHi ? 'आज के मरीज' : 'Today', '${todayBookings.length}', Icons.calendar_today),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDocStatCard(isHi ? 'लंबित बुकिंग' : 'Pending', '${pendingBookings.length}', Icons.pending_actions),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDocStatCard(
                  isHi ? 'कुल कमाई' : 'Earnings',
                  '₹${earnings.toStringAsFixed(0)}',
                  Icons.payments,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorEarningsScreen(doctorId: doctor.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Online consultation availability toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.01)),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: Text(
                isHi ? 'ऑनलाइन परामर्श सेवा' : 'Online Consult Available',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
              ),
              subtitle: Text(
                isHi ? 'मरीजों को ऑनलाइन बुक करने की अनुमति दें' : 'Allow patients to book video consulting',
                style: const TextStyle(fontSize: 11),
              ),
              value: doctor.isOnline,
              onChanged: (val) async {
                final next = doctor.copyWith(isOnlineAvailable: val);
                await store.doctorService.updateDoctor(store, next);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Appointment Queue Title
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isHi ? 'अपॉइंटमेंट अनुरोध' : 'Appointment Queue',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Booking Card lists
          if (pendingBookings.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(
                  isHi ? 'कोई नए अपॉइंटमेंट अनुरोध नहीं हैं।' : 'No new appointment requests.',
                  style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Nunito'),
                ),
              ),
            )
          else
            ...pendingBookings.map((b) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.premiumShadow,
                  border: Border.all(color: Colors.black.withOpacity(0.015)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          b.patientName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            b.status.toUpperCase(),
                            style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w700, fontSize: 9, fontFamily: 'Nunito'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Slot: ${b.date}, ${b.time} | Type: ${b.type.toUpperCase()}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Nunito'),
                    ),
                    if (b.symptoms.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Symptoms: ${b.symptoms}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMedium, fontFamily: 'Nunito'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.check, size: 16, color: AppColors.success),
                          label: Text(isHi ? 'स्वीकारें' : 'Accept', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            await store.bookingService.updateStatus(store, b.id, 'accepted');
                          },
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                          label: Text(isHi ? 'अस्वीकार करें' : 'Reject', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            await store.bookingService.updateStatus(store, b.id, 'rejected');
                          },
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDocStatCard(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.premiumShadow,
          border: Border.all(color: Colors.black.withOpacity(0.015)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Nunito'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// DOCTOR APPOINTMENTS LIST SCREEN
// ==========================================

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DoctorMitraStore>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final doctor = store.currentDoctor;
    final list = doctor == null
        ? <Booking>[]
        : store.doctorService.appointmentsForDoctor(store, doctor.id);

    return AppPage(
      title: isHi ? 'मरीज अपॉइंटमेंट्स' : 'All Appointments',
      subtitle: isHi ? 'सभी बुक किए गए टाइम स्लॉट' : 'Schedule of all booked sessions',
      useGradientAppBar: true,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: list.isEmpty ? 1 : list.length,
        itemBuilder: (context, index) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.calendar_today_outlined,
              title: isHi ? 'कोई अपॉइंटमेंट नहीं मिला' : 'No Appointments',
              subtitle: isHi ? 'आपके पास अभी कोई अपॉइंटमेंट नहीं है।' : 'You have no consultation sessions listed yet.',
            );
          }

          final b = list[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.015)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b.patientName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
                    ),
                    _buildPillBadge(b.status, lang),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Slot: ${b.date}, ${b.time} | Mobile: ${b.patientMobile}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Nunito'),
                ),
                if (b.symptoms.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Symptoms: ${b.symptoms}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMedium, fontFamily: 'Nunito'),
                  ),
                ],
                if (b.type == 'online' && b.status == 'accepted') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TeleconsultScreen()),
                        );
                      },
                      child: Text(
                        isHi ? 'वीडियो परामर्श शुरू करें' : 'Start Video Consultation',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Nunito'),
                      ),
                    ),
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPillBadge(String status, LanguageProvider lang) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'pending':
        color = const Color(0xFFE65100);
        bgColor = const Color(0xFFFFF3E0);
        break;
      case 'accepted':
      case 'upcoming':
        color = const Color(0xFF1565C0);
        bgColor = const Color(0xFFE3F2FD);
        break;
      case 'completed':
        color = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        break;
      default:
        color = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        lang.t(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}

// ==========================================
// DOCTOR SLOTS MANAGEMENT SCREEN
// ==========================================

class DoctorSlotsScreen extends StatefulWidget {
  const DoctorSlotsScreen({super.key});

  @override
  State<DoctorSlotsScreen> createState() => _DoctorSlotsScreenState();
}

class _DoctorSlotsScreenState extends State<DoctorSlotsScreen> {
  final TextEditingController _slotController = TextEditingController();

  @override
  void dispose() {
    _slotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DoctorMitraStore>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final doctor = store.currentDoctor;
    if (doctor == null) {
      return const Scaffold(body: Center(child: Text('Loading doctor profile...')));
    }

    return AppPage(
      title: isHi ? 'परामर्श समय स्लॉट' : 'Slot Manager',
      subtitle: isHi ? 'मरीजों के लिए उपलब्ध स्लॉट बदलें' : 'Manage your available consultation hours',
      useGradientAppBar: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // Active slots section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.015)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHi ? 'सक्रिय समय स्लॉट' : 'Active Time Slots',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 12),
                if (doctor.slots.isEmpty)
                  Text(
                    isHi ? 'कोई सक्रिय स्लॉट उपलब्ध नहीं है। स्लॉट जोड़ें।' : 'No slots currently active. Please add a slot below.',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Nunito'),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: doctor.slots.map((slot) {
                      return Chip(
                        label: Text(slot, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 12)),
                        onDeleted: () async {
                          await store.slotService.removeSlot(store, doctor, slot);
                        },
                        deleteIconColor: AppColors.textMuted,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Add Slot Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.015)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHi ? 'नया समय स्लॉट जोड़ें' : 'Add New Consultation Slot',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _slotController,
                  decoration: InputDecoration(
                    hintText: isHi ? 'उदा. 10:30' : 'e.g. 10:30',
                    prefixIcon: const Icon(Icons.schedule, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: isHi ? 'स्लॉट जोड़ें' : 'Add Slot',
                  onPressed: () async {
                    final slot = _slotController.text.trim();
                    if (slot.isNotEmpty) {
                      await store.slotService.addSlot(store, doctor, slot);
                      _slotController.clear();
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// DOCTOR PATIENTS LIST SCREEN
// ==========================================

class DoctorPatientsScreen extends StatelessWidget {
  const DoctorPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DoctorMitraStore>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final doctor = store.currentDoctor;
    final list = doctor == null
        ? <AppUser>[]
        : store.doctorService.patientsForDoctor(store, doctor.id);

    return AppPage(
      title: isHi ? 'मेरे मरीज सूची' : 'My Patients',
      subtitle: isHi ? 'अपॉइंटमेंट बुक करने वाले मरीज' : 'List of patients consulted so far',
      useGradientAppBar: true,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: list.isEmpty ? 1 : list.length,
        itemBuilder: (context, index) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.groups_outlined,
              title: isHi ? 'कोई मरीज़ नहीं मिला' : 'No Patients Yet',
              subtitle: isHi ? 'अभी तक किसी मरीज़ ने स्लॉट बुक नहीं किया।' : 'Consulted patient records will be listed here.',
            );
          }

          final patient = list[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.015)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark, fontFamily: 'Nunito'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mobile: ${patient.mobile} • District: ${patient.district}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Nunito'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// DOCTOR PROFILE SCREEN
// ==========================================

class DoctorProfileViewScreen extends StatelessWidget {
  const DoctorProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DoctorMitraStore>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final doctor = store.currentDoctor;
    if (doctor == null) {
      return const Scaffold(body: Center(child: Text('Loading profile...')));
    }

    return AppPage(
      title: isHi ? 'डॉक्टर प्रोफाइल' : 'Doctor Profile',
      subtitle: isHi ? 'आपकी क्लिनिक और परामर्श विवरण' : 'Your medical clinic & consult specifications',
      useGradientAppBar: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.premiumShadow,
              border: Border.all(color: Colors.black.withOpacity(0.01)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileDetailRow(isHi ? 'पूरा नाम' : 'Full Name', doctor.name),
                const Divider(color: AppColors.border, height: 24),
                _buildProfileDetailRow(isHi ? 'विशिष्टता' : 'Specialty', doctor.specialty),
                const Divider(color: AppColors.border, height: 24),
                _buildProfileDetailRow(isHi ? 'डिग्री/योग्यता' : 'Qualification', doctor.degree),
                const Divider(color: AppColors.border, height: 24),
                _buildProfileDetailRow(isHi ? 'रजिस्ट्रेशन नंबर' : 'Reg. Number', doctor.registrationNumber),
                const Divider(color: AppColors.border, height: 24),
                _buildProfileDetailRow(isHi ? 'क्लीनिक नाम' : 'Clinic Name', doctor.clinicName),
                const Divider(color: AppColors.border, height: 24),
                _buildProfileDetailRow(isHi ? 'जिला' : 'District', doctor.district),
                const Divider(color: AppColors.border, height: 24),
                _buildProfileDetailRow(isHi ? 'परामर्श शुल्क' : 'In-Clinic Fee', '₹${doctor.fee.toStringAsFixed(0)}'),
                const Divider(color: AppColors.border, height: 24),
                _buildProfileDetailRow(isHi ? 'ऑनलाइन परामर्श शुल्क' : 'Online Consult Fee', '₹${doctor.onlineFee.toStringAsFixed(0)}'),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await store.logout();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                lang.t('logout'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontFamily: 'Nunito'),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark, fontFamily: 'Nunito'),
          ),
        ),
      ],
    );
  }
}

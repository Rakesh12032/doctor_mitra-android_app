import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/language_toggle.dart';
import '../widgets/whatsapp_fab.dart';
import '../widgets/doctor_card.dart';
import '../widgets/specialty_chip.dart';
import '../widgets/custom_ui.dart';
import '../data/doctors_data.dart';
import 'doctors_screen.dart';
import 'teleconsult_screen.dart';
import 'health_card_screen.dart';
import 'hospitals_screen.dart';
import 'ambulance_screen.dart';
import 'bookings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, lang),
              const SizedBox(height: 16),
              _buildSearchBanner(context, lang),
              const SizedBox(height: 24),
              _buildQuickActions(context, lang),
              const SizedBox(height: 24),
              _buildStatsRow(context, lang),
              const SizedBox(height: 24),
              _buildSpecialties(context, lang),
              const SizedBox(height: 24),
              _buildTopDoctors(context, lang),
              const SizedBox(height: 24),
              _buildHowItWorks(context, lang),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: const WhatsappFab(),
    );
  }

  Widget _buildHeader(BuildContext context, LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.15), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.cardBg,
                  child: Icon(Icons.person, color: AppColors.primary, size: 28),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.isHindi ? "आपका स्वागत है" : "Welcome back,",
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontFamily: 'Poppins'),
                  ),
                  const Text(
                    "Patient User",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const LanguageToggle(),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none,
                      color: AppColors.textDark, size: 24),
                  onPressed: () {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchBanner(BuildContext context, LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.isHindi
                            ? 'भरोसेमंद इलाज खोजें'
                            : 'Find Trusted Care',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang.isHindi
                            ? 'ऑनलाइन या अस्पताल में'
                            : 'Online or at the hospital',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.health_and_safety,
                    color: Colors.white, size: 56),
              ],
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DoctorsScreen()),
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      lang.t('search_hint'),
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, LanguageProvider lang) {
    final actions = [
      {
        'icon': Icons.medical_services_outlined,
        'label': lang.t('find_doctor'),
        'screen': const DoctorsScreen()
      },
      {
        'icon': Icons.video_call_outlined,
        'label': lang.t('online_consult'),
        'screen': const TeleconsultScreen()
      },
      {
        'icon': Icons.credit_card_outlined,
        'label': lang.t('health_card'),
        'screen': const HealthCardScreen()
      },
      {
        'icon': Icons.local_hospital_outlined,
        'label': lang.t('hospitals'),
        'screen': const HospitalsScreen()
      },
      {
        'icon': Icons.directions_car_outlined,
        'label': lang.t('ambulance'),
        'screen': const AmbulanceScreen()
      },
      {
        'icon': Icons.calendar_today_outlined,
        'label': lang.isHindi ? 'मेरी बुकिंग' : 'My Bookings',
        'screen': const BookingsScreen()
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: lang.isHindi ? 'सेवाएं' : 'Services'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildActionBtn(
                context,
                action['icon'] as IconData,
                action['label'] as String,
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => action['screen'] as Widget));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(child: Icon(icon, color: Colors.white, size: 26)),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.1,
                    fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
                '30+', lang.isHindi ? 'डॉक्टर' : 'Doctors', Icons.people),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
                '5', lang.isHindi ? 'जिले' : 'Districts', Icons.location_on),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(lang.isHindi ? 'मुफ़्त' : 'Free',
                lang.isHindi ? 'बुकिंग' : 'Booking', Icons.check_circle),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark,
                fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialties(BuildContext context, LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: lang.t('specialties')),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              SpecialtyChip(
                  label: lang.isHindi ? 'सामान्य चिकित्सक' : 'Physician',
                  icon: Icons.favorite,
                  color: Colors.blue,
                  onTap: () {}),
              const SizedBox(width: 8),
              SpecialtyChip(
                  label: lang.isHindi ? 'हृदय रोग' : 'Cardiologist',
                  icon: Icons.favorite_border,
                  color: Colors.red,
                  onTap: () {}),
              const SizedBox(width: 8),
              SpecialtyChip(
                  label: lang.isHindi ? 'स्त्री रोग' : 'Gynecologist',
                  icon: Icons.pregnant_woman,
                  color: Colors.pink,
                  onTap: () {}),
              const SizedBox(width: 8),
              SpecialtyChip(
                  label: lang.isHindi ? 'त्वचा विशेषज्ञ' : 'Dermatologist',
                  icon: Icons.face,
                  color: Colors.teal,
                  onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopDoctors(BuildContext context, LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: lang.t('top_doctors'),
          actionLabel: lang.t('see_all'),
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DoctorsScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 290, // Increased height to accommodate the larger DoctorCard
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            itemBuilder: (context, index) {
              final doctor = DoctorsData.doctors[index];
              return Container(
                width: 320,
                padding: const EdgeInsets.only(right: 16),
                child: DoctorCard(doctor: doctor),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorks(BuildContext context, LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: lang.t('how_it_works')),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2)),
              ],
              border: Border.all(color: Colors.black.withOpacity(0.01)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepCard(context, '1', lang.t('step1')),
                Icon(Icons.arrow_forward_ios,
                    color: AppColors.textMuted.withOpacity(0.3), size: 14),
                _buildStepCard(context, '2', lang.t('step2')),
                Icon(Icons.arrow_forward_ios,
                    color: AppColors.textMuted.withOpacity(0.3), size: 14),
                _buildStepCard(context, '3', lang.t('step3')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(BuildContext context, String number, String text) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.lightBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Poppins')),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMedium,
                height: 1.3,
                fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/store_provider.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';

class HealthCardScreen extends StatelessWidget {
  const HealthCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final store = Provider.of<DoctorMitraStore>(context);
    final user = store.currentUser;
    final card = store.currentHealthCard;
    final isHi = lang.isHindi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.primary),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          lang.t('health_card'),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, fontFamily: 'Nunito'),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDigitalCard(context, store),
              const SizedBox(height: 32),
              SectionHeader(
                  title:
                      isHi ? 'मेडिकल जानकारी' : 'Medical Information'),
              const SizedBox(height: 16),
              _buildInfoTile(
                icon: Icons.bloodtype_outlined,
                iconColor: AppColors.primary,
                title: isHi ? 'रक्त समूह' : 'Blood Group',
                subtitle: card?.bloodGroup ?? 'Not set',
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.warning,
                title: lang.t('allergies'),
                subtitle: card?.allergies ?? 'Not set',
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                icon: Icons.medication_outlined,
                iconColor: AppColors.accent,
                title: lang.t('medications'),
                subtitle: card?.medications ?? 'None currently',
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                icon: Icons.emergency_outlined,
                iconColor: AppColors.error,
                title: isHi ? 'आपातकालीन संपर्क' : 'Emergency Contact',
                subtitle: card?.emergencyContact ?? user?.mobile ?? 'Not set',
              ),
              const SizedBox(height: 32),
              AppButton(
                text: lang.t('download_card'),
                icon: Icons.download_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isHi ? "डाउनलोड शुरू हो रहा है..." : "Starting download...",
                        style: const TextStyle(fontFamily: 'Nunito'),
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalCard(BuildContext context, DoctorMitraStore store) {
    final user = store.currentUser;
    final card = store.currentHealthCard;
    final cardId = card != null && card.id.length >= 8
        ? 'DM-HC-${card.id.substring(0, 8).toUpperCase()}'
        : 'DM-HC- राकेश९८';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20), // rounded 20px
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000), // subtle shadow
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.health_and_safety,
                size: 160, color: Colors.white.withOpacity(0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
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
                        letterSpacing: 2,
                        fontSize: 14,
                        fontFamily: 'Nunito',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Rakesh Kumar',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ID: $cardId',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              letterSpacing: 1.0,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(Icons.qr_code_2,
                          size: 38, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCardItem('BLOOD', card?.bloodGroup ?? 'O+'),
                      Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withOpacity(0.2)),
                      _buildCardItem('DISTRICT', user?.district ?? 'Patna'),
                      Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withOpacity(0.2)),
                      _buildCardItem('EMERGENCY', card?.emergencyContact ?? user?.mobile ?? '102'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 10,
            letterSpacing: 0.5,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
      {required IconData icon,
      required Color iconColor,
      required String title,
      required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: Colors.black.withOpacity(0.01)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontFamily: 'Nunito',
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

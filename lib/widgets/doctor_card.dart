import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/doctor_model.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../screens/doctor_profile_screen.dart';
import '../screens/booking_screen.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.015)),
        boxShadow: AppColors.premiumShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorProfileScreen(doctor: doctor),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with colored background per specialty
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: doctor.specialtyColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          color: doctor.specialtyColor,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  isHi ? doctor.nameHi : doctor.nameEn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                              if (doctor.isOnline)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        lang.t('online'),
                                        style: const TextStyle(
                                          color: AppColors.success,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isHi ? doctor.specialtyHi : doctor.specialtyEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isHi ? doctor.degreeHi : doctor.degreeEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.work_outline,
                                  size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                isHi
                                    ? '${doctor.experience} वर्ष अनुभव'
                                    : '${doctor.experience} Yrs Exp.',
                                style: const TextStyle(
                                    color: AppColors.textMedium,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Nunito'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: AppColors.border.withOpacity(0.5), height: 1),
                const SizedBox(height: 14),
                // Rating and Fee
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.warning, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${doctor.rating}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.warning,
                                      fontFamily: 'Nunito'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '(${doctor.reviews} ${isHi ? 'समीक्षाएं' : 'Reviews'})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                  fontFamily: 'Nunito'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${doctor.fee}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 18,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DoctorProfileScreen(doctor: doctor),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(isHi ? 'प्रोफाइल' : 'View Profile',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Nunito')),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookingScreen(doctor: doctor),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(isHi ? 'बुक करें' : 'Book Now',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Nunito',
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

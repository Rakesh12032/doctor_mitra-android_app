import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../providers/language_provider.dart';

class WaitingRoomView extends StatelessWidget {
  final int secondsLeft;
  final int queuePosition;
  final Animation<double> pulseAnimation;
  final LanguageProvider lang;

  const WaitingRoomView({
    super.key,
    required this.secondsLeft,
    required this.queuePosition,
    required this.pulseAnimation,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing rings
                ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.25).animate(pulseAnimation),
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.04),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.15).animate(pulseAnimation),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Glowing Avatar Ring
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 20, spreadRadius: 4),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Timer badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.premiumShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '00:${secondsLeft.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Doctor Mitra waiting room',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connecting you with Dr. Rajeev Kumar',
              style: TextStyle(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.premiumShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Queue Position:', style: TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w500)),
                      Text('#$queuePosition', style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Wait Time:', style: TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w500)),
                      Text('~${secondsLeft}s', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

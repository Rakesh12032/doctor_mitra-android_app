import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../providers/language_provider.dart';
import '../../widgets/custom_ui.dart';

class DeviceCheckView extends StatelessWidget {
  final bool cameraChecked;
  final bool micChecked;
  final bool networkChecked;
  final bool checkingInProgress;
  final VoidCallback onStartDiagnostic;
  final VoidCallback onJoinWaitingRoom;
  final LanguageProvider lang;

  const DeviceCheckView({
    super.key,
    required this.cameraChecked,
    required this.micChecked,
    required this.networkChecked,
    required this.checkingInProgress,
    required this.onStartDiagnostic,
    required this.onJoinWaitingRoom,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final allPassed = cameraChecked && micChecked && networkChecked;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings_system_daydream_rounded, size: 48, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              lang.t('device_diagnostics'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Checking device camera, microphone, and internet latency to guarantee a premium call quality.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 32),

          // Diagnostic cards
          _buildCheckCard(
            title: 'Camera Access',
            subtitle: cameraChecked ? 'Front camera connected' : 'Verifying camera sensor...',
            icon: Icons.videocam_rounded,
            isChecked: cameraChecked,
          ),
          const SizedBox(height: 16),
          _buildCheckCard(
            title: 'Microphone Sensor',
            subtitle: micChecked ? 'Audio levels healthy' : 'Verifying microphone input...',
            icon: Icons.mic_rounded,
            isChecked: micChecked,
          ),
          const SizedBox(height: 16),
          _buildCheckCard(
            title: 'Network Stability',
            subtitle: networkChecked ? 'Ping: 34ms (Excellent)' : 'Measuring connection latency...',
            icon: Icons.wifi_rounded,
            isChecked: networkChecked,
          ),
          const SizedBox(height: 48),

          // Control Button
          if (!allPassed && !checkingInProgress)
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Begin Pre-Call Check',
                onPressed: onStartDiagnostic,
              ),
            )
          else if (checkingInProgress)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
                  SizedBox(height: 16),
                  Text('Executing diagnostics checks...', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else if (allPassed)
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.success),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All diagnostic checks passed. Your device is ready.',
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Join Waiting Room',
                    onPressed: onJoinWaitingRoom,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCheckCard({required String title, required String subtitle, required IconData icon, required bool isChecked}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: isChecked ? AppColors.primary.withOpacity(0.2) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isChecked ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isChecked ? AppColors.primary : Colors.grey, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: isChecked ? AppColors.textMedium : AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          if (isChecked)
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 26)
          else
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)),
            ),
        ],
      ),
    );
  }
}

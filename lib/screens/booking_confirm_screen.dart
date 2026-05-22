import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/booking_model.dart';
import '../models/doctor_model.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';

class BookingConfirmScreen extends StatefulWidget {
  final Booking booking;
  final Doctor doctor;

  const BookingConfirmScreen({
    super.key,
    required this.booking,
    required this.doctor,
  });

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final doctorName =
        lang.isHindi ? widget.doctor.nameHi : widget.doctor.nameEn;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 80),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  lang.t('booking_confirmed'),
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  lang.t('booking_saved'),
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textMedium),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 20,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(lang.t('booking_id'),
                          widget.booking.id.substring(0, 8).toUpperCase()),
                      const Divider(color: AppColors.border, height: 32),
                      _buildDetailRow(
                          lang.t('patient_name'), widget.booking.patientName),
                      const Divider(color: AppColors.border, height: 32),
                      _buildDetailRow(lang.t('doctors'), doctorName),
                      const Divider(color: AppColors.border, height: 32),
                      _buildDetailRow(lang.t('select_slot'),
                          '${widget.booking.date}, ${widget.booking.time}'),
                      const Divider(color: AppColors.border, height: 32),
                      _buildDetailRow(lang.t('fee'),
                          '₹${widget.booking.fee.toStringAsFixed(0)}',
                          isHighlight: true),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                AppButton(
                  text: lang.t('share_whatsapp'),
                  icon: Icons.share_rounded,
                  isPrimary: false,
                  onPressed: () => _shareBooking(lang, doctorName),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: lang.t('go_home'),
                  isPrimary: true,
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.primary : AppColors.textDark,
              fontSize: isHighlight ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _shareBooking(LanguageProvider lang, String doctorName) async {
    final message = '''
${lang.t('booking_confirmed')}
${lang.t('booking_id')}: ${widget.booking.id.substring(0, 8).toUpperCase()}
${lang.t('patient_name')}: ${widget.booking.patientName}
${lang.t('doctors')}: $doctorName
${lang.t('select_slot')}: ${widget.booking.date}, ${widget.booking.time}
${lang.t('fee')}: ₹${widget.booking.fee.toStringAsFixed(0)}
''';

    final url =
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch WhatsApp');
    }
  }
}

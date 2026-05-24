import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';
import 'teleconsult/prescription_card.dart';
import 'teleconsult/rating_sheet.dart';

class ConsultationCompletionScreen extends StatefulWidget {
  const ConsultationCompletionScreen({super.key});

  @override
  State<ConsultationCompletionScreen> createState() => _ConsultationCompletionScreenState();
}

class _ConsultationCompletionScreenState extends State<ConsultationCompletionScreen> {
  double _overallRating = 5.0;
  double _behaviorRating = 5.0;
  double _explanationRating = 5.0;
  double _waitRating = 5.0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Consultation Overview',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _submitted ? _buildSuccessView(lang) : _buildCompletionView(lang),
        ),
      ),
    );
  }

  Widget _buildCompletionView(LanguageProvider lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header message
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Consultation Completed!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your digital prescription is ready below.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 1. Professional Clinic styled Digital Prescription Card
          PrescriptionCard(lang: lang),
          const SizedBox(height: 32),

          // 2. Feedback Star Rating Section Sheet
          RatingSheet(
            overallRating: _overallRating,
            behaviorRating: _behaviorRating,
            explanationRating: _explanationRating,
            waitRating: _waitRating,
            feedbackController: _feedbackController,
            onOverallUpdate: (rating) => setState(() => _overallRating = rating),
            onBehaviorUpdate: (rating) => setState(() => _behaviorRating = rating),
            onExplanationUpdate: (rating) => setState(() => _explanationRating = rating),
            onWaitUpdate: (rating) => setState(() => _waitRating = rating),
            lang: lang,
          ),
          const SizedBox(height: 32),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Submit Feedback & Return Home',
              onPressed: () {
                debugPrint('Feedback submitted: Overall: $_overallRating, Explanation: $_explanationRating, Behavior: $_behaviorRating, Wait: $_waitRating, Comments: ${_feedbackController.text}');
                setState(() => _submitted = true);
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuccessView(LanguageProvider lang) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.celebration_rounded, color: AppColors.primary, size: 64),
            ),
            const SizedBox(height: 32),
            const Text(
              'Thank You, Rakesh!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your review has been successfully submitted. It helps thousands of other patients in Bihar find high-quality care.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textMedium, height: 1.5),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Back to Home Dashboard',
                onPressed: () {
                  Navigator.pop(context); // Go back to Home
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

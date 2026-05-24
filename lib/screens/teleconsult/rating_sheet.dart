import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../providers/language_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingSheet extends StatelessWidget {
  final double overallRating;
  final double behaviorRating;
  final double explanationRating;
  final double waitRating;
  final TextEditingController feedbackController;
  final ValueChanged<double> onOverallUpdate;
  final ValueChanged<double> onBehaviorUpdate;
  final ValueChanged<double> onExplanationUpdate;
  final ValueChanged<double> onWaitUpdate;
  final LanguageProvider lang;

  const RatingSheet({
    super.key,
    required this.overallRating,
    required this.behaviorRating,
    required this.explanationRating,
    required this.waitRating,
    required this.feedbackController,
    required this.onOverallUpdate,
    required this.onBehaviorUpdate,
    required this.onExplanationUpdate,
    required this.onWaitUpdate,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How was your consultation experience?',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Center(
            child: RatingBar.builder(
              initialRating: overallRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star_rounded,
                color: Colors.amber,
              ),
              onRatingUpdate: onOverallUpdate,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 20),

          // Practo dimensions
          _buildRatingDimension('Doctor Explanation & Diagnosis', explanationRating, onExplanationUpdate),
          const SizedBox(height: 16),
          _buildRatingDimension('Doctor Empathy & Behavior', behaviorRating, onBehaviorUpdate),
          const SizedBox(height: 16),
          _buildRatingDimension('Wait Time Experience', waitRating, onWaitUpdate),
          const SizedBox(height: 24),

          // Feedback comment
          const Text('Write your detailed review (optional)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: feedbackController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Share your feedback about doctor diagnosis, friendliness, clinic hygiene...',
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDimension(String label, double rating, ValueChanged<double> onUpdate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMedium, fontWeight: FontWeight.w500)),
        ),
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemSize: 18,
          itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
          itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber),
          onRatingUpdate: onUpdate,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../providers/language_provider.dart';

class PrescriptionCard extends StatelessWidget {
  final LanguageProvider lang;

  const PrescriptionCard({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Clinical Letterhead header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DOCTOR MITRA DIGITAL RX CLINIC', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13, letterSpacing: 0.5)),
                      SizedBox(height: 2),
                      Text('Aarogya Clinic, Boring Road, Patna, Bihar', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor and Patient Metadata
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. Rajeev Kumar', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 15)),
                        Text('MBBS, MD (Medicine)', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        Text('Reg No: MCI-88741', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Patient: Rakesh Kumar', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 13)),
                        Text('Age: 28  Gender: Male', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        Text('Date: 22 May 2026', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.border),

                // Symptoms / Diagnostics Info
                const Text('Symptoms / Symptoms Noted', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 12)),
                const SizedBox(height: 4),
                const Text('High fever, body aches, headache since last night.', style: TextStyle(color: AppColors.textMedium, fontSize: 13)),
                const SizedBox(height: 16),

                // Rx Prescribed Medicine Table
                const Row(
                  children: [
                    Icon(Icons.medication_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text('Rx (Prescribed Medicines)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMedicineItem('Tab. Paracetamol 650mg', '1 tablet - TDS (Three times a day) - 5 days', 'After Food'),
                _buildMedicineItem('Tab. Amoxycillin 500mg', '1 tablet - BD (Two times a day) - 5 days', 'After Food'),
                _buildMedicineItem('Syp. Multivitamin', '10ml - OD (Once a day) - 10 days', 'Before Food'),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),

                // Clinical Advice
                const Text('Advice / Instructions', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 12)),
                const SizedBox(height: 4),
                const Text('Rest well, drink plenty of fluids, and check temperature every 4 hours.', style: TextStyle(color: AppColors.textMedium, fontSize: 13, height: 1.4)),
                const SizedBox(height: 24),

                // Digital signature & share buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 10),
                              SizedBox(width: 4),
                              Text('DIGITALLY SIGNED', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Dr. Rajeev Kumar', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Row(
                      children: [
                        _buildRxActionButton(icon: Icons.download_rounded, label: 'Download', onTap: () {}),
                        const SizedBox(width: 8),
                        _buildRxActionButton(icon: Icons.share_rounded, label: 'Share', onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineItem(String name, String dose, String timing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(dose, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(timing, style: const TextStyle(fontSize: 10, color: AppColors.textMedium, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRxActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

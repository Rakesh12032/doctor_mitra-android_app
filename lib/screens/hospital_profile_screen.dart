import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';
import '../widgets/doctor_card.dart';
import '../data/doctors_data.dart';

class HospitalProfileScreen extends StatefulWidget {
  final Map<String, dynamic> hospital;

  const HospitalProfileScreen({super.key, required this.hospital});

  @override
  State<HospitalProfileScreen> createState() => _HospitalProfileScreenState();
}

class _HospitalProfileScreenState extends State<HospitalProfileScreen> {
  bool _showSuccessOverlay = false;

  final List<String> _departments = [
    'General Medicine',
    'Cardiology',
    'Gynecology & Obstetric',
    'Pediatrics',
    'Trauma & ICU',
    '24/7 Pharmacy',
  ];

  final List<String> _departmentsHi = [
    'सामान्य चिकित्सा',
    'हृदय रोग विभाग',
    'स्त्री एवं प्रसूति रोग',
    'बाल रोग विभाग',
    'ट्रॉमा एवं आईसीयू',
    '24/7 फार्मेसी',
  ];

  void _triggerOpdBooking(LanguageProvider lang) {
    setState(() {
      _showSuccessOverlay = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessOverlay = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;
    final hosp = widget.hospital;

    // Filter doctors working in this hospital city
    final affiliatedDoctors = DoctorsData.doctors.where((d) {
      return d.districtEn.toLowerCase() == hosp['cityEn'].toString().toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Immersive Silver Appbar
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                    child: const LanguageToggle(),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Immersive decorative container simulation
                      Container(
                        decoration: const LinearGradientDecoration(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.local_hospital_rounded, size: 64, color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  hosp['typeEn'] ?? 'Trauma Center',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Soft shadow overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hospital Title Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    isHi ? hosp['nameHi']! : hosp['nameEn']!,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                      fontFamily: 'Poppins',
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        hosp['rating'] ?? '4.5',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    isHi ? hosp['addressHi']! : hosp['addressEn']!,
                                    style: const TextStyle(color: AppColors.textMedium, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.airline_seat_flat_angled_outlined, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  isHi 
                                      ? "कुल खाली बिस्तर: ${hosp['beds'] ?? '45 Beds'}" 
                                      : "Available Beds: ${hosp['beds'] ?? '45 Beds'}",
                                  style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // About Hospital Section
                      Text(
                        isHi ? 'हमारे बारे में' : 'About Hospital',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark, fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isHi 
                            ? "${hosp['nameHi']} बिहार का एक उत्कृष्ट स्वास्थ्य देखभाल संस्थान है। यहाँ 24/7 उन्नत आपातकालीन विभाग, आईसीयू, बाल चिकित्सा और कुशल चिकित्सकों की टीम उपलब्ध है।" 
                            : "${hosp['nameEn']} is a state-of-the-art medical institution equipped with modern diagnostics, dedicated critical care ICU units, and top-tier clinical services in Bihar.",
                        style: const TextStyle(color: AppColors.textMedium, fontSize: 14, height: 1.5, fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isHi ? 'राष्ट्रीय अस्पताल प्रत्यायन बोर्ड (NABH) प्रमाणित' : 'NABH Accredited Health Provider',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 28),

                      // Departments Grid
                      Text(
                        isHi ? 'हमारे विभाग' : 'Key Departments',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark, fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.8,
                        ),
                        itemCount: _departments.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Center(
                              child: Text(
                                isHi ? _departmentsHi[index] : _departments[index],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Poppins'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 28),

                      // Affiliated Doctors working in the same city
                      Text(
                        isHi ? 'अस्पताल के विशेषज्ञ डॉक्टर' : 'Specialist Doctors',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark, fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 12),
                      affiliatedDoctors.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
                              child: Text(
                                isHi ? 'इस अस्पताल के लिए कोई डॉक्टर लिस्टेड नहीं है।' : 'No verified doctors listed here.',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: affiliatedDoctors.length,
                              itemBuilder: (context, index) {
                                final doc = affiliatedDoctors[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: DoctorCard(doctor: doc),
                                );
                              },
                            ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Toast / Booking success animation mock overlay
          if (_showSuccessOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 64, color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          isHi ? "OPD अपॉइंटमेंट अनुरोध भेजा गया!" : "OPD Booking Requested!",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isHi 
                              ? "सदर स्वास्थ्य डेस्क जल्द ही आपके मोबाइल पर एसएमएस भेजकर समय की पुष्टि करेगा।" 
                              : "The hospital desk will SMS you shortly to confirm the scheduled time slot.",
                          style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      
      // Immersive Sticky Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          border: Border.all(color: AppColors.border),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  text: isHi ? 'आपातकालीन कॉल' : 'Emergency Call',
                  color: AppColors.error,
                  onPressed: () {
                    final cleanPhone = hosp['phoneEn']?.replaceAll(RegExp(r'\s+'), '') ?? '102';
                    launchUrl(Uri.parse('tel:$cleanPhone'));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: isHi ? 'ओपीडी पर्ची बुक करें' : 'Book OPD Slip',
                  onPressed: () => _triggerOpdBooking(lang),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Inline helper for gradient decoration
class LinearGradientDecoration extends Decoration {
  final List<Color> colors;

  const LinearGradientDecoration({required this.colors});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _LinearGradientBoxPainter(colors);
  }
}

class _LinearGradientBoxPainter extends BoxPainter {
  final List<Color> colors;

  _LinearGradientBoxPainter(this.colors);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & configuration.size!;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }
}

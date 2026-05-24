import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      icon: Icons.person_search_rounded,
      titleEn: "Find Doctors Near You",
      titleHi: "अपने पास के डॉक्टर खोजें",
      descEn: "Browse verified local specialists in Saharsa, Patna, and all across Bihar and UP.",
      descHi: "सहरसा, पटना और संपूर्ण बिहार-यूपी के सत्यापित डॉक्टरों की सूची खोजें।",
    ),
    OnboardingSlideData(
      icon: Icons.calendar_month_rounded,
      titleEn: "Book Appointments Instantly",
      titleHi: "तुरंत अपॉइंटमेंट बुक करें",
      descEn: "Select convenient dates, secure your consultation slots, and get instant reminders.",
      descHi: "सुविधानुसार तिथि और समय स्लॉट चुनें, बुकिंग करें और तुरंत रिमाइंडर पाएं।",
    ),
    OnboardingSlideData(
      icon: Icons.video_camera_front_rounded,
      titleEn: "Consult Online Anytime",
      titleHi: "कभी भी ऑनलाइन परामर्श लें",
      descEn: "Start zero-latency high-quality video consultations and receive digital prescriptions instantly.",
      descHi: "बिना किसी रुकावट के हाई-क्वालिटी वीडियो कॉल शुरू करें और तुरंत डिजिटल पर्चा पाएं।",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Language Selector & Skip Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hindi / English Selector Button
                  GestureDetector(
                    onTap: () {
                      lang.toggleLanguage();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.translate, color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            isHi ? "English" : "हिंदी",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Skip Button (Only show if not on the last page)
                  if (!_isLastPage)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        isHi ? "छोड़ें" : "Skip",
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page Slides View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    _isLastPage = index == _slides.length - 1;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Giant circular gradient icon container (Premium Practo Look)
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.22),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            slide.icon,
                            size: 72,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Title
                        Text(
                          isHi ? slide.titleHi : slide.titleEn,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            fontFamily: 'Nunito',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Description text
                        Text(
                          isHi ? slide.descHi : slide.descEn,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.5,
                            fontFamily: 'Nunito',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Indicators & Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Smooth Indicator dots
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _slides.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.border,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 6,
                    ),
                  ),

                  // Floating Navigation Button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLastPage
                        ? SizedBox(
                            width: 140,
                            child: AppButton(
                              text: isHi ? "शुरू करें" : "Get Started",
                              onPressed: _completeOnboarding,
                              isFullWidth: false,
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeInOutCubic,
                              );
                            },
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlideData {
  final IconData icon;
  final String titleEn;
  final String titleHi;
  final String descEn;
  final String descHi;

  OnboardingSlideData({
    required this.icon,
    required this.titleEn,
    required this.titleHi,
    required this.descEn,
    required this.descHi,
  });
}

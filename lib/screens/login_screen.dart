import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/store_provider.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  String _selectedRole = 'patient';
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _doctorIdController = TextEditingController();
  final TextEditingController _doctorPasswordController = TextEditingController();
  final TextEditingController _adminIdController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _doctorIdController.dispose();
    _doctorPasswordController.dispose();
    _adminIdController.dispose();
    _adminPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendSeconds = 30;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _sendOtp() {
    final mobile = _phoneController.text.trim();
    if (mobile.length != 10) {
      setState(() {
        _errorMessage = Provider.of<LanguageProvider>(context, listen: false).isHindi
            ? 'कृपया 10 अंकों का मोबाइल नंबर दर्ज करें'
            : 'Please enter a valid 10-digit mobile number';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    store.authService.sendPatientOtp(
      mobile: mobile,
      onCodeSent: (verId) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _otpSent = true;
          _verificationId = verId;
          _otpController.clear();
        });
        _startResendTimer();
      },
      onFailed: (err) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = err;
        });
      },
    );
  }

  void _verifyOtp() {
    final mobile = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    final isHi = Provider.of<LanguageProvider>(context, listen: false).isHindi;
    if (otp.length != 6) {
      setState(() {
        _errorMessage = isHi ? 'कृपया 6 अंकों का ओटीपी दर्ज करें' : 'Please enter a 6-digit OTP code';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    store.authService.patientOtpLogin(
      store,
      mobile: mobile,
      otp: otp,
      verificationId: _verificationId,
    ).then((error) {
      if (!mounted) return;
      if (error == null) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      }
    });
  }

  void _loginDoctorOrAdmin() {
    final isHi = Provider.of<LanguageProvider>(context, listen: false).isHindi;
    final email = _selectedRole == 'doctor' ? _doctorIdController.text.trim() : _adminIdController.text.trim();
    final password = _selectedRole == 'doctor' ? _doctorPasswordController.text.trim() : _adminPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = isHi ? 'कृपया आईडी और पासवर्ड दोनों दर्ज करें' : 'Please enter both ID and Password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    Future<String?> loginFuture;
    if (_selectedRole == 'doctor') {
      loginFuture = store.authService.doctorLogin(store, email: email, password: password);
    } else {
      loginFuture = store.authService.adminLogin(store, email: email, password: password);
    }

    loginFuture.then((error) {
      if (!mounted) return;
      if (error == null) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Gradient Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.premiumShadow,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.health_and_safety,
                              size: 32, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isHi
                              ? 'डॉक्टर मित्रा में आपका स्वागत है'
                              : 'Welcome to Doctor Mitra',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Nunito',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isHi
                              ? 'बेहतर स्वास्थ्य देखभाल, अब आपके फोन पर'
                              : 'Premium healthcare, now on your phone',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            fontFamily: 'Nunito',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Role Selection Title
                  Text(
                    isHi
                        ? 'आगे बढ़ने के लिए अपना रोल चुनें'
                        : 'Choose your role to continue',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      fontFamily: 'Nunito',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Premium Role Selection Cards
                  _buildRoleCard(
                    role: 'patient',
                    icon: Icons.person_outline_rounded,
                    title: isHi ? 'मरीज़ (Patient)' : 'Patient Panel',
                    subtitle: isHi
                        ? 'डॉक्टर बुक करें और ऑनलाइन परामर्श लें'
                        : 'Book doctors and consult instantly',
                  ),
                  const SizedBox(height: 12),
                  _buildRoleCard(
                    role: 'doctor',
                    icon: Icons.medical_services_outlined,
                    title: isHi ? 'डॉक्टर (Doctor)' : 'Doctor Panel',
                    subtitle: isHi
                        ? 'स्लॉट प्रबंधित करें और अपॉइंटमेंट देखें'
                        : 'Manage consultation hours & sessions',
                  ),
                  const SizedBox(height: 12),
                  _buildRoleCard(
                    role: 'admin',
                    icon: Icons.admin_panel_settings_outlined,
                    title: isHi ? 'प्रशासक (Admin)' : 'Admin Control Panel',
                    subtitle: isHi
                        ? 'डॉक्टर स्वीकृतियां और रेवेन्यू प्रबंधित करें'
                        : 'Oversee doctor queues & statistics',
                  ),
                  const SizedBox(height: 24),

                  // Error Message Box
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Login Form Card
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey('${_selectedRole}_$_otpSent'),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.premiumShadow,
                        border: Border.all(color: Colors.black.withOpacity(0.015)),
                      ),
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    strokeWidth: 3,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Processing...',
                                    style: TextStyle(
                                      color: AppColors.textMedium,
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_selectedRole == 'patient') ...[
                                  if (!_otpSent) ...[
                                    TextField(
                                      controller: _phoneController,
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      decoration: InputDecoration(
                                        labelText: lang.t('enter_phone'),
                                        counterText: '',
                                        labelStyle: const TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 13,
                                          color: AppColors.textMuted,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.phone_outlined,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    AppButton(
                                      text: lang.t('send_otp'),
                                      onPressed: _sendOtp,
                                    ),
                                  ] else ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${isHi ? 'मोबाइल' : 'Mobile'}: +91 ${_phoneController.text}',
                                          style: const TextStyle(
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(Icons.edit, size: 14, color: AppColors.primary),
                                          label: Text(
                                            isHi ? 'बदलें' : 'Change',
                                            style: const TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _otpSent = false;
                                              _errorMessage = null;
                                              _resendTimer?.cancel();
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _otpController,
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      decoration: InputDecoration(
                                        labelText: isHi ? '६-अंकीय ओटीपी दर्ज करें' : 'Enter 6-digit OTP',
                                        counterText: '',
                                        labelStyle: const TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 13,
                                          color: AppColors.textMuted,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (_resendSeconds > 0)
                                          Text(
                                            isHi
                                                ? 'ओटीपी पुनः भेजें: ${_resendSeconds}s'
                                                : 'Resend OTP in: ${_resendSeconds}s',
                                            style: const TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 12,
                                              color: AppColors.textMedium,
                                            ),
                                          )
                                        else
                                          TextButton(
                                            onPressed: _sendOtp,
                                            child: Text(
                                              isHi ? 'ओटीपी पुनः भेजें' : 'Resend OTP',
                                              style: const TextStyle(
                                                fontFamily: 'Nunito',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    AppButton(
                                      text: isHi ? 'ओटीपी सत्यापित करें' : 'Verify & Login',
                                      onPressed: _verifyOtp,
                                    ),
                                  ],
                                ] else if (_selectedRole == 'doctor') ...[
                                  TextField(
                                    controller: _doctorIdController,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: isHi ? 'ईमेल / लॉगिन आईडी' : 'Doctor Email / Login ID',
                                      labelStyle: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _doctorPasswordController,
                                    obscureText: true,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: isHi ? 'पासवर्ड' : 'Password',
                                      labelStyle: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  AppButton(
                                    text: isHi ? 'लॉगिन करें' : 'Login Now',
                                    onPressed: _loginDoctorOrAdmin,
                                  ),
                                ] else if (_selectedRole == 'admin') ...[
                                  TextField(
                                    controller: _adminIdController,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: isHi ? 'एडमिन ईमेल / आईडी' : 'Admin Email / ID',
                                      labelStyle: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.admin_panel_settings_outlined,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _adminPasswordController,
                                    obscureText: true,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: isHi ? 'पासवर्ड' : 'Password',
                                      labelStyle: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  AppButton(
                                    text: isHi ? 'लॉगिन करें' : 'Login Now',
                                    onPressed: _loginDoctorOrAdmin,
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Demo Credentials Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_person_outlined, color: AppColors.primary, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Demo Credentials (Click role card above, then use below)',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColors.textDark,
                                    fontFamily: 'Nunito'),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Patient: 9876543210 (OTP: 123456)\nDoctor: rajeev@doctormitra.in / doctor123\nAdmin: admin@doctormitra.in / Rakesh@12032',
                                style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                    height: 1.3),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    lang.t('data_safe'),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontFamily: 'Nunito',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ]
              : AppColors.premiumShadow,
        ),
        child: Row(
          children: [
            // Left circular avatar (light green bg, dark green icon)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 24,
                  color: isSelected ? Colors.white : AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Nunito',
                      color: isSelected ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Nunito',
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: isSelected ? AppColors.primary : Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

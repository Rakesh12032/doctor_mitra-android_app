import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../providers/language_provider.dart';
import '../providers/store_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/language_toggle.dart';

class AbhaScreen extends StatefulWidget {
  const AbhaScreen({super.key});

  @override
  State<AbhaScreen> createState() => _AbhaScreenState();
}

class _AbhaScreenState extends State<AbhaScreen> {
  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isLinked = false;
  String _abhaNumber = '';
  String _transactionId = '';
  
  // Card profile details
  String _cardName = '';
  String _cardAbhaId = '';
  String _cardGender = '';
  String _cardDob = '';
  String _cardPhoto = '';
  String _cardQrText = '';

  final _abhaController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLinkedStatus();
  }

  @override
  void dispose() {
    _abhaController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _checkLinkedStatus() async {
    setState(() {
      _isLoading = true;
    });

    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    final user = store.currentUser;
    
    // Check locally in SharedPreferences first (offline robustness)
    final prefs = await SharedPreferences.getInstance();
    final localLinked = prefs.getBool('abha_linked_${user?.id}') ?? false;
    
    if (localLinked) {
      setState(() {
        _cardName = prefs.getString('abha_name_${user?.id}') ?? 'Rakesh Raj';
        _cardAbhaId = prefs.getString('abha_id_${user?.id}') ?? '18-0512-3294-8501';
        _cardGender = prefs.getString('abha_gender_${user?.id}') ?? 'Male';
        _cardDob = prefs.getString('abha_dob_${user?.id}') ?? '18-05-1996';
        _cardPhoto = prefs.getString('abha_photo_${user?.id}') ?? 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=400&q=80';
        _cardQrText = prefs.getString('abha_qr_${user?.id}') ?? 'ABDM:ABHA-CARD:14-digit:18051232948501:name:Rakesh Raj';
        _isLinked = true;
        _isLoading = false;
      });
      return;
    }

    if (InternetApiLayer.isConfiguredStatic && user != null) {
      try {
        final apiBaseUrl = const String.fromEnvironment('DOCTOR_MITRA_API_URL');
        final response = await http.get(
          Uri.parse('$apiBaseUrl/api/abha/${user.id}'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          if (body['success'] == true && body['linked'] == true) {
            final data = body['data'];
            
            // Save locally
            await prefs.setBool('abha_linked_${user.id}', true);
            await prefs.setString('abha_name_${user.id}', data['name']);
            await prefs.setString('abha_id_${user.id}', data['abhaNumber']);
            await prefs.setString('abha_gender_${user.id}', data['gender']);
            await prefs.setString('abha_dob_${user.id}', data['dob']);
            await prefs.setString('abha_photo_${user.id}', data['photo']);
            await prefs.setString('abha_qr_${user.id}', data['qrCodeText']);

            setState(() {
              _cardName = data['name'];
              _cardAbhaId = data['abhaNumber'];
              _cardGender = data['gender'];
              _cardDob = data['dob'];
              _cardPhoto = data['photo'];
              _cardQrText = data['qrCodeText'];
              _isLinked = true;
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("ABHA Screen check error: $e");
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _sendVerificationOtp() async {
    final abhaInput = _abhaController.text.replaceAll('-', '').replaceAll(' ', '').trim();
    if (abhaInput.length != 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).isHindi
                ? "कृपया सही 14-अंकों का आभा नंबर दर्ज करें।"
                : "Please enter a valid 14-digit ABHA number.",
            style: const TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _abhaNumber = abhaInput;
    });

    if (InternetApiLayer.isConfiguredStatic) {
      try {
        final apiBaseUrl = const String.fromEnvironment('DOCTOR_MITRA_API_URL');
        final response = await http.post(
          Uri.parse('$apiBaseUrl/api/abha/verify'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'abhaNumber': _abhaNumber,
            'action': 'send_otp',
          }),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          if (body['success'] == true) {
            setState(() {
              _transactionId = body['data']['transactionId'];
              _isOtpSent = true;
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("ABHA verify REST API failed: $e");
      }
    }

    // Offline / Sandbox Mock OTP Dispatch
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _transactionId = "txn_mock_abha_123";
      _isOtpSent = true;
      _isLoading = false;
    });
  }

  Future<void> _verifyOtpAndCreateCard() async {
    final otpInput = _otpController.text.trim();
    if (otpInput.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).isHindi
                ? "कृपया 6-अंकों का ओटीपी दर्ज करें।"
                : "Please enter 6-digit OTP.",
            style: const TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    final user = store.currentUser;

    if (InternetApiLayer.isConfiguredStatic && user != null) {
      try {
        final apiBaseUrl = const String.fromEnvironment('DOCTOR_MITRA_API_URL');
        final verifyRes = await http.post(
          Uri.parse('$apiBaseUrl/api/abha/verify'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'abhaNumber': _abhaNumber,
            'action': 'verify_otp',
            'otp': otpInput,
            'transactionId': _transactionId,
          }),
        ).timeout(const Duration(seconds: 5));

        if (verifyRes.statusCode == 200) {
          final verifyBody = jsonDecode(verifyRes.body) as Map<String, dynamic>;
          if (verifyBody['success'] == true) {
            final profile = verifyBody['data'];

            // Link in backend
            final linkRes = await http.post(
              Uri.parse('$apiBaseUrl/api/abha/link'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'userId': user.id,
                'abhaNumber': _abhaNumber,
                'abhaAddress': profile['abhaAddress'],
              }),
            ).timeout(const Duration(seconds: 5));

            if (linkRes.statusCode == 200) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('abha_linked_${user.id}', true);
              await prefs.setString('abha_name_${user.id}', profile['name']);
              await prefs.setString('abha_id_${user.id}', _abhaNumber);
              await prefs.setString('abha_gender_${user.id}', profile['gender']);
              await prefs.setString('abha_dob_${user.id}', profile['dob']);
              await prefs.setString('abha_photo_${user.id}', profile['photo']);
              await prefs.setString('abha_qr_${user.id}', profile['qrCodeText']);

              setState(() {
                _cardName = profile['name'];
                _cardAbhaId = _abhaNumber;
                _cardGender = profile['gender'];
                _cardDob = profile['dob'];
                _cardPhoto = profile['photo'];
                _cardQrText = profile['qrCodeText'];
                _isLinked = true;
                _isLoading = false;
              });
              return;
            }
          }
        }
      } catch (e) {
        debugPrint("ABHA OTP Verify backend failed: $e");
      }
    }

    // Mock Offline execution (Success with standard demo OTP 123456)
    if (otpInput == '123456' || otpInput == '654321') {
      await Future.delayed(const Duration(milliseconds: 1500));
      final prefs = await SharedPreferences.getInstance();
      final targetUserId = user?.id ?? 'temp_patient_99';
      
      await prefs.setBool('abha_linked_$targetUserId', true);
      await prefs.setString('abha_name_$targetUserId', 'Rakesh Raj');
      await prefs.setString('abha_id_$targetUserId', _abhaNumber);
      await prefs.setString('abha_gender_$targetUserId', 'Male');
      await prefs.setString('abha_dob_$targetUserId', '18-05-1996');
      await prefs.setString('abha_photo_$targetUserId', 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=400&q=80');
      await prefs.setString('abha_qr_$targetUserId', 'ABDM:ABHA-CARD:14-digit:$_abhaNumber:name:Rakesh Raj');

      setState(() {
        _cardName = 'Rakesh Raj';
        _cardAbhaId = _abhaNumber;
        _cardGender = 'Male';
        _cardDob = '18-05-1996';
        _cardPhoto = 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=400&q=80';
        _cardQrText = 'ABDM:ABHA-CARD:14-digit:$_abhaNumber:name:Rakesh Raj';
        _isLinked = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).isHindi
                ? "ग़लत ओटीपी। कृपया 123456 का उपयोग करें।"
                : "Invalid OTP code. Please use standard demo OTP 123456.",
            style: const TextStyle(fontFamily: 'Nunito'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _unlinkAbhaCard() async {
    final prefs = await SharedPreferences.getInstance();
    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    final user = store.currentUser;
    final targetUserId = user?.id ?? 'temp_patient_99';
    
    await prefs.remove('abha_linked_$targetUserId');
    await prefs.remove('abha_name_$targetUserId');
    await prefs.remove('abha_id_$targetUserId');
    await prefs.remove('abha_gender_$targetUserId');
    await prefs.remove('abha_dob_$targetUserId');
    await prefs.remove('abha_photo_$targetUserId');
    await prefs.remove('abha_qr_$targetUserId');

    setState(() {
      _isLinked = false;
      _isOtpSent = false;
      _abhaController.clear();
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.primary),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(
          isHi ? 'डिजिटल आभा कार्ड' : 'ABHA Health Card',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Nunito'),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _isLinked ? _buildAbhaCardLayout(isHi) : _buildLinkFormLayout(isHi),
            ),
    );
  }

  Widget _buildAbhaCardLayout(bool isHi) {
    final formattedAbha = _cardAbhaId.length == 14
        ? '${_cardAbhaId.substring(0, 2)}-${_cardAbhaId.substring(2, 6)}-${_cardAbhaId.substring(6, 10)}-${_cardAbhaId.substring(10, 14)}'
        : _cardAbhaId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Premium ABHA Card Render
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F9D58), Color(0xFF0B6E4F)], // National deep green gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B6E4F).withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gov Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AYUSHMAN BHARAT DIGITAL MISSION',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Nunito'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isHi ? 'राष्ट्रीय स्वास्थ्य प्राधिकरण' : 'National Health Authority',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 8, fontFamily: 'Nunito'),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.health_and_safety, color: Colors.orange, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          isHi ? 'आभा' : 'ABHA',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 24, thickness: 1),

              // Patient Info Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo Avatar
                  Container(
                    width: 72,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white30, width: 1.5),
                      image: DecorationImage(
                        image: NetworkImage(_cardPhoto),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cardName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
                        ),
                        const SizedBox(height: 6),
                        _buildCardField(isHi ? 'आभा संख्या' : 'ABHA Number', formattedAbha, isBold: true),
                        _buildCardField(isHi ? 'आभा पता' : 'ABHA Address', '${_cardName.replaceAll(' ', '').toLowerCase()}@abdm'),
                        _buildCardField(isHi ? 'लिंग' : 'Gender', isHi ? (_cardGender == 'Male' ? 'पुरुष' : 'महिला') : _cardGender),
                        _buildCardField(isHi ? 'जन्म तिथि' : 'DOB', _cardDob),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 24, thickness: 1),

              // Footer with QR Code
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified, color: Colors.blue, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'ABDM VERIFIED',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Digital Health Locker Linked',
                        style: TextStyle(color: Colors.white70, fontSize: 8, fontFamily: 'Nunito'),
                      ),
                    ],
                  ),
                  // Mock QR Code block
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.qr_code_2, color: Colors.black, size: 40),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Link with Health Records Notification info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.link, color: AppColors.primary, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHi ? 'हेल्थ लॉकर से लिंक किया गया' : 'Linked to Digital Health Locker',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isHi
                          ? 'आपके सभी पर्चे, दवाइयाँ और लैब रिपोर्ट सीधे आपके ABHA खाते से सिंक्रोनाइज़ की जाएंगी।'
                          : 'Your prescriptions, diagnostics, and doctor logs will automatically sync securely to your governmental health locker account.',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.3, fontFamily: 'Nunito'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Unlink Card Trigger
        OutlinedButton.icon(
          onPressed: _unlinkAbhaCard,
          icon: const Icon(Icons.link_off, color: AppColors.error),
          label: Text(
            isHi ? 'आभा कार्ड को हटाएँ' : 'Unlink ABHA Card',
            style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildCardField(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Nunito'),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkFormLayout(bool isHi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Branding Banner / Badge
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 3),
            ),
            child: const Icon(Icons.health_and_safety, color: AppColors.primary, size: 36),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isHi ? 'आयुष्मान भारत डिजिटल हेल्थ खाता' : 'Ayushman Bharat ABHA Account',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textDark, fontFamily: 'Nunito'),
        ),
        const SizedBox(height: 8),
        Text(
          isHi
              ? 'अपना 14-अंकीय ABHA (आयुष्मान भारत स्वास्थ्य खाता) जोड़ें या एक नया डिजिटल हेल्थ आईडी बनाएं।'
              : 'Link your 14-digit Ayushman Bharat Health Account (ABHA) to store all digital medical prescriptions in a unified government-compliant card.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.4, fontFamily: 'Nunito'),
        ),
        const SizedBox(height: 32),

        // Links Selection: Option Links
        Row(
          children: [
            Expanded(
              child: _buildSelectOption(
                isHi ? 'ABHA कार्ड लिंक करें' : 'Link Existing ABHA',
                Icons.link,
                true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSelectOption(
                isHi ? 'नया ABHA बनाएं' : 'Create New ABHA',
                Icons.add_card,
                false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        if (!_isOtpSent) ...[
          // Step 1: Input ABHA Number
          Text(
            isHi ? '14-अंकों का आभा संख्या दर्ज करें' : 'Enter 14-digit ABHA ID',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _abhaController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'e.g. 18-0512-3294-8501',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              prefixIcon: const Icon(Icons.credit_card_rounded, color: AppColors.primary),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _sendVerificationOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isHi ? 'ओटीपी प्राप्त करें' : 'Generate Verification OTP',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Nunito'),
            ),
          ),
        ] else ...[
          // Step 2: OTP Verification
          Text(
            isHi ? 'रजिस्टर मोबाइल पर भेजा ओटीपी दर्ज करें' : 'Enter Verification OTP',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 4),
          Text(
            isHi
                ? 'आधार-लिंक मोबाइल नंबर पर 6-अंकों का कोड भेजा गया है।'
                : 'A 6-digit confirmation code has been dispatched to the mobile linked to your Aadhaar card.',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(fontFamily: 'Nunito', letterSpacing: 8, fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              counterText: '',
              hintText: 'XXXXXX',
              hintStyle: TextStyle(letterSpacing: 4, color: AppColors.textMuted, fontSize: 16),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _verifyOtpAndCreateCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isHi ? 'कार्ड सत्यापित करें और लिंक करें' : 'Verify & Link Health Card',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Nunito'),
            ),
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              setState(() {
                _isOtpSent = false;
                _otpController.clear();
              });
            },
            child: Text(
              isHi ? 'संख्या बदलें' : 'Change ABHA number',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectOption(String label, IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
          width: isActive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: isActive ? AppColors.primary : AppColors.textMedium, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.primary : AppColors.textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

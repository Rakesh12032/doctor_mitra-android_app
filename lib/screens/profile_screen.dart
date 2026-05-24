import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_colors.dart';
import 'health_card_screen.dart';
import 'health_vault_screen.dart';
import 'family_members_screen.dart';
import 'login_screen.dart';
import 'abha_screen.dart';
import 'my_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Editable details states
  String _bloodGroup = "O+";
  String _allergies = "Dust, Penicillin";
  String _chronic = "None";
  bool _notifSms = true;
  bool _notifReminders = true;

  void _showEditHealthDialog(BuildContext context, LanguageProvider lang) {
    final bloodController = TextEditingController(text: _bloodGroup);
    final allergyController = TextEditingController(text: _allergies);
    final chronicController = TextEditingController(text: _chronic);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            lang.isHindi ? "स्वास्थ्य विवरण संपादित करें" : "Edit Health Summary",
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bloodController,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                decoration: InputDecoration(labelText: lang.isHindi ? 'रक्त समूह' : 'Blood Group'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: allergyController,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                decoration: InputDecoration(labelText: lang.isHindi ? 'ज्ञात एलर्जी' : 'Known Allergies'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: chronicController,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                decoration: InputDecoration(labelText: lang.isHindi ? 'पुरानी बीमारी' : 'Chronic Conditions'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.isHindi ? 'रद्द करें' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _bloodGroup = bloodController.text.trim();
                  _allergies = allergyController.text.trim();
                  _chronic = chronicController.text.trim();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(lang.isHindi ? 'सहेजें' : 'Save', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
        title: Text(lang.t('profile')),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Immersive User Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 3),
                          ),
                          child: const Icon(Icons.person_rounded, size: 48, color: AppColors.primary),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Rajeev Kumar',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontFamily: 'Poppins',
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isHi ? 'प्राइमरी मरीज़ खाता' : 'Primary Patient Account',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMedium, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Health Summary Card (Editable)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isHi ? 'स्वास्थ्य सारांश' : 'Health Summary',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark, fontFamily: 'Poppins'),
                  ),
                  TextButton.icon(
                    onPressed: () => _showEditHealthDialog(context, lang),
                    icon: const Icon(Icons.edit, size: 14, color: AppColors.primary),
                    label: Text(isHi ? 'बदलें' : 'Edit', style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(isHi ? 'रक्त समूह' : 'Blood Group', _bloodGroup),
                    const Divider(color: AppColors.border, height: 20),
                    _buildSummaryRow(isHi ? 'ज्ञात एलर्जी' : 'Known Allergies', _allergies),
                    const Divider(color: AppColors.border, height: 20),
                    _buildSummaryRow(isHi ? 'पुरानी बीमारी' : 'Chronic Illness', _chronic),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              
              // Medical Features
              Text(
                isHi ? 'स्वास्थ्य उपकरण' : 'Medical Folders',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 12),
              
              _buildFeatureTile(
                icon: Icons.people_outline_rounded,
                title: isHi ? 'परिवार के सदस्य' : 'Family Members',
                subtitle: isHi ? 'सदस्यों को जोड़ें और प्रबंधित करें' : 'Manage your loved ones',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FamilyMembersScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildFeatureTile(
                icon: Icons.folder_shared_outlined,
                title: isHi ? 'डिजिटल हेल्थ वॉल्ट' : 'Digital Health Vault',
                subtitle: isHi ? 'लैब रिपोर्ट और पर्चे सहेजें' : 'Save lab reports & prescriptions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HealthVaultScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildFeatureTile(
                icon: Icons.badge_outlined,
                title: lang.t('health_card'),
                subtitle: isHi ? 'डिजिटल मेडिकल आईडी कार्ड' : 'Digital health ID card',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HealthCardScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildFeatureTile(
                icon: Icons.badge_outlined,
                title: isHi ? 'आभा हेल्थ कार्ड' : 'ABHA Health Card',
                subtitle: isHi ? 'डिजिटल आयुष्मान भारत आईडी कार्ड' : 'Digital Ayushman Bharat ID card',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AbhaScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildFeatureTile(
                icon: Icons.local_shipping_outlined,
                title: isHi ? 'दवाइयों के आर्डर्स' : 'My Medicine Orders',
                subtitle: isHi ? 'खरीदी गयी दवाइयों की सूची एवं ट्रैकिंग' : 'Track and review past orders',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
                  );
                },
              ),
              
              const SizedBox(height: 28),

              // Push Notification Preferences
              Text(
                isHi ? 'सूचना प्राथमिकताएं' : 'Notification Settings',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      activeColor: AppColors.primary,
                      title: Text(isHi ? 'व्हाट्सएप एवं एसएमएस अपडेट' : 'WhatsApp & SMS Alerts', style: const TextStyle(fontSize: 14, fontFamily: 'Poppins')),
                      subtitle: Text(isHi ? 'बुकिंग अपडेट तुरंत मोबाइल पर पाएं' : 'Get instant OTPs and bookings', style: const TextStyle(fontSize: 12)),
                      value: _notifSms,
                      onChanged: (val) {
                        setState(() {
                          _notifSms = val;
                        });
                      },
                    ),
                    const Divider(color: AppColors.border),
                    SwitchListTile(
                      activeColor: AppColors.primary,
                      title: Text(isHi ? 'अपॉइंटमेंट अलार्म रिमाइंडर' : 'Appointment Reminders', style: const TextStyle(fontSize: 14, fontFamily: 'Poppins')),
                      subtitle: Text(isHi ? 'कॉल से 1 घंटा पहले अलर्ट' : 'Alert 1 hour before scheduled call', style: const TextStyle(fontSize: 12)),
                      value: _notifReminders,
                      onChanged: (val) {
                        setState(() {
                          _notifReminders = val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardBg,
                    foregroundColor: AppColors.error,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.error, width: 1.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, size: 22),
                      const SizedBox(width: 8),
                      Text(lang.t('logout'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'v1.1.0 • Made with ❤️ in Bihar',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMedium, fontSize: 13, fontFamily: 'Poppins')),
        Text(val, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins')),
      ],
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark, fontFamily: 'Poppins')),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 22),
      ),
    );
  }
}

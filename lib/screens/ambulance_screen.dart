import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';

class AmbulanceScreen extends StatefulWidget {
  const AmbulanceScreen({super.key});

  @override
  State<AmbulanceScreen> createState() => _AmbulanceScreenState();
}

class _AmbulanceScreenState extends State<AmbulanceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _selectedCity = 'Saharsa';

  final List<String> _cities = ['Saharsa', 'Patna', 'Supaul', 'Madhepura', 'Darbhanga'];

  final List<Map<String, dynamic>> _mockAmbulances = [
    {
      'nameEn': 'Saharsa Sadar ICU Ambulance',
      'nameHi': 'सहरसा सदर आईसीयू एम्बुलेंस',
      'typeEn': 'ICU/Advanced Life Support',
      'typeHi': 'आईसीयू/उन्नत लाइफ सपोर्ट',
      'eta': '8-12 min',
      'phone': '102',
      'city': 'Saharsa',
      'isGovt': true,
    },
    {
      'nameEn': 'Mithila Cardiac Ambulance',
      'nameHi': 'मिथिला कार्डियक एम्बुलेंस',
      'typeEn': 'Cardiac Support',
      'typeHi': 'कार्डियक सपोर्ट',
      'eta': '10-15 min',
      'phone': '+91 9471800200',
      'city': 'Saharsa',
      'isGovt': false,
    },
    {
      'nameEn': 'Patna Emergency Core Transport',
      'nameHi': 'पटना इमरजेंसी कोर ट्रांसपोर्ट',
      'typeEn': 'Advanced Ventilator Support',
      'typeHi': 'उन्नत वेंटिलेटर सपोर्ट',
      'eta': '5-8 min',
      'phone': '+91 9934102102',
      'city': 'Patna',
      'isGovt': false,
    },
    {
      'nameEn': 'Supaul Public Health Transport',
      'nameHi': 'सुपौल जन स्वास्थ्य परिवहन',
      'typeEn': 'Basic Life Support',
      'typeHi': 'बेसिक लाइफ सपोर्ट',
      'eta': '12-18 min',
      'phone': '102',
      'city': 'Supaul',
      'isGovt': true,
    },
  ];

  final List<Map<String, dynamic>> _emergencyContacts = [
    {'nameEn': 'Ambulance Helpline', 'nameHi': 'एम्बुलेंस हेल्पलाइन', 'number': '102', 'desc': 'Free Govt Service'},
    {'nameEn': 'Medical Helpline Bihar', 'nameHi': 'चिकित्सा हेल्पलाइन बिहार', 'number': '104', 'desc': '24/7 Health Desk'},
    {'nameEn': 'AIIMS Patna Emergency', 'nameHi': 'एम्स पटना इमरजेंसी', 'number': '06122451200', 'desc': 'Trauma/Critical'},
    {'nameEn': 'Sadar Hospital Saharsa Desk', 'nameHi': 'सदर अस्पताल सहरसा डेस्क', 'number': '06478222001', 'desc': 'Local Emergency'},
  ];

  final List<Map<String, dynamic>> _nearestHospitals = [
    {
      'nameEn': 'Sadar Sadar Hospital Saharsa',
      'nameHi': 'सदर अस्पताल सहरसा',
      'distance': '1.2 km',
      'beds': '24 Beds Free',
      'phone': '06478222001',
    },
    {
      'nameEn': 'Koshi Trauma Care Center',
      'nameHi': 'कोशी ट्रॉमा केयर सेंटर',
      'distance': '2.8 km',
      'beds': '6 Beds Free',
      'phone': '+91 9431209340',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _makeCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri url = Uri.parse('tel:$cleanPhone');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch dialer');
    }
  }

  void _showEmergencyContactsSheet(BuildContext context, LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                lang.isHindi ? 'आपातकालीन हॉटलाइन सूची' : 'Emergency Hotlines',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _emergencyContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _emergencyContacts[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.error),
                      ),
                      title: Text(
                        lang.isHindi ? contact['nameHi']! : contact['nameEn']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                      subtitle: Text(
                        "${contact['number']} (${contact['desc']})",
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.call, color: AppColors.primary),
                        onPressed: () => _makeCall(contact['number']!),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _simulateRouteDialog(BuildContext context, String hospitalName, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            lang.isHindi ? "मार्ग सिमुलेशन" : "Route Map Simulation",
            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.map_rounded, size: 80, color: Colors.blueAccent),
                    Positioned(
                      top: 20,
                      left: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.my_location, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(lang.isHindi ? "आप" : "You", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.local_hospital, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(lang.isHindi ? "अस्पताल" : "Hospital", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    // Pulsating line
                    Positioned(
                      child: Icon(Icons.navigation, size: 24, color: AppColors.primary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lang.isHindi 
                    ? "$hospitalName तक 1.2 किमी का सबसे तेज़ मार्ग सक्रिय है।" 
                    : "Fastest route (1.2 km) to $hospitalName is active.",
                style: const TextStyle(color: AppColors.textMedium, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.isHindi ? "बंद करें" : "Close", style: const TextStyle(fontWeight: FontWeight.bold)),
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

    final filteredAmbulances = _mockAmbulances.where((amb) => amb['city'] == _selectedCity).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isHi ? 'आपातकालीन सेवाएं' : 'Emergency Services'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Red Pulse Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: AppColors.error.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: GestureDetector(
                          onTap: () => _makeCall('102'),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.error.withOpacity(0.35),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.phone_in_talk_rounded,
                                  size: 48, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isHi ? 'आपातकालीन एम्बुलेंस (102)' : 'Emergency Ambulance (102)',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isHi
                            ? 'बिहार सरकार द्वारा 24/7 निःशुल्क सेवा।'
                            : '24/7 Free Medical Service in Bihar.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () => _showEmergencyContactsSheet(context, lang),
                          icon: const Icon(Icons.list_alt_rounded, size: 18, color: AppColors.error),
                          label: Text(
                            isHi ? 'अन्य आपातकालीन नंबर' : 'Other Helpline Numbers',
                            style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Local City Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHi ? 'शहर चुनें:' : 'Select City:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins'),
                    ),
                    DropdownButton<String>(
                      value: _selectedCity,
                      items: _cities.map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCity = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Ambulance Service Listing
              SectionHeader(
                title: isHi ? 'उपलब्ध एम्बुलेंस सेवा' : 'Available Ambulances',
              ),
              const SizedBox(height: 12),
              
              filteredAmbulances.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
                        child: Text(
                          isHi 
                              ? "$_selectedCity में कोई निजी एम्बुलेंस लिस्टेड नहीं है। आपातकाल में 102 डायल करें।"
                              : "No private ambulances listed in $_selectedCity. Dial 102 for emergency.",
                          style: const TextStyle(color: AppColors.textMedium, fontSize: 13, fontFamily: 'Poppins'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredAmbulances.length,
                      itemBuilder: (context, index) {
                        final amb = filteredAmbulances[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: amb['isGovt'] 
                                      ? AppColors.primary.withOpacity(0.08) 
                                      : Colors.amber.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.airport_shuttle, 
                                  color: amb['isGovt'] ? AppColors.primary : Colors.amber[800], 
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isHi ? amb['nameHi']! : amb['nameEn']!,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins'),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isHi ? amb['typeHi']! : amb['typeEn']!,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 13, color: AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${isHi ? 'पहुंच समय' : 'ETA'}: ${amb['eta']}",
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.call, color: AppColors.primary),
                                onPressed: () => _makeCall(amb['phone']!),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              
              const SizedBox(height: 24),
              
              // Nearest Hospital Suggestions
              SectionHeader(
                title: isHi ? 'नजदीकी ट्रॉमा अस्पताल' : 'Nearest Trauma Hospitals',
              ),
              const SizedBox(height: 12),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _nearestHospitals.length,
                itemBuilder: (context, index) {
                  final hosp = _nearestHospitals[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_hospital, color: AppColors.error, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isHi ? hosp['nameHi']! : hosp['nameEn']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${isHi ? 'दूरी' : 'Distance'}: ${hosp['distance']} • ${hosp['beds']}",
                              style: const TextStyle(color: AppColors.textMedium, fontSize: 12),
                            ),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () => _simulateRouteDialog(
                                    context, 
                                    isHi ? hosp['nameHi']! : hosp['nameEn']!, 
                                    lang,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  child: Text(isHi ? 'मार्ग' : 'Route', style: const TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _makeCall(hosp['phone']!),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  child: Text(isHi ? 'कॉल' : 'Call', style: const TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

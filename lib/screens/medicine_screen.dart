import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../providers/language_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/language_toggle.dart';
import 'medicine_cart_screen.dart';

class LocalMedicine {
  final String id;
  final String name;
  final String genericName;
  final String manufacturer;
  final double price;
  final String composition;
  final List<String> uses;
  final List<String> sideEffects;
  final String dosage;
  final String category;
  final bool isAvailable;

  LocalMedicine({
    required this.id,
    required this.name,
    required this.genericName,
    required this.manufacturer,
    required this.price,
    required this.composition,
    required this.uses,
    required this.sideEffects,
    required this.dosage,
    required this.category,
    required this.isAvailable,
  });
}

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  List<LocalMedicine> _medicines = [];

  final List<LocalMedicine> _localFallbackMedicines = [
    LocalMedicine(
      id: 'med-001',
      name: 'Crocin Pain Relief',
      genericName: 'Paracetamol & Caffeine',
      manufacturer: 'GlaxoSmithKline (GSK) Pharmaceuticals',
      price: 38.5,
      composition: 'Paracetamol 650mg + Caffeine 50mg',
      uses: ['Headache / सिरदर्द', 'Fever / बुखार', 'Body Pain / बदन दर्द', 'Toothache / दांत दर्द'],
      sideEffects: ['Nausea / जी मिचलाना', 'Allergy rashes / एलर्जी चकत्ते', 'Acidity / एसिडिटी'],
      dosage: '1 tablet twice a day after meals, max 3 tablets in 24 hours',
      category: 'Analgesics',
      isAvailable: true,
    ),
    LocalMedicine(
      id: 'med-002',
      name: 'Calpol 650',
      genericName: 'Paracetamol',
      manufacturer: 'GlaxoSmithKline (GSK) IP',
      price: 30.2,
      composition: 'Paracetamol IP 650mg',
      uses: ['Fever / बुखार', 'Pain relief / दर्द निवारक', 'Common cold / सर्दी-जुकाम'],
      sideEffects: ['Allergic reactions / एलर्जी प्रतिक्रियाएं', 'Liver issues if overdosed / ओवरडोज़ पर लीवर की समस्या'],
      dosage: '1 tablet 3-4 times daily as directed by doctor',
      category: 'Antipyretics',
      isAvailable: true,
    ),
    LocalMedicine(
      id: 'med-003',
      name: 'Alersin-L',
      genericName: 'Levocetirizine',
      manufacturer: 'Cipla Ltd',
      price: 55.0,
      composition: 'Levocetirizine Dihydrochloride 5mg',
      uses: ['Sneezing / छींक आना', 'Running nose / बहती नाक', 'Allergic rhinitis / एलर्जी', 'Skin itching / त्वचा की खुजली'],
      sideEffects: ['Drowsiness / नींद आना', 'Dry mouth / मुंह सूखना', 'Fatigue / थकान'],
      dosage: '1 tablet daily at bedtime',
      category: 'Antihistamines',
      isAvailable: true,
    ),
    LocalMedicine(
      id: 'med-004',
      name: 'Pan-D Capsule',
      genericName: 'Pantoprazole & Domperidone',
      manufacturer: 'Alkem Laboratories Ltd',
      price: 142.0,
      composition: 'Pantoprazole 40mg + Domperidone 30mg SR',
      uses: ['Acidity / एसिडिटी', 'Acid reflux / खट्टी डकार', 'Gerd / गैस समस्या', 'Heartburn / सीने में जलन', 'Bloating / पेट फूलना'],
      sideEffects: ['Headache / सिरदर्द', 'Diarrhea / दस्त', 'Flatulence / गैस बनना'],
      dosage: '1 capsule daily in the morning, 30 minutes before breakfast',
      category: 'Antacids',
      isAvailable: true,
    ),
    LocalMedicine(
      id: 'med-005',
      name: 'Combiflam',
      genericName: 'Ibuprofen & Paracetamol',
      manufacturer: 'Sanofi India Ltd',
      price: 45.8,
      composition: 'Ibuprofen 400mg + Paracetamol 325mg',
      uses: ['Muscle pain / मांसपेशियों का दर्द', 'Joint swelling / जोड़ों की सूजन', 'Inflammation / सूजन', 'Tooth pain / दांत का दर्द'],
      sideEffects: ['Stomach upset / पेट खराब', 'Dizziness / चक्कर आना', 'Heartburn / जलन'],
      dosage: '1 tablet twice daily after food',
      category: 'Analgesics',
      isAvailable: true,
    ),
    LocalMedicine(
      id: 'med-006',
      name: 'Azithral 500',
      genericName: 'Azithromycin',
      manufacturer: 'Alembic Pharmaceuticals Ltd',
      price: 119.5,
      composition: 'Azithromycin 500mg',
      uses: ['Bacterial infection / बैक्टीरियल संक्रमण', 'Throat infection / गले में संक्रमण', 'Tonsillitis / टॉन्सिल', 'Bronchitis / ब्रोंकाइटिस'],
      sideEffects: ['Nausea / उल्टी महसूस होना', 'Abdominal pain / पेट दर्द', 'Vomiting / उल्टी'],
      dosage: '1 tablet daily for 3 days, 1 hour before or 2 hours after food',
      category: 'Antibiotics',
      isAvailable: true,
    ),
    LocalMedicine(
      id: 'med-007',
      name: 'Glycomet 500 SR',
      genericName: 'Metformin',
      manufacturer: 'USV Private Ltd',
      price: 24.5,
      composition: 'Metformin Hydrochloride IP 500mg',
      uses: ['Type-2 Diabetes / मधुमेह टाइप-2', 'PCOS / पीसीओएस'],
      sideEffects: ['Nausea / जी मिचलाना', 'Metallic taste / धात्विक स्वाद', 'Stomach pain / पेट दर्द'],
      dosage: '1 tablet with dinner or as suggested by doctor',
      category: 'Antidiabetics',
      isAvailable: true,
    ),
    LocalMedicine(
      id: 'med-008',
      name: 'Amlokind-5',
      genericName: 'Amlodipine',
      manufacturer: 'Mankind Pharma Ltd',
      price: 15.0,
      composition: 'Amlodipine Besylate 5mg',
      uses: ['Hypertension / उच्च रक्तचाप', 'Angina / छाती में दर्द'],
      sideEffects: ['Ankle swelling / टखने में सूजन', 'Headache / सिरदर्द', 'Sleepiness / नींद आना'],
      dosage: '1 tablet daily at the same time every day',
      category: 'Antihypertensives',
      isAvailable: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true;
    });

    if (InternetApiLayer.isConfiguredStatic) {
      try {
        final apiBaseUrl = const String.fromEnvironment('DOCTOR_MITRA_API_URL');
        final response = await http.get(
          Uri.parse('$apiBaseUrl/api/medicines?search=$_searchQuery'),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          if (body['success'] == true && body['data'] is List) {
            final list = body['data'] as List;
            setState(() {
              _medicines = list.map((item) {
                return LocalMedicine(
                  id: (item['_id'] ?? item['id']).toString(),
                  name: item['name'].toString(),
                  genericName: item['genericName'].toString(),
                  manufacturer: item['manufacturer'].toString(),
                  price: double.tryParse(item['price'].toString()) ?? 0.0,
                  composition: item['composition']?.toString() ?? '',
                  uses: item['uses'] != null ? List<String>.from(item['uses'] as List) : [],
                  sideEffects: item['sideEffects'] != null ? List<String>.from(item['sideEffects'] as List) : [],
                  dosage: item['dosage']?.toString() ?? 'As directed by physician',
                  category: item['category']?.toString() ?? 'General',
                  isAvailable: item['isAvailable'] == null ? true : (item['isAvailable'] as bool),
                );
              }).toList();
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("MedicineScreen: Fetch error, falling back: $e");
      }
    }

    // Fallback Offline
    setState(() {
      if (_searchQuery.trim().isEmpty) {
        _medicines = _localFallbackMedicines;
      } else {
        final term = _searchQuery.toLowerCase();
        _medicines = _localFallbackMedicines.where((med) {
          return med.name.toLowerCase().contains(term) ||
              med.genericName.toLowerCase().contains(term) ||
              med.category.toLowerCase().contains(term) ||
              med.uses.any((u) => u.toLowerCase().contains(term));
        }).toList();
      }
      _isLoading = false;
    });
  }

  void _openGoogleMapsPharmacy() async {
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=pharmacy+near+me");
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open maps");
    }
  }

  void _openOnlineOrderLink(String medName) async {
    final query = Uri.encodeComponent(medName);
    
    // Choose Netmeds or 1mg
    final netmedsUrl = Uri.parse("https://www.netmeds.com/catalogsearch/result?q=$query");
    
    if (await canLaunchUrl(netmedsUrl)) {
      await launchUrl(netmedsUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch Netmeds link");
    }
  }

  void _showMedicineDetailSheet(LocalMedicine med, bool isHi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pull Indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 18),

                // Medicine Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.medication_liquid_rounded, color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark, fontFamily: 'Nunito'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            med.genericName,
                            style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            med.manufacturer,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Nunito'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHi ? 'खुदरा मूल्य' : 'Retail Price',
                      style: const TextStyle(color: AppColors.textMedium, fontSize: 13, fontFamily: 'Nunito'),
                    ),
                    Text(
                      '₹${med.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green, fontFamily: 'Nunito'),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),

                // Salt Composition
                _buildSectionDetail(
                  title: isHi ? 'रासायनिक संरचना (Salt)' : 'Salt Composition',
                  content: med.composition.isEmpty ? med.genericName : med.composition,
                  icon: Icons.biotech,
                ),
                
                // Recommended Uses
                _buildSectionList(
                  title: isHi ? 'मुख्य उपयोग (Indications)' : 'Main Medical Uses',
                  items: med.uses,
                  icon: Icons.check_circle_outline,
                  color: AppColors.primary,
                ),

                // Recommended Dosage
                _buildSectionDetail(
                  title: isHi ? 'सामान्य खुराक (Dosage)' : 'Recommended Dosage',
                  content: med.dosage,
                  icon: Icons.schedule_rounded,
                ),

                // Side Effects
                _buildSectionList(
                  title: isHi ? 'दुष्प्रभाव (Side Effects)' : 'Potential Side Effects',
                  items: med.sideEffects,
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.error,
                ),

                const SizedBox(height: 24),

                // Action launchers
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openGoogleMapsPharmacy,
                        icon: const Icon(Icons.map, size: 18, color: Colors.white),
                        label: Text(
                          isHi ? 'नज़दीकी फार्मेसी' : 'Find Pharmacy',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13, fontFamily: 'Nunito'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openOnlineOrderLink(med.name),
                        icon: const Icon(Icons.shopping_cart, size: 18, color: Colors.white),
                        label: Text(
                          isHi ? 'ऑनलाइन ऑर्डर' : 'Order Online',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13, fontFamily: 'Nunito'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionDetail({required String title, required String content, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textMedium),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              content,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMedium, height: 1.3, fontFamily: 'Nunito'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionList({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.12)),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 11, color: color.withOpacity(0.85), fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
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
          isHi ? 'दवाइयों की खोज' : 'Medicine Search',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Nunito'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _fetchMedicines,
          ),
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_rounded, color: AppColors.primary),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MedicineCartScreen()),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                  _fetchMedicines();
                },
                decoration: InputDecoration(
                  hintText: isHi ? 'पेरासिटामोल, अमॉक्सिसिलिन खोजें...' : 'Search paracetamol, amoxicillin...',
                  hintStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                  fillColor: AppColors.background,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),

            // Pharmacy locator quick entry banner
            _buildPharmacyLocatorBanner(isHi),

            // Medicine List results
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 3,
                      ),
                    )
                  : (_medicines.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.medical_services_outlined, size: 56, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                isHi ? 'कोई दवा नहीं मिली' : 'No medicines matched your query',
                                style: const TextStyle(color: AppColors.textMedium, fontSize: 14, fontFamily: 'Nunito'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _medicines.length,
                          itemBuilder: (context, index) {
                            final med = _medicines[index];
                            return _buildMedicineCard(med, isHi);
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacyLocatorBanner(bool isHi) {
    return GestureDetector(
      onTap: _openGoogleMapsPharmacy,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.local_pharmacy, color: Colors.white, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isHi ? 'अपने पास की दवा दुकानें खोजें' : 'Locate Nearby Pharmacies',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Nunito'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isHi ? 'मानचित्र पर तुरंत दुकानें और दिशा-निर्देश देखें' : 'View physical chemist shops directly on Google Maps',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10, fontFamily: 'Nunito'),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(LocalMedicine med, bool isHi) {
    return GestureDetector(
      onTap: () => _showMedicineDetailSheet(med, isHi),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.premiumShadow,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.vaccines, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.textDark, fontFamily: 'Nunito'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    med.genericName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    med.manufacturer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'Nunito'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${med.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: med.isAvailable ? AppColors.primaryLight : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isHi
                        ? (med.isAvailable ? 'स्टॉक में' : 'उपलब्ध नहीं')
                        : (med.isAvailable ? 'In Stock' : 'Out of Stock'),
                    style: TextStyle(
                      color: med.isAvailable ? AppColors.primary : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 8.5,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
                if (med.isAvailable) ...[
                  const SizedBox(height: 6),
                  Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      return InkWell(
                        onTap: () {
                          cart.addItem(
                            id: med.id,
                            name: med.name,
                            genericName: med.genericName,
                            manufacturer: med.manufacturer,
                            price: med.price,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isHi ? '${med.name} कार्ट में जोड़ा गया!' : '${med.name} added to cart!'),
                              duration: const Duration(milliseconds: 800),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_shopping_cart, color: Colors.white, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                isHi ? 'जोड़ें' : 'Add',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

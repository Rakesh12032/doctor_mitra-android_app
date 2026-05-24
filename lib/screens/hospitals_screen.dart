import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_colors.dart';
import 'hospital_profile_screen.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Govt, Private, ICU

  final List<Map<String, dynamic>> _mockHospitals = [
    {
      'id': 'h-1',
      'nameEn': 'Sadar Hospital Saharsa',
      'nameHi': 'सदर अस्पताल सहरसा',
      'typeEn': 'Government Sadar Care',
      'typeHi': 'सरकारी सदर केयर',
      'addressEn': 'Hospital Road, Saharsa, Bihar',
      'addressHi': 'अस्पताल रोड, सहरसा, बिहार',
      'cityEn': 'Saharsa',
      'phoneEn': '06478 222001',
      'rating': '4.2',
      'beds': '35 Beds Free',
      'distance': '1.2 km',
      'isGovt': true,
      'hasIcu': true,
    },
    {
      'nameEn': 'AIIMS Patna Trauma Center',
      'nameHi': 'एम्स पटना ट्रॉमा सेंटर',
      'typeEn': 'Apex Government Care',
      'typeHi': 'शीर्ष सरकारी केयर',
      'addressEn': 'Phulwari Sharif, Patna, Bihar',
      'addressHi': 'फुलवारी शरीफ, पटना, बिहार',
      'cityEn': 'Patna',
      'phoneEn': '0612 2451200',
      'rating': '4.8',
      'beds': '12 Beds Free',
      'distance': '4.5 km',
      'isGovt': true,
      'hasIcu': true,
    },
    {
      'nameEn': 'Sanjeevani Care & ICU Center',
      'nameHi': 'संजीवनी केयर एवं आईसीयू सेंटर',
      'typeEn': 'Private Multispecialty',
      'typeHi': 'निजी मल्टीस्पेशलिटी',
      'addressEn': '45 Kankarbagh Road, Patna, Bihar',
      'addressHi': '45 कंकड़बाग रोड, पटना, बिहार',
      'cityEn': 'Patna',
      'phoneEn': '+91 9934102102',
      'rating': '4.4',
      'beds': '8 Beds Free',
      'distance': '5.8 km',
      'isGovt': false,
      'hasIcu': true,
    },
    {
      'nameEn': 'Koshi Medical Center',
      'nameHi': 'कोशी मेडिकल सेंटर',
      'typeEn': 'Private General Hospital',
      'typeHi': 'निजी सामान्य अस्पताल',
      'addressEn': 'D.B. Road, Saharsa, Bihar',
      'addressHi': 'डी.बी. रोड, सहरसा, बिहार',
      'cityEn': 'Saharsa',
      'phoneEn': '+91 9471800200',
      'rating': '4.1',
      'beds': '20 Beds Free',
      'distance': '2.1 km',
      'isGovt': false,
      'hasIcu': false,
    },
    {
      'nameEn': 'Apollo Clinic Boring Road',
      'nameHi': 'अपोलो क्लिनिक बोरिंग रोड',
      'typeEn': 'Private Clinic & Diagnostic',
      'typeHi': 'निजी क्लिनिक एवं डायग्नोस्टिक',
      'addressEn': 'Boring Canal Road, Patna, Bihar',
      'addressHi': 'बोरिंग कैनाल रोड, पटना, बिहार',
      'cityEn': 'Patna',
      'phoneEn': '+91 9431209340',
      'rating': '4.7',
      'beds': '0 Beds Free',
      'distance': '6.2 km',
      'isGovt': false,
      'hasIcu': false,
    },
    {
      'nameEn': 'Supaul Sadar Care Hospital',
      'nameHi': 'सदर अस्पताल सुपौल',
      'typeEn': 'Government Sadar Care',
      'typeHi': 'सरकारी सदर केयर',
      'addressEn': 'Sadar Hospital Campus, Supaul, Bihar',
      'addressHi': 'सदर अस्पताल परिसर, सुपौल, बिहार',
      'cityEn': 'Supaul',
      'phoneEn': '06473 222300',
      'rating': '4.0',
      'beds': '15 Beds Free',
      'distance': '12.8 km',
      'isGovt': true,
      'hasIcu': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final filteredHospitals = _mockHospitals.where((hosp) {
      final matchesSearch = hosp['nameEn'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hosp['nameHi'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hosp['addressEn'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hosp['addressHi'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesFilter = true;
      if (_selectedFilter == 'Govt') {
        matchesFilter = hosp['isGovt'] == true;
      } else if (_selectedFilter == 'Private') {
        matchesFilter = hosp['isGovt'] == false;
      } else if (_selectedFilter == 'ICU') {
        matchesFilter = hosp['hasIcu'] == true;
      }

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isHi ? 'अस्पताल निर्देशिका' : 'Hospital Directory'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Gorgeous Search Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: isHi ? 'अस्पताल या पता खोजें...' : 'Search hospitals or address...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            
            // Filter Pillsstrip
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('All', isHi ? 'सभी' : 'All'),
                  _buildFilterChip('Govt', isHi ? 'सरकारी' : 'Govt Care'),
                  _buildFilterChip('Private', isHi ? 'निजी अस्पताल' : 'Private Care'),
                  _buildFilterChip('ICU', isHi ? 'आईसीयू उपलब्ध' : 'ICU Available'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Main Listing
            Expanded(
              child: filteredHospitals.isEmpty
                  ? Center(
                      child: Text(
                        isHi ? 'कोई अस्पताल नहीं मिला।' : 'No hospitals found.',
                        style: const TextStyle(color: AppColors.textMedium, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: filteredHospitals.length,
                      itemBuilder: (context, index) {
                        final hosp = filteredHospitals[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HospitalProfileScreen(hospital: hosp),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: hosp['isGovt'] 
                                              ? AppColors.primary.withOpacity(0.08) 
                                              : AppColors.error.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          Icons.local_hospital_rounded,
                                          color: hosp['isGovt'] ? AppColors.primary : AppColors.error,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isHi ? hosp['nameHi']! : hosp['nameEn']!,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textDark,
                                                fontFamily: 'Poppins',
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isHi ? hosp['typeHi']! : hosp['typeEn']!,
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMedium),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    isHi ? hosp['addressHi']! : hosp['addressEn']!,
                                                    style: const TextStyle(color: AppColors.textMedium, fontSize: 12),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  const Divider(color: AppColors.border, height: 1),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.airline_seat_flat_angled, color: AppColors.primary, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isHi ? hosp['beds'].toString().replaceAll("Beds Free", "मुक्त") : hosp['beds'],
                                                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (hosp['hasIcu'])
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isHi ? "आईसीयू" : "ICU Care",
                                                style: const TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            hosp['rating'],
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterVal, String label) {
    final isSelected = _selectedFilter == filterVal;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filterVal;
          });
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
        ),
      ),
    );
  }
}

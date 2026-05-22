import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/language_toggle.dart';
import '../widgets/doctor_card.dart';
import '../data/doctors_data.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  String _searchQuery = '';
  String? _selectedSpecialty;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    final filteredDoctors = DoctorsData.doctors.where((doc) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = doc.nameEn.toLowerCase().contains(query) ||
          doc.nameHi.toLowerCase().contains(query) ||
          doc.specialtyEn.toLowerCase().contains(query) ||
          doc.specialtyHi.toLowerCase().contains(query);

      final matchesSpecialty = _selectedSpecialty == null ||
          doc.specialtyEn == _selectedSpecialty ||
          doc.specialtyHi == _selectedSpecialty;

      return matchesSearch && matchesSpecialty;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.primary),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: Text(
          lang.t('doctors'),
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Poppins'),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black.withOpacity(0.04), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: lang.t('search_hint'),
                      hintStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.primary, size: 22),
                      fillColor: AppColors.background,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip(lang.isHindi ? 'सभी' : 'All', null),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            lang.isHindi ? 'सामान्य चिकित्सक' : 'Physician',
                            lang.isHindi ? 'सामान्य चिकित्सक' : 'Physician'),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            lang.isHindi ? 'हृदय रोग' : 'Cardiologist',
                            lang.isHindi ? 'हृदय रोग' : 'Cardiologist'),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            lang.isHindi ? 'स्त्री रोग' : 'Gynecologist',
                            lang.isHindi ? 'स्त्री रोग' : 'Gynecologist'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredDoctors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: AppColors.lightBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.search_off_rounded,
                                size: 48,
                                color: AppColors.primary.withOpacity(0.5)),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            lang.isHindi
                                ? 'कोई डॉक्टर नहीं मिला'
                                : 'No doctors found',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        return DoctorCard(doctor: filteredDoctors[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedSpecialty == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSpecialty = isSelected ? null : value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }
}

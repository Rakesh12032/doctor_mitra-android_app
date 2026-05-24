import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';

class HealthVaultScreen extends StatefulWidget {
  const HealthVaultScreen({super.key});

  @override
  State<HealthVaultScreen> createState() => _HealthVaultScreenState();
}

class _HealthVaultScreenState extends State<HealthVaultScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isAbhaLinked = true;
  final String _abhaId = "14-2394-0982-1249";

  final List<Map<String, String>> _categories = [
    {'id': 'All', 'nameEn': 'All Records', 'nameHi': 'सभी रिकॉर्ड', 'icon': '📂'},
    {'id': 'Lab', 'nameEn': 'Lab Reports', 'nameHi': 'लैब रिपोर्ट', 'icon': '🔬'},
    {'id': 'Rx', 'nameEn': 'Prescriptions', 'nameHi': 'पर्चे (Rx)', 'icon': '📝'},
    {'id': 'Radiology', 'nameEn': 'Radiology / X-Ray', 'nameHi': 'एक्स-रे / स्कैन', 'icon': '🩻'},
    {'id': 'Vaccine', 'nameEn': 'Vaccination', 'nameHi': 'टीकाकरण', 'icon': '💉'},
  ];

  final List<Map<String, dynamic>> _mockRecords = [
    {
      'id': 'rec-1',
      'title': 'Complete Blood Count (CBC)',
      'titleHi': 'कम्पलीट ब्लड काउंट (CBC)',
      'category': 'Lab',
      'date': '20 May 2026',
      'doctor': 'Dr. Alok Kumar Jha',
      'doctorHi': 'डॉ. आलोक कुमार झा',
      'fileSize': '1.2 MB',
      'isShared': true,
    },
    {
      'id': 'rec-2',
      'title': 'General Wellness Prescription',
      'titleHi': 'सामान्य स्वास्थ्य पर्चा',
      'category': 'Rx',
      'date': '12 May 2026',
      'doctor': 'Dr. R. K. Singh',
      'doctorHi': 'डॉ. आर. के. सिंह',
      'fileSize': '850 KB',
      'isShared': false,
    },
    {
      'id': 'rec-3',
      'title': 'Chest X-Ray Digital Copy',
      'titleHi': 'छाती का एक्स-रे',
      'category': 'Radiology',
      'date': '02 Apr 2026',
      'doctor': 'AIIMS Patna Radiology',
      'doctorHi': 'एम्स पटना रेडियोलॉजी',
      'fileSize': '4.5 MB',
      'isShared': true,
    },
    {
      'id': 'rec-4',
      'title': 'COVID Booster Certificate',
      'titleHi': 'कोविड बूस्टर प्रमाणपत्र',
      'category': 'Vaccine',
      'date': '15 Dec 2025',
      'doctor': 'Sadar Hospital Saharsa',
      'doctorHi': 'सदर अस्पताल सहरसा',
      'fileSize': '620 KB',
      'isShared': false,
    },
  ];

  void _addNewRecord(Map<String, dynamic> record) {
    setState(() {
      _mockRecords.insert(0, record);
    });
  }

  void _showAddRecordSheet(BuildContext context, LanguageProvider lang) {
    final titleController = TextEditingController();
    final doctorController = TextEditingController();
    String selectedCat = 'Lab';
    String? selectedFilePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              decoration: const BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
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
                    const SizedBox(height: 24),
                    Text(
                      lang.isHindi ? 'नया मेडिकल रिकॉर्ड जोड़ें' : 'Add Medical Record',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Upload Picker Options
                    Row(
                      children: [
                        Expanded(
                          child: _buildUploadOption(
                            icon: Icons.camera_alt_outlined,
                            label: lang.isHindi ? 'कैमरा फोटो' : 'Camera Photo',
                            onTap: () {
                              setModalState(() {
                                selectedFilePath = "IMG_20260522_HEALTH.jpg";
                              });
                            },
                            isSelected: selectedFilePath?.startsWith("IMG") ?? false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildUploadOption(
                            icon: Icons.picture_as_pdf_outlined,
                            label: lang.isHindi ? 'PDF दस्तावेज' : 'PDF Document',
                            onTap: () {
                              setModalState(() {
                                selectedFilePath = "LAB_REPORT_SAHARSA.pdf";
                              });
                            },
                            isSelected: selectedFilePath?.endsWith("pdf") ?? false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (selectedFilePath != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedFilePath!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      decoration: InputDecoration(
                        labelText: lang.isHindi ? 'रिकॉर्ड का नाम (उदा. ब्लड रिपोर्ट)' : 'Record Title (e.g. Blood Report)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: doctorController,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      decoration: InputDecoration(
                        labelText: lang.isHindi ? 'डॉक्टर / लैब का नाम' : 'Doctor / Lab Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown for Category
                    DropdownButtonFormField<String>(
                      value: selectedCat,
                      decoration: InputDecoration(
                        labelText: lang.isHindi ? 'श्रेणी' : 'Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: _categories
                          .where((c) => c['id'] != 'All')
                          .map((c) => DropdownMenuItem(
                                value: c['id'],
                                child: Text(lang.isHindi ? c['nameHi']! : c['nameEn']!),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          selectedCat = val;
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: lang.isHindi ? 'रिकॉर्ड सेव करें' : 'Save Record',
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        final newRec = {
                          'id': 'rec-${DateTime.now().millisecondsSinceEpoch}',
                          'title': titleController.text.trim(),
                          'titleHi': titleController.text.trim(),
                          'category': selectedCat,
                          'date': '22 May 2026',
                          'doctor': doctorController.text.trim().isEmpty 
                              ? 'Self Uploaded' 
                              : doctorController.text.trim(),
                          'doctorHi': doctorController.text.trim().isEmpty 
                              ? 'स्वयं अपलोड किया गया' 
                              : doctorController.text.trim(),
                          'fileSize': '1.5 MB',
                          'isShared': false,
                        };
                        _addNewRecord(newRec);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang.isHindi 
                                ? 'रिकॉर्ड सफलतापूर्वक अपलोड हो गया!' 
                                : 'Record uploaded successfully!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: isSelected ? AppColors.primary : AppColors.textMedium),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.textMedium,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final filteredRecords = _mockRecords.where((rec) {
      final matchesSearch = rec['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rec['titleHi'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rec['doctor'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || rec['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isHi ? 'डिजिटल हेल्थ वॉल्ट' : 'Digital Health Vault'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordSheet(context, lang),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildVitalsCard(isHi),
              const SizedBox(height: 20),
              _buildAbhaSection(isHi),
              const SizedBox(height: 20),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      hintText: isHi ? 'दस्तावेज या डॉक्टर खोजें...' : 'Search reports or doctors...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Category Tags Strip
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat['id'] == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          "${cat['icon']} ${isHi ? cat['nameHi']! : cat['nameEn']!}",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : AppColors.textDark,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = cat['id']!;
                          });
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.cardBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              SectionHeader(
                title: isHi ? 'आपके दस्तावेज' : 'Your Documents',
                actionLabel: isHi ? 'सॉर्ट करें 📅' : 'Sort Date 📅',
              ),
              const SizedBox(height: 12),
              
              filteredRecords.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: EmptyState(
                        icon: Icons.folder_open,
                        title: isHi ? 'कोई रिकॉर्ड नहीं मिला' : 'No Records Found',
                        subtitle: isHi 
                            ? 'आपके सर्च के अनुसार कोई दस्तावेज नहीं है।' 
                            : 'Upload a report by clicking the + button below.',
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final rec = filteredRecords[index];
                        return _buildRecordCard(rec, isHi);
                      },
                    ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalsCard(bool isHi) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  isHi ? 'स्वास्थ्य वाइटल्स' : 'Health Vitals',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textDark,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildVitalItem('BP', '120/80', 'mmHg', isHi),
                _buildVitalItem('SpO2', '98%', 'Oxygen', isHi),
                _buildVitalItem(isHi ? 'वजन' : 'Weight', '72', 'Kg', isHi),
                _buildVitalItem(isHi ? 'शर्करा' : 'Sugar', '96', 'mg/dL', isHi),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVitalItem(String label, String val, String unit, bool isHi) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Poppins')),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark, fontFamily: 'Poppins')),
        Text(unit, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontFamily: 'Poppins')),
      ],
    );
  }

  Widget _buildAbhaSection(bool isHi) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "ABHA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.white, size: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isAbhaLinked) ...[
                    const Text(
                      "Linked ABHA ID",
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _abhaId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ] else ...[
                    Text(
                      isHi 
                          ? 'आयुष्मान भारत हेल्थ अकाउंट (ABHA) को जोड़ें'
                          : 'Link Ayushman Bharat Health Account',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isAbhaLinked = !_isAbhaLinked;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                _isAbhaLinked 
                    ? (isHi ? 'अनलिंक' : 'Unlink') 
                    : (isHi ? 'लिंक करें' : 'Link'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> rec, bool isHi) {
    IconData fileIcon;
    Color iconColor;
    switch (rec['category']) {
      case 'Lab':
        fileIcon = Icons.science_outlined;
        iconColor = Colors.purple;
        break;
      case 'Rx':
        fileIcon = Icons.receipt_long_outlined;
        iconColor = Colors.orange;
        break;
      case 'Radiology':
        fileIcon = Icons.camera_outlined;
        iconColor = Colors.teal;
        break;
      default:
        fileIcon = Icons.vaccines_outlined;
        iconColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(fileIcon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHi ? rec['titleHi']! : rec['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isHi ? "द्वारा: ${rec['doctorHi']}" : "By: ${rec['doctor']}",
                      style: const TextStyle(fontSize: 12, color: AppColors.textMedium, fontFamily: 'Poppins'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${rec['date']} • ${rec['fileSize']}",
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Share with doctor toggle
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: rec['isShared'] as bool,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          rec['isShared'] = val;
                        });
                      },
                    ),
                  ),
                  Text(
                    isHi ? 'डॉक्टर से साझा' : 'Share with Doctor',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMedium, fontFamily: 'Poppins'),
                  ),
                ],
              ),
              // Download Button icon
              IconButton(
                icon: const Icon(Icons.download_for_offline_outlined, color: AppColors.primary, size: 24),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isHi 
                          ? 'फ़ाइल डाउनलोड हो रही है...' 
                          : 'Downloading file offline...'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

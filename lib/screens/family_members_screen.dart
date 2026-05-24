import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final List<Map<String, dynamic>> _mockFamily = [
    {
      'id': 'f-1',
      'name': 'Kiran Devi',
      'relationEn': 'Spouse',
      'relationHi': 'पत्नी',
      'age': 30,
      'genderEn': 'Female',
      'genderHi': 'महिला',
    },
    {
      'id': 'f-2',
      'name': 'Aarav Kumar',
      'relationEn': 'Son',
      'relationHi': 'बेटा',
      'age': 8,
      'genderEn': 'Male',
      'genderHi': 'पुरुष',
    },
    {
      'id': 'f-3',
      'name': 'Ram Chandra Prasad',
      'relationEn': 'Father',
      'relationHi': 'पिता',
      'age': 65,
      'genderEn': 'Male',
      'genderHi': 'पुरुष',
    },
  ];

  void _addFamilyMember(Map<String, dynamic> member) {
    setState(() {
      _mockFamily.add(member);
    });
  }

  void _deleteFamilyMember(String id) {
    setState(() {
      _mockFamily.removeWhere((item) => item['id'] == id);
    });
  }

  void _showAddMemberSheet(BuildContext context, LanguageProvider lang) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String selectedRelation = 'Spouse';
    String selectedGender = 'Male';

    final List<Map<String, String>> relations = [
      {'id': 'Spouse', 'nameEn': 'Spouse', 'nameHi': 'पत्नी/पति'},
      {'id': 'Son', 'nameEn': 'Son', 'nameHi': 'बेटा'},
      {'id': 'Daughter', 'nameEn': 'Daughter', 'nameHi': 'बेटी'},
      {'id': 'Father', 'nameEn': 'Father', 'nameHi': 'पिता'},
      {'id': 'Mother', 'nameEn': 'Mother', 'nameHi': 'माता'},
    ];

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
                      lang.isHindi ? 'परिवार के सदस्य को जोड़ें' : 'Add Family Member',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      decoration: InputDecoration(
                        labelText: lang.isHindi ? 'पूरा नाम' : 'Full Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      decoration: InputDecoration(
                        labelText: lang.isHindi ? 'उम्र (वर्षों में)' : 'Age (in Years)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRelation,
                      decoration: InputDecoration(
                        labelText: lang.isHindi ? 'संबंध' : 'Relationship',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: relations
                          .map((r) => DropdownMenuItem(
                                value: r['id'],
                                child: Text(lang.isHindi ? r['nameHi']! : r['nameEn']!),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedRelation = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lang.isHindi ? 'लिंग (Gender):' : 'Gender:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(lang.isHindi ? 'पुरुष' : 'Male', style: const TextStyle(fontSize: 13)),
                            value: 'Male',
                            groupValue: selectedGender,
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  selectedGender = val;
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(lang.isHindi ? 'महिला' : 'Female', style: const TextStyle(fontSize: 13)),
                            value: 'Female',
                            groupValue: selectedGender,
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  selectedGender = val;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: lang.isHindi ? 'सदस्य सेव करें' : 'Save Member',
                      onPressed: () {
                        if (nameController.text.trim().isEmpty || ageController.text.trim().isEmpty) return;
                        final newMember = {
                          'id': 'f-${DateTime.now().millisecondsSinceEpoch}',
                          'name': nameController.text.trim(),
                          'relationEn': selectedRelation,
                          'relationHi': relations.firstWhere((r) => r['id'] == selectedRelation)[lang.isHindi ? 'nameHi' : 'nameEn'],
                          'age': int.tryParse(ageController.text.trim()) ?? 30,
                          'genderEn': selectedGender,
                          'genderHi': selectedGender == 'Male' ? 'पुरुष' : 'महिला',
                        };
                        _addFamilyMember(newMember);
                        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isHi ? 'परिवार के सदस्य' : 'Family Members'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemberSheet(context, lang),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: _mockFamily.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  icon: Icons.people_outline,
                  title: isHi ? 'कोई सदस्य नहीं है' : 'No Family Members',
                  subtitle: isHi 
                      ? 'अपने परिवार के सदस्यों को यहाँ जोड़ें ताकि आप उनके लिए भी बुकिंग कर सकें।' 
                      : 'Add your loved ones here to quickly book doctor slots for them.',
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _mockFamily.length,
                itemBuilder: (context, index) {
                  final member = _mockFamily[index];
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            member['genderEn'] == 'Male' ? Icons.face : Icons.face_3,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark, fontFamily: 'Poppins'),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isHi ? member['relationHi'] : member['relationEn'],
                                      style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${member['age']} ${isHi ? 'वर्ष' : 'Yrs'} • ${isHi ? member['genderHi'] : member['genderEn']}",
                                    style: const TextStyle(color: AppColors.textMedium, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => _deleteFamilyMember(member['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

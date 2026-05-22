import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/booking_model.dart';
import '../models/doctor_model.dart';
import '../providers/booking_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';
import 'booking_confirm_screen.dart';

class BookingScreen extends StatefulWidget {
  final Doctor doctor;

  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _symptomsController = TextEditingController();
  String? _selectedSlot;
  int _currentStep = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _symptomsController.dispose();
    super.dispose();
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
        title: Text(lang.t('book_appointment')),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(lang),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDoctorSummary(isHi),
                    const SizedBox(height: 32),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                                    begin: const Offset(0.05, 0),
                                    end: Offset.zero)
                                .animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _currentStep == 1
                          ? _buildTimeSelection(lang)
                          : _buildPatientDetailsForm(lang),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildStickyButton(isHi, lang),
    );
  }

  Widget _buildStickyButton(bool isHi, LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: AppButton(
          text: _currentStep == 1
              ? (isHi ? 'आगे बढ़ें' : 'Next Step')
              : lang.t('confirm_booking'),
          onPressed: () {
            if (_currentStep == 1) {
              if (_selectedSlot == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(isHi
                          ? 'कृपया एक स्लॉट चुनें'
                          : 'Please select a slot'),
                      backgroundColor: AppColors.error),
                );
                return;
              }
              setState(() => _currentStep = 2);
            } else {
              _confirmBooking(lang);
            }
          },
        ),
      ),
    );
  }

  Widget _buildStepIndicator(LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      color: Colors.transparent,
      child: Row(
        children: [
          _buildStepCircle(
              '1', _currentStep >= 1, lang.isHindi ? 'समय' : 'Time'),
          Expanded(
              child: Container(
                  height: 3,
                  color: _currentStep >= 2
                      ? AppColors.primary
                      : AppColors.border.withOpacity(0.5))),
          _buildStepCircle(
              '2', _currentStep >= 2, lang.isHindi ? 'विवरण' : 'Details'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(String step, bool isActive, String label) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.cardBg,
            shape: BoxShape.circle,
            border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: 2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1)
                  ]
                : [],
          ),
          child: Center(
            child: isActive && step == '1' && _currentStep == 2
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    step,
                    style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.textDark : AppColors.textMuted,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorSummary(bool isHi) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: widget.doctor.specialtyColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: widget.doctor.specialtyColor.withOpacity(0.2),
                  width: 2),
            ),
            child: Icon(Icons.person,
                color: widget.doctor.specialtyColor, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHi ? widget.doctor.nameHi : widget.doctor.nameEn,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  isHi ? widget.doctor.specialtyHi : widget.doctor.specialtyEn,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.payment,
                          size: 16, color: AppColors.textDark),
                      const SizedBox(width: 8),
                      Text(
                        '₹${widget.doctor.fee}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelection(LanguageProvider lang) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: lang.t('select_slot')),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.doctor.slots.map((slot) {
            final isSelected = _selectedSlot == slot;
            return ChoiceChip(
              label: Container(
                width: 80,
                alignment: Alignment.center,
                child: Text(slot),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedSlot = selected ? slot : null);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.cardBg,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPatientDetailsForm(LanguageProvider lang) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey(2),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep = 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              SectionHeader(title: lang.t('patient_name')),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: lang.t('patient_name'),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return lang.t('required_field');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: lang.t('phone_number'),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              final phone = value?.replaceAll(RegExp(r'\D'), '') ?? '';
              if (phone.length != 10) return lang.t('invalid_phone');
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _symptomsController,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: lang.t('optional_symptoms'),
              prefixIcon: const Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking(LanguageProvider lang) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final now = DateTime.now();
    final booking = Booking(
      id: const Uuid().v4(),
      doctorId: widget.doctor.id,
      doctorNameEn: widget.doctor.nameEn,
      doctorNameHi: widget.doctor.nameHi,
      specialtyEn: widget.doctor.specialtyEn,
      specialtyHi: widget.doctor.specialtyHi,
      patientName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.replaceAll(RegExp(r'\D'), ''),
      symptoms: _symptomsController.text.trim(),
      date: DateFormat('dd MMM yyyy').format(now),
      time: _selectedSlot!,
      status: 'upcoming',
      fee: widget.doctor.fee,
      createdAt: now.toIso8601String(),
    );

    final bookingProvider = context.read<BookingProvider>();
    await bookingProvider.addBooking(booking);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BookingConfirmScreen(
          booking: booking,
          doctor: widget.doctor,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

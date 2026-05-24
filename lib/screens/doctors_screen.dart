import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/language_toggle.dart';
import '../widgets/doctor_card.dart';
import '../data/doctors_data.dart';
import '../models/doctor_model.dart';
import 'doctor_profile_screen.dart';
import 'booking_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  String _searchQuery = '';
  String? _selectedSpecialty;
  bool _showMapView = false;
  GoogleMapController? _mapController;
  Doctor? _selectedDoctorForMap;

  // Bihar/UP clinic coordinates mapping
  LatLng _getDoctorLatLng(Doctor doc) {
    switch (doc.id) {
      case 'dm-d-001': return const LatLng(25.6100, 85.1310); // Boring Road, Patna
      case 'dm-d-002': return const LatLng(25.5920, 85.1670); // Kankarbagh, Patna
      case 'dm-d-003': return const LatLng(25.5980, 85.1600); // Rajendra Nagar, Patna
      case 'dm-d-004': return const LatLng(25.2425, 86.9842); // Bhagalpur
      case 'dm-d-005': return const LatLng(25.5910, 85.1680); // Neuro Kankarbagh, Patna
      case 'dm-d-006': return const LatLng(25.6120, 85.1300); // Skin Boring Road, Patna
      case 'dm-d-007': return const LatLng(26.1200, 85.3900); // Muzaffarpur
      case 'dm-d-008': return const LatLng(25.6040, 85.1440); // Bailey Road, Patna
      case 'dm-d-009': return const LatLng(25.5930, 85.1650); // Dental Kankarbagh, Patna
      case 'dm-d-010': return const LatLng(25.2450, 86.9850); // Bhagalpur Eye
      case 'dm-d-011': return const LatLng(26.1250, 85.3950); // Muzaffarpur ENT
      case 'dm-d-012': return const LatLng(25.5950, 85.1500); // Mind Patna
      case 'dm-d-013': return const LatLng(26.1522, 85.9020); // Darbhanga
      case 'dm-d-014': return const LatLng(25.8800, 86.6000); // Saharsa Heart
      case 'dm-d-015': return const LatLng(25.8820, 86.6050); // Saharsa Gen
      default:
        return const LatLng(25.6110, 85.1310); // Patna Center
    }
  }

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

    // Map coordinates to Marker objects
    final Set<Marker> markers = filteredDoctors.map((doc) {
      final pos = _getDoctorLatLng(doc);
      return Marker(
        markerId: MarkerId(doc.id),
        position: pos,
        infoWindow: InfoWindow(
          title: lang.isHindi ? doc.nameHi : doc.nameEn,
          snippet: lang.isHindi ? doc.specialtyHi : doc.specialtyEn,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () {
          setState(() {
            _selectedDoctorForMap = doc;
          });
        },
      );
    }).toSet();

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
              fontWeight: FontWeight.w700, fontSize: 20, fontFamily: 'Nunito'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showMapView ? Icons.list_rounded : Icons.map_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _showMapView = !_showMapView;
                _selectedDoctorForMap = null;
              });
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
            // Search and Filters
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: AppColors.premiumShadow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _selectedDoctorForMap = null;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: lang.t('search_hint'),
                      hintStyle: const TextStyle(
                          fontFamily: 'Nunito',
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
            
            // Toggle Display between List and Map
            Expanded(
              child: _showMapView
                  ? Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(25.6110, 85.1310), // Center in Patna
                            zoom: 12.0,
                          ),
                          markers: markers,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          onTap: (_) {
                            setState(() {
                              _selectedDoctorForMap = null;
                            });
                          },
                        ),
                        if (_selectedDoctorForMap != null)
                          _buildSelectedDoctorCard(_selectedDoctorForMap!, lang),
                      ],
                    )
                  : (filteredDoctors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.search_off_rounded,
                                    size: 48,
                                    color: AppColors.primary.withOpacity(0.7)),
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
                                    fontFamily: 'Nunito'),
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
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDoctorCard(Doctor doc, LanguageProvider lang) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.premiumShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.isHindi ? doc.nameHi : doc.nameEn,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textDark,
                            fontFamily: 'Nunito'),
                      ),
                      Text(
                        lang.isHindi ? doc.specialtyHi : doc.specialtyEn,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Nunito'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${doc.experience} ${lang.isHindi ? 'वर्ष का अनुभव' : 'yrs experience'}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontFamily: 'Nunito'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${lang.isHindi ? 'परामर्श शुल्क' : 'Fee'}: ₹${doc.fee.round()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      fontFamily: 'Nunito'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorProfileScreen(doctor: doc),
                          ),
                        );
                      },
                      child: Text(
                        lang.isHindi ? 'प्रोफ़ाइल' : 'Profile',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Nunito'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(doctor: doc),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      child: Text(
                        lang.isHindi ? 'बुक करें' : 'Book',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito'),
                      ),
                    ),
                  ],
                ),
              ],
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
          _selectedDoctorForMap = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primaryLight,
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
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.cardBg,
          elevation: 0,
          title: Text(lang.t('my_bookings')),
          actions: const [
            Padding(
                padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                tabs: [
                  Tab(text: lang.t('upcoming')),
                  Tab(text: lang.t('past')),
                  Tab(text: lang.t('cancelled')),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(context, lang, bookingProvider.upcomingBookings),
            _buildBookingList(context, lang, bookingProvider.pastBookings),
            _buildBookingList(context, lang, bookingProvider.cancelledBookings),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    LanguageProvider lang,
    List<Booking> bookings,
  ) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: lang.isHindi ? 'कोई बुकिंग नहीं मिली' : 'No bookings found',
        subtitle: lang.isHindi
            ? 'आपकी अभी तक कोई बुकिंग नहीं है।'
            : 'You have no bookings at the moment.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final doctorName =
            lang.isHindi ? booking.doctorNameHi : booking.doctorNameEn;
        final specialty =
            lang.isHindi ? booking.specialtyHi : booking.specialtyEn;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.lightBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.person_outline,
                            color: AppColors.primary, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  doctorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              _buildStatusChip(context, lang, booking.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            specialty,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoLine(Icons.person_outline,
                          lang.t('patient_name'), booking.patientName),
                      const SizedBox(height: 10),
                      _buildInfoLine(Icons.schedule, lang.t('select_slot'),
                          '${booking.date}, ${booking.time}'),
                      const SizedBox(height: 10),
                      _buildInfoLine(Icons.account_balance_wallet_outlined,
                          lang.t('fee'), '₹${booking.fee.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
                if (booking.status == 'upcoming') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context
                            .read<BookingProvider>()
                            .cancelBooking(booking.id);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(
                            color: AppColors.error, width: 1.2),
                        minimumSize: const Size(0, 42),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        lang.t('cancel'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(
      BuildContext context, LanguageProvider lang, String status) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'pending':
        color = const Color(0xFFE65100);
        bgColor = const Color(0xFFFFF3E0);
        break;
      case 'accepted':
      case 'upcoming':
        color = const Color(0xFF1565C0);
        bgColor = const Color(0xFFE3F2FD);
        break;
      case 'completed':
      case 'past':
        color = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 'cancelled':
        color = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
        break;
      default:
        color = AppColors.textMuted;
        bgColor = AppColors.lightBackground;
    }

    final label = lang.t(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildInfoLine(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

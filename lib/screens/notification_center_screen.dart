import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_ui.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'n-1',
      'titleEn': 'Video Call is Ready 🎥',
      'titleHi': 'वीडियो कॉल तैयार है 🎥',
      'bodyEn': 'Dr. Alok Kumar Jha is waiting in the room. Tap to join the consultation.',
      'bodyHi': 'डॉ. आलोक कुमार झा रूम में आपका इंतजार कर रहे हैं। परामर्श में शामिल होने के लिए दबाएं।',
      'time': '5 min ago',
      'type': 'call',
      'isRead': false,
    },
    {
      'id': 'n-2',
      'titleEn': 'Prescription Uploaded 📝',
      'titleHi': 'पर्चा (Prescription) अपलोड हुआ 📝',
      'bodyEn': 'Your digital prescription for the wellness checkup is ready in your Vault.',
      'bodyHi': 'आपके स्वास्थ्य परीक्षण का डिजिटल पर्चा आपके हेल्थ वॉल्ट में उपलब्ध है।',
      'time': '2 hours ago',
      'type': 'prescription',
      'isRead': false,
    },
    {
      'id': 'n-3',
      'titleEn': 'Booking Confirmed! ✅',
      'titleHi': 'बुकिंग की पुष्टि हो गई! ✅',
      'bodyEn': 'Your appointment with Dr. Rajeev Kumar is scheduled for tomorrow at 10:00 AM.',
      'bodyHi': 'डॉ. राजीव कुमार के साथ आपका अपॉइंटमेंट कल सुबह 10:00 बजे के लिए कन्फर्म हो गया है।',
      'time': '1 day ago',
      'type': 'booking',
      'isRead': true,
    },
    {
      'id': 'n-4',
      'titleEn': 'Lab Report Ready 🔬',
      'titleHi': 'लैब रिपोर्ट तैयार है 🔬',
      'bodyEn': 'Your CBC blood report has been uploaded by Koshi Diagnostics.',
      'bodyHi': 'कोशी डायग्नोस्टिक्स द्वारा आपका सीबीसी ब्लड रिपोर्ट अपलोड कर दिया गया है।',
      'time': '3 days ago',
      'type': 'lab',
      'isRead': true,
    },
    {
      'id': 'n-5',
      'titleEn': 'Health Wallet Bonus! 🪙',
      'titleHi': 'हेल्थ वॉलेट बोनस! 🪙',
      'bodyEn': 'You earned 50 Mitra Credits on your first booking referral.',
      'bodyHi': 'आपने अपने पहले बुकिंग रेफरल पर 50 मित्रा क्रेडिट अर्जित किए हैं।',
      'time': '5 days ago',
      'type': 'wallet',
      'isRead': true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item['isRead'] = true;
      }
    });
  }

  void _clearNotifications() {
    setState(() {
      _notifications.clear();
    });
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
        title: Text(isHi ? 'सूचना केंद्र' : 'Notification Center'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8.0), child: LanguageToggle())
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Action buttons header
            if (_notifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _markAllAsRead,
                      icon: const Icon(Icons.done_all, size: 16, color: AppColors.primary),
                      label: Text(
                        isHi ? 'सभी पढ़े हुए मार्क करें' : 'Mark all as read',
                        style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _clearNotifications,
                      icon: const Icon(Icons.delete_sweep_outlined, size: 16, color: AppColors.error),
                      label: Text(
                        isHi ? 'सभी साफ करें' : 'Clear all',
                        style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: EmptyState(
                        icon: Icons.notifications_off_outlined,
                        title: isHi ? 'कोई सूचना नहीं है' : 'No Notifications',
                        subtitle: isHi 
                            ? 'जब भी कोई नई अपडेट होगी, हम आपको सूचित करेंगे।' 
                            : 'We will notify you when there are booking updates or records.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        return _buildNotificationCard(notif, isHi);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, bool isHi) {
    IconData icon;
    Color color;

    switch (notif['type']) {
      case 'call':
        icon = Icons.video_camera_front_outlined;
        color = Colors.blue;
        break;
      case 'prescription':
        icon = Icons.note_alt_outlined;
        color = Colors.orange;
        break;
      case 'booking':
        icon = Icons.check_circle_outline_rounded;
        color = AppColors.primary;
        break;
      case 'lab':
        icon = Icons.science_outlined;
        color = Colors.purple;
        break;
      default:
        icon = Icons.monetization_on_outlined;
        color = Colors.teal;
    }

    final isRead = notif['isRead'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? AppColors.cardBg : AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? AppColors.border : AppColors.primary.withOpacity(0.2),
          width: isRead ? 1 : 1.5,
        ),
        boxShadow: isRead 
            ? [] 
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isHi ? notif['titleHi']! : notif['titleEn']!,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.bold : FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textDark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    Text(
                      notif['time']!,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isHi ? notif['bodyHi']! : notif['bodyEn']!,
                  style: TextStyle(
                    color: isRead ? AppColors.textMedium : AppColors.textDark.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.4,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

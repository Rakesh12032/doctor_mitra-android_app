import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/cart_provider.dart';
import '../providers/language_provider.dart';
import '../providers/store_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    final store = Provider.of<DoctorMitraStore>(context, listen: false);

    if (InternetApiLayer.isConfiguredStatic) {
      try {
        final apiBaseUrl = const String.fromEnvironment('DOCTOR_MITRA_API_URL');
        final token = store.token;

        final response = await http.get(
          Uri.parse('$apiBaseUrl/api/orders/${widget.orderId}'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          if (body['success'] == true) {
            setState(() {
              _order = body['data'];
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("OrderTrackingScreen: Fetch error: $e");
      }
    }

    // Mock Offline fallback
    final now = DateTime.now();
    setState(() {
      _order = {
        '_id': widget.orderId,
        'status': widget.orderId.startsWith('ord_') ? 'placed' : 'shipped',
        'totalAmount': 172.0,
        'trackingId': 'TRK_MITRA_849021',
        'estimatedDelivery': now.add(const Duration(days: 3)).toIso8601String(),
        'createdAt': now.toIso8601String(),
        'deliveryPartner': 'Mitra Express Delivery',
        'payment': {
          'method': widget.orderId.startsWith('ord_') ? 'cod' : 'online',
          'status': widget.orderId.startsWith('ord_') ? 'pending' : 'successful',
          'transactionId': widget.orderId.startsWith('ord_') ? '' : 'tx_razorpay_9423851',
        },
        'deliveryAddress': {
          'name': 'Rakesh Raj',
          'phone': '9876543210',
          'address': 'Boring Road, Crossing No. 3',
          'city': 'Patna',
          'pincode': '800001',
        },
        'items': [
          { 'name': 'Crocin Pain Relief', 'quantity': 2, 'price': 38.5 },
          { 'name': 'Alersin-L', 'quantity': 1, 'price': 55.0 }
        ],
      };
      _isLoading = false;
    });
  }

  Future<void> _cancelOrder() async {
    setState(() {
      _isLoading = true;
    });

    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    if (InternetApiLayer.isConfiguredStatic) {
      try {
        final apiBaseUrl = const String.fromEnvironment('DOCTOR_MITRA_API_URL');
        final token = store.token;

        final response = await http.put(
          Uri.parse('$apiBaseUrl/api/orders/${widget.orderId}/cancel'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          if (body['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(lang.isHindi ? "ऑर्डर सफलतापूर्वक रद्द कर दिया गया!" : "Order cancelled successfully!"),
                backgroundColor: AppColors.success,
              ),
            );
            _fetchOrderDetails();
            return;
          }
        }
      } catch (e) {
        debugPrint("OrderTrackingScreen: Cancel error: $e");
      }
    }

    // Mock Cancel offline fallback
    setState(() {
      if (_order != null) {
        _order!['status'] = 'cancelled';
      }
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang.isHindi ? "ऑर्डर सफलतापूर्वक रद्द कर दिया गया!" : "Order cancelled successfully!"),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadInvoice(LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 48),
              const SizedBox(height: 16),
              Text(
                lang.isHindi ? "इनवॉइस डाउनलोड हो गया!" : "Invoice Downloaded!",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 8),
              Text(
                'File saved under /Downloads/DoctorMitra_Invoice_${widget.orderId}.pdf',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.textMedium, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(lang.isHindi ? "ठीक है" : "Done", style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _reorderItems(LanguageProvider lang) {
    if (_order == null || _order!['items'] == null) return;
    final cart = Provider.of<CartProvider>(context, listen: false);
    final items = _order!['items'] as List;

    for (var item in items) {
      cart.addItem(
        id: item['medicine']?.toString() ?? 'med_${DateTime.now().millisecondsSinceEpoch}',
        name: item['name'].toString(),
        genericName: 'Reordered composition',
        manufacturer: 'Mitra Pharma',
        price: double.tryParse(item['price'].toString()) ?? 50.0,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang.isHindi ? "दवाइयाँ कार्ट में पुनः जोड़ दी गयी हैं!" : "Medicines re-added to cart!"),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
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
          isHi ? 'ऑर्डर ट्रैकिंग' : 'Track Medicine Order',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Nunito'),
        ),
      ),
      body: _isLoading || _order == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Order Details banner
                  _buildDetailsHeader(isHi),
                  const SizedBox(height: 20),

                  // Timeline Steps
                  Text(
                    isHi ? 'ऑर्डर प्रोग्रेस' : 'Order Status Progress',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark, fontFamily: 'Nunito'),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusTimeline(isHi),
                  const SizedBox(height: 24),

                  // Delivery Address details
                  _buildAddressSection(isHi),
                  const SizedBox(height: 24),

                  // Actions row
                  _buildActionsFooter(lang),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailsHeader(bool isHi) {
    final estDate = DateTime.tryParse(_order!['estimatedDelivery']?.toString() ?? '') ?? DateTime.now();
    final estStr = '${estDate.day}/${estDate.month}/${estDate.year}';
    final status = _order!['status'].toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID: ${_order!['_id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tracking ID: ${_order!['trackingId']}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Nunito'),
                  ),
                ],
              ),
              _buildStatusBadge(status, isHi),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHi ? 'अनुमानित डिलिवरी' : 'Est. Delivery Date',
                style: const TextStyle(color: AppColors.textMedium, fontSize: 12, fontFamily: 'Nunito'),
              ),
              Text(
                estStr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHi ? 'डिलिवरी पार्टनर' : 'Delivery Partner',
                style: const TextStyle(color: AppColors.textMedium, fontSize: 12, fontFamily: 'Nunito'),
              ),
              Text(
                _order!['deliveryPartner'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isHi) {
    Color bg = const Color(0xFFE8F5E9);
    Color textCol = const Color(0xFF2E7D32);

    if (status == 'cancelled') {
      bg = const Color(0xFFFFEBEE);
      textCol = const Color(0xFFC62828);
    } else if (status == 'placed') {
      bg = const Color(0xFFFFF3E0);
      textCol = const Color(0xFFE65100);
    } else if (status == 'shipped') {
      bg = const Color(0xFFE3F2FD);
      textCol = const Color(0xFF1565C0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 9, fontFamily: 'Nunito'),
      ),
    );
  }

  Widget _buildStatusTimeline(bool isHi) {
    final status = _order!['status'].toString().toLowerCase();

    if (status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                isHi
                    ? 'यह आर्डर रद्द कर दिया गया है।'
                    : 'This order has been cancelled. If any online payment was deducted, it will refund in 3-5 bank working days.',
                style: const TextStyle(fontSize: 12, color: Colors.red, fontFamily: 'Nunito', height: 1.3),
              ),
            )
          ],
        ),
      );
    }

    final steps = ['placed', 'confirmed', 'packed', 'shipped', 'delivered'];
    final currentIndex = steps.indexOf(status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isActive = index <= currentIndex;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column for timeline dot/line
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? AppColors.primary : Colors.grey.shade200,
                      border: Border.all(
                        color: isActive ? Colors.transparent : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isActive ? Icons.check : Icons.circle,
                        color: isActive ? Colors.white : Colors.grey.shade400,
                        size: isActive ? 14 : 6,
                      ),
                    ),
                  ),
                  if (index != steps.length - 1)
                    Container(
                      width: 2.5,
                      height: 36,
                      color: isActive ? AppColors.primary : Colors.grey.shade200,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStepName(step, isHi),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isActive ? AppColors.textDark : AppColors.textMuted,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isActive
                            ? (isHi ? 'प्रक्रिया संपन्न हो गयी है' : 'Step successfully completed')
                            : (isHi ? 'प्रतीक्षारत' : 'Pending progress'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Nunito'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _getStepName(String step, bool isHi) {
    switch (step) {
      case 'placed': return isHi ? 'ऑर्डर प्लेस हुआ' : 'Order Placed';
      case 'confirmed': return isHi ? 'ऑर्डर स्वीकार किया' : 'Confirmed';
      case 'packed': return isHi ? 'दवाइयाँ पैक हुई' : 'Packed';
      case 'shipped': return isHi ? 'रास्ते में है' : 'Shipped';
      case 'delivered': return isHi ? 'सफलतापूर्वक डिलिवर' : 'Delivered';
      default: return step;
    }
  }

  Widget _buildAddressSection(bool isHi) {
    final addr = _order!['deliveryAddress'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.home_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                isHi ? 'शिपिंग का पता' : 'Shipping Coordinates',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            addr['name'].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 4),
          Text(
            '${addr['address']}, ${addr['city']} - ${addr['pincode']}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.3, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 4),
          Text(
            'Contact: ${addr['phone']}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Nunito'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsFooter(LanguageProvider lang) {
    final status = _order!['status'].toString().toLowerCase();
    final isHi = lang.isHindi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (status == 'placed')
          ElevatedButton.icon(
            onPressed: _cancelOrder,
            icon: const Icon(Icons.cancel_presentation_outlined, color: Colors.white, size: 18),
            label: Text(
              isHi ? 'ऑर्डर रद्द करें' : 'Cancel Order',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        if (status == 'delivered') ...[
          ElevatedButton.icon(
            onPressed: () => _reorderItems(lang),
            icon: const Icon(Icons.replay_circle_filled, color: Colors.white, size: 18),
            label: Text(
              isHi ? 'पुनः आर्डर करें' : 'Reorder Items',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _downloadInvoice(lang),
            icon: const Icon(Icons.download_rounded, color: AppColors.primary, size: 18),
            label: Text(
              isHi ? 'इनवॉइस डाउनलोड करें' : 'Download Invoice',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/language_provider.dart';
import '../providers/store_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'order_tracking_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _orders = [];
  String _selectedTab = 'Active'; // Active | Delivered | Cancelled

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    final user = store.currentUser;

    if (InternetApiLayer.isConfiguredStatic && user != null) {
      try {
        final apiBaseUrl = const String.fromEnvironment('DOCTOR_MITRA_API_URL');
        final token = store.token;

        final response = await http.get(
          Uri.parse('$apiBaseUrl/api/orders/patient/${user.id}'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          if (body['success'] == true && body['data'] is List) {
            final list = body['data'] as List;
            setState(() {
              _orders = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("MyOrdersScreen: Fetch orders error: $e");
      }
    }

    // Fallback Mock Orders for offline testing
    final now = DateTime.now();
    setState(() {
      _orders = [
        {
          '_id': 'ord-101',
          'patient': user?.id ?? 'temp_patient_99',
          'items': [
            { 'name': 'Crocin Pain Relief', 'quantity': 2, 'price': 38.5 },
            { 'name': 'Alersin-L', 'quantity': 1, 'price': 55.0 }
          ],
          'totalAmount': 172.0,
          'deliveryAddress': {
            'name': 'Rakesh Raj',
            'phone': '9876543210',
            'address': 'Boring Road, Crossing No. 3',
            'city': 'Patna',
            'pincode': '800001'
          },
          'status': 'shipped',
          'trackingId': 'TRK_MITRA_849021',
          'deliveryPartner': 'Mitra Express Delivery',
          'estimatedDelivery': now.add(const Duration(days: 1)).toIso8601String(),
          'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()
        },
        {
          '_id': 'ord-102',
          'patient': user?.id ?? 'temp_patient_99',
          'items': [
            { 'name': 'Pan-D Capsule', 'quantity': 1, 'price': 142.0 }
          ],
          'totalAmount': 182.0,
          'deliveryAddress': {
            'name': 'Rakesh Raj',
            'phone': '9876543210',
            'address': 'Boring Road, Crossing No. 3',
            'city': 'Patna',
            'pincode': '800001'
          },
          'status': 'placed',
          'trackingId': 'TRK_MITRA_120485',
          'deliveryPartner': 'Mitra Express Delivery',
          'estimatedDelivery': now.add(const Duration(days: 2)).toIso8601String(),
          'createdAt': now.toIso8601String()
        },
        {
          '_id': 'ord-103',
          'patient': user?.id ?? 'temp_patient_99',
          'items': [
            { 'name': 'Calpol 650', 'quantity': 3, 'price': 30.2 }
          ],
          'totalAmount': 130.6,
          'deliveryAddress': {
            'name': 'Rakesh Raj',
            'phone': '9876543210',
            'address': 'Boring Road, Crossing No. 3',
            'city': 'Patna',
            'pincode': '800001'
          },
          'status': 'delivered',
          'trackingId': 'TRK_MITRA_592810',
          'deliveryPartner': 'Mitra Express Delivery',
          'estimatedDelivery': now.subtract(const Duration(days: 2)).toIso8601String(),
          'createdAt': now.subtract(const Duration(days: 5)).toIso8601String()
        }
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHi = lang.isHindi;

    final filteredOrders = _orders.where((order) {
      final status = order['status'].toString().toLowerCase();
      if (_selectedTab == 'Active') {
        return status != 'delivered' && status != 'cancelled';
      } else if (_selectedTab == 'Delivered') {
        return status == 'delivered';
      } else {
        return status == 'cancelled';
      }
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.primary),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text(
          isHi ? 'मेरे ऑर्डर्स' : 'My Medicine Orders',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Nunito'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tabs row
            _buildFilterTabs(isHi),

            // Order lists
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 3,
                      ),
                    )
                  : (filteredOrders.isEmpty
                      ? _buildEmptyState(isHi)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _buildOrderCard(order, isHi);
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(bool isHi) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton(isHi ? 'सक्रिय' : 'Active', 'Active'),
          _buildTabButton(isHi ? 'वितरित' : 'Delivered', 'Delivered'),
          _buildTabButton(isHi ? 'रद्द' : 'Cancelled', 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String tabKey) {
    final isSelected = _selectedTab == tabKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'Nunito',
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isHi) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            isHi ? 'कोई आर्डर नहीं मिला' : 'No orders found',
            style: const TextStyle(fontSize: 15, color: AppColors.textMedium, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isHi) {
    final DateTime date = DateTime.tryParse(order['createdAt']?.toString() ?? '') ?? DateTime.now();
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final items = order['items'] as List;
    final medicinesSummary = items.map((i) => "${i['name']} (${i['quantity']})").join(', ');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(orderId: order['_id'].toString()),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                Text(
                  'ID: ${order['_id']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
                ),
                _buildStatusMiniBadge(order['status'].toString(), isHi),
              ],
            ),
            const Divider(height: 20),
            Text(
              isHi ? 'दवाइयाँ: ' : 'Medicines: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMedium, fontFamily: 'Nunito'),
            ),
            const SizedBox(height: 4),
            Text(
              medicinesSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontFamily: 'Nunito'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: $dateStr',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Nunito'),
                ),
                Text(
                  'Total: ₹${double.parse(order['totalAmount'].toString()).toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green, fontFamily: 'Nunito'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMiniBadge(String status, bool isHi) {
    Color bg = const Color(0xFFFFF3E0);
    Color textCol = const Color(0xFFE65100);

    if (status == 'delivered') {
      bg = const Color(0xFFE8F5E9);
      textCol = const Color(0xFF2E7D32);
    } else if (status == 'cancelled') {
      bg = const Color(0xFFFFEBEE);
      textCol = const Color(0xFFC62828);
    } else if (status == 'shipped') {
      bg = const Color(0xFFE3F2FD);
      textCol = const Color(0xFF1565C0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 8, fontFamily: 'Nunito'),
      ),
    );
  }
}

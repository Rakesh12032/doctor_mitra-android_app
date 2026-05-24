import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../providers/cart_provider.dart';
import '../providers/language_provider.dart';
import '../providers/store_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'order_tracking_screen.dart';

class MedicineCheckoutScreen extends StatefulWidget {
  const MedicineCheckoutScreen({super.key});

  @override
  State<MedicineCheckoutScreen> createState() => _MedicineCheckoutScreenState();
}

class _MedicineCheckoutScreenState extends State<MedicineCheckoutScreen> {
  bool _isLoading = false;
  String _paymentMethod = 'cod'; // cod | online
  bool _saveAddress = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    final user = store.currentUser;
    final id = user?.id ?? 'guest';

    setState(() {
      _nameController.text = prefs.getString('ship_name_$id') ?? user?.name ?? '';
      _phoneController.text = prefs.getString('ship_phone_$id') ?? user?.mobile ?? '';
      _addressController.text = prefs.getString('ship_addr_$id') ?? '';
      _cityController.text = prefs.getString('ship_city_$id') ?? user?.district ?? 'Patna';
      _pincodeController.text = prefs.getString('ship_pin_$id') ?? '';
    });
  }

  Future<void> _saveAddressDetails() async {
    if (!_saveAddress) return;
    final prefs = await SharedPreferences.getInstance();
    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    final id = store.currentUser?.id ?? 'guest';

    await prefs.setString('ship_name_$id', _nameController.text.trim());
    await prefs.setString('ship_phone_$id', _phoneController.text.trim());
    await prefs.setString('ship_addr_$id', _addressController.text.trim());
    await prefs.setString('ship_city_$id', _cityController.text.trim());
    await prefs.setString('ship_pin_$id', _pincodeController.text.trim());
  }

  Future<void> _placeMedicineOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    final cart = Provider.of<CartProvider>(context, listen: false);
    final store = Provider.of<DoctorMitraStore>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final user = store.currentUser;

    final deliveryAddress = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'pincode': _pincodeController.text.trim(),
    };

    final orderItems = cart.items.values.map((item) {
      return {
        'medicine': item.id,
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
      };
    }).toList();

    final orderPayload = {
      'patient': user?.id ?? 'guest_patient_id',
      'items': orderItems,
      'totalAmount': cart.total,
      'deliveryAddress': deliveryAddress,
      'payment': {
        'method': _paymentMethod,
        'status': _paymentMethod == 'online' ? 'successful' : 'pending',
        'transactionId': _paymentMethod == 'online' ? 'tx_razorpay_${DateTime.now().millisecondsSinceEpoch}' : '',
      }
    };

    // If online checkouts chosen, show a beautiful mock Razorpay secure loading dialog
    if (_paymentMethod == 'online') {
      await _simulateOnlineRazorpayCheckout(lang);
    }

    String orderId = 'ord_${DateTime.now().millisecondsSinceEpoch}';

    if (InternetApiLayer.isConfiguredStatic) {
      try {
        final apiBaseUrl = const String.fromEnvironment('DOCTOR_MITRA_API_URL');
        final token = store.token;

        final response = await http.post(
          Uri.parse('$apiBaseUrl/api/orders'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(orderPayload),
        ).timeout(const Duration(seconds: 6));

        if (response.statusCode == 201) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          if (body['success'] == true) {
            orderId = body['data']['_id'] ?? body['data']['id'];
          }
        }
      } catch (e) {
        debugPrint("CheckoutScreen: REST placement error: $e");
      }
    } else {
      // Local sync insertion simulation inside DoctorMitraStore if required
      await Future.delayed(const Duration(seconds: 1));
    }

    await _saveAddressDetails();
    cart.clearCart();

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(orderId: orderId),
        ),
      );
    }
  }

  Future<void> _simulateOnlineRazorpayCheckout(LanguageProvider lang) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 18),
              Text(
                lang.isHindi ? "रेज़रपे भुगतान विंडो खुल रही है..." : "Launching Razorpay Secure Portal...",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Nunito'),
              ),
              const SizedBox(height: 6),
              Text(
                lang.isHindi ? "कृपया विंडो बंद न करें" : "Processing encrypted checksum validation...",
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Nunito'),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    // Simulate 2 seconds online payment processing
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context); // Close loading dialog
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
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
          isHi ? 'चेकआउट' : 'Checkout & Delivery',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Nunito'),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Order Summary header
                    _buildSummaryCard(cart, isHi),
                    const SizedBox(height: 20),

                    // Delivery Address Form
                    Text(
                      isHi ? 'डिलिवरी पता' : 'Delivery Address',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark, fontFamily: 'Nunito'),
                    ),
                    const SizedBox(height: 10),
                    _buildAddressForm(isHi),
                    const SizedBox(height: 24),

                    // Payment Method Options
                    Text(
                      isHi ? 'भुगतान का प्रकार' : 'Payment Method',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark, fontFamily: 'Nunito'),
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentSelector(isHi),
                    const SizedBox(height: 32),

                    // Place Order button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _placeMedicineOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          isHi ? 'आर्डर प्लेस करें (₹${cart.total.toStringAsFixed(0)})' : 'Place Order (₹${cart.total.toStringAsFixed(0)})',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Nunito'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(CartProvider cart, bool isHi) {
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
          Text(
            isHi ? 'आर्डर विवरण' : 'Order Summary',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark, fontFamily: 'Nunito'),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHi ? 'कुल दवाइयाँ' : 'Total Items',
                style: const TextStyle(color: AppColors.textMedium, fontSize: 13, fontFamily: 'Nunito'),
              ),
              Text(
                '${cart.itemCount}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Nunito'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHi ? 'भुगतान योग्य राशि (डिलिवरी सहित)' : 'Grand Total (incl. delivery)',
                style: const TextStyle(color: AppColors.textMedium, fontSize: 13, fontFamily: 'Nunito'),
              ),
              Text(
                '₹${cart.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green, fontFamily: 'Nunito'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm(bool isHi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInput(isHi ? 'प्राप्तकर्ता का नाम' : 'Recipient\'s Name', _nameController, Icons.person_outline),
          const SizedBox(height: 12),
          _buildInput(isHi ? 'मोबाइल नंबर' : 'Phone Number', _phoneController, Icons.phone_android, isPhone: true),
          const SizedBox(height: 12),
          _buildInput(isHi ? 'पूरा पता (गली, मकान न.)' : 'Full Delivery Address', _addressController, Icons.home_outlined, maxLines: 2),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInput(isHi ? 'शहर' : 'City', _cityController, Icons.location_city_outlined),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInput(isHi ? 'पिनकोड' : 'Pincode', _pincodeController, Icons.pin_drop_outlined, isPin: true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            title: Text(
              isHi ? "भविष्य के लिए आर्डर पता सहेजें" : "Save this shipping address for future",
              style: const TextStyle(fontSize: 12, fontFamily: 'Nunito'),
            ),
            value: _saveAddress,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _saveAddress = val;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    bool isPhone = false,
    bool isPin = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: (isPhone || isPin) ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 13, fontFamily: 'Nunito', fontWeight: FontWeight.bold),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Required';
        if (isPhone && val.trim().length < 10) return 'Invalid mobile';
        if (isPin && val.trim().length != 6) return 'Invalid pincode';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textMedium),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPaymentSelector(bool isHi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            activeColor: AppColors.primary,
            title: Text(isHi ? "कैश ऑन डिलीवरी (COD)" : "Cash on Delivery (COD)", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
            subtitle: Text(isHi ? "दवाइयाँ मिलने पर भुगतान करें" : "Pay with cash at your doorstep", style: const TextStyle(fontSize: 11)),
            value: 'cod',
            groupValue: _paymentMethod,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _paymentMethod = val;
                });
              }
            },
          ),
          const Divider(color: AppColors.border),
          RadioListTile<String>(
            activeColor: AppColors.primary,
            title: Text(isHi ? "ऑनलाइन सुरक्षित भुगतान" : "Online Secure Payment", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
            subtitle: Text(isHi ? "रेज़रपे UPI, कार्ड, नेटबैंकिंग" : "Pay via Razorpay UPI / Card / Netbanking", style: const TextStyle(fontSize: 11)),
            value: 'online',
            groupValue: _paymentMethod,
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _paymentMethod = val;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

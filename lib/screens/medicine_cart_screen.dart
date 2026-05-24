import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import 'medicine_checkout_screen.dart';

class MedicineCartScreen extends StatelessWidget {
  const MedicineCartScreen({super.key});

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
          isHi ? 'दवाइयों की कार्ट' : 'Medicine Cart',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Nunito'),
        ),
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart(isHi)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      return _buildCartItemCard(context, item, cart, isHi);
                    },
                  ),
                ),
                _buildPriceSummaryAndCheckout(context, cart, isHi),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(bool isHi) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            isHi ? 'आपकी कार्ट खाली है' : 'Your cart is empty',
            style: const TextStyle(fontSize: 16, color: AppColors.textMedium, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 8),
          Text(
            isHi ? 'दवाइयों की खोज स्क्रीन से दवाइयाँ जोड़ें।' : 'Browse medicines and add them to order online.',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item, CartProvider cart, bool isHi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.premiumShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.vaccines_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 2),
                Text(
                  item.genericName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green, fontFamily: 'Nunito'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // Quantity Selector +/-
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary, size: 22),
                onPressed: () => cart.decrementItem(item.id),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Nunito'),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22),
                onPressed: () => cart.addItem(
                  id: item.id,
                  name: item.name,
                  genericName: item.genericName,
                  manufacturer: item.manufacturer,
                  price: item.price,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Remove Button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
            onPressed: () => cart.removeItem(item.id),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryAndCheckout(BuildContext context, CartProvider cart, bool isHi) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow(isHi ? 'दवाइयों का मूल्य' : 'Subtotal', cart.subtotal),
          const SizedBox(height: 8),
          _buildSummaryRow(isHi ? 'डिलिवरी शुल्क' : 'Delivery Fee', cart.shipping),
          const Divider(height: 20, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHi ? 'कुल राशि' : 'Total Amount',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark, fontFamily: 'Nunito'),
              ),
              Text(
                '₹${cart.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary, fontFamily: 'Nunito'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicineCheckoutScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                isHi ? 'आर्डर के लिए आगे बढ़ें' : 'Proceed to Checkout',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Nunito'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMedium, fontSize: 13, fontFamily: 'Nunito')),
        Text('₹${val.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Nunito')),
      ],
    );
  }
}

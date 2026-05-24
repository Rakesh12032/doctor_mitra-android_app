import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final String genericName;
  final String manufacturer;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.genericName,
    required this.manufacturer,
    required this.price,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get shipping => subtotal > 0 ? 40.0 : 0.0;

  double get total => subtotal + shipping;

  void addItem({
    required String id,
    required String name,
    required String genericName,
    required String manufacturer,
    required double price,
  }) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
    } else {
      _items[id] = CartItem(
        id: id,
        name: name,
        genericName: genericName,
        manufacturer: manufacturer,
        price: price,
        quantity: 1,
      );
    }
    notifyListeners();
  }

  void decrementItem(String id) {
    if (!_items.containsKey(id)) return;
    if (_items[id]!.quantity > 1) {
      _items[id]!.quantity -= 1;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

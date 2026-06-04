import 'package:flutter/foundation.dart';
import '../screens/menu/models/meal.dart';
import '../screens/order/models/cart_item.dart';

class CartService extends ChangeNotifier {
  static final CartService instance = CartService._internal();
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  static const double deliveryFee = 1.50;

  double get total => subtotal + deliveryFee;

  bool containsMeal(String mealId) =>
      _items.any((item) => item.mealId == mealId);

  int quantityOf(String mealId) {
    try {
      return _items.firstWhere((i) => i.mealId == mealId).quantity;
    } catch (_) {
      return 0;
    }
  }

  void addMeal(Meal meal, int quantity) {
    final index = _items.indexWhere((i) => i.mealId == meal.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(
        mealId: meal.id,
        imagePath: meal.imagePath,
        name: meal.name,
        subtitle: meal.category,
        priceValue: meal.price,
        timeBadge: meal.age,
        isHalal: meal.isHalal,
        isKosher: meal.isKosher,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void removeItem(String mealId) {
    _items.removeWhere((i) => i.mealId == mealId);
    notifyListeners();
  }

  void updateQuantity(String mealId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(mealId);
      return;
    }
    final index = _items.indexWhere((i) => i.mealId == mealId);
    if (index >= 0) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

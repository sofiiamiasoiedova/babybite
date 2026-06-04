class CartItem {
  final String mealId;
  final String imagePath;
  final String name;
  final String subtitle;
  final double priceValue;
  final String? timeBadge;
  final bool isHalal;
  final bool isKosher;
  int quantity;

  CartItem({
    required this.mealId,
    required this.imagePath,
    required this.name,
    required this.subtitle,
    required this.priceValue,
    this.timeBadge,
    this.isHalal = false,
    this.isKosher = false,
    this.quantity = 1,
  });

  double get totalPrice => priceValue * quantity;
  String get priceLabel => '€${priceValue.toStringAsFixed(2)}';
  String get totalPriceLabel => '€${totalPrice.toStringAsFixed(2)}';
}

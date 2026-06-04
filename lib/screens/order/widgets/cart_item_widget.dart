import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart_item.dart';

const _kPrimary = Color(0xFF7EB8E8);
const _kSoftBlue = Color(0xFFD4E8F8);
const _kDarkBlue = Color(0xFF2C3E6B);

Widget buildDietaryTags(bool isHalal, bool isKosher) {
  if (!isHalal && !isKosher) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      children: [
        if (isHalal)
          _dietaryTag('Halal', Icons.mosque_rounded,
              const Color(0xFF2E8B57), const Color(0xFFDFF5EA)),
        if (isHalal && isKosher) const SizedBox(width: 6),
        if (isKosher)
          _dietaryTag('Kosher', Icons.hexagon_outlined,
              const Color(0xFF5B4FCF), const Color(0xFFEDE9FF)),
      ],
    ),
  );
}

Widget _dietaryTag(
    String label, IconData icon, Color textColor, Color bgColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: textColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDelete;
  final ValueChanged<int>? onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onDelete,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            item.imagePath,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kDarkBlue,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (item.timeBadge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kPrimary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.timeBadge!,
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              buildDietaryTags(item.isHalal, item.isKosher),
              const SizedBox(height: 6),
              Row(
                children: [
                  // Quantity stepper
                  _qtyBtn(
                    icon: Icons.remove_rounded,
                    onTap: () =>
                        onQuantityChanged?.call(item.quantity - 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _kDarkBlue,
                      ),
                    ),
                  ),
                  _qtyBtn(
                    icon: Icons.add_rounded,
                    onTap: () =>
                        onQuantityChanged?.call(item.quantity + 1),
                  ),
                  const Spacer(),
                  Text(
                    item.totalPriceLabel,
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _kPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE57373),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: _kSoftBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: _kDarkBlue),
      ),
    );
  }
}

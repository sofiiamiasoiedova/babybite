import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';

class CategoryPills extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CategoryPills({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const _icons = [
    (icon: Icons.blur_circular_rounded, color: Color(0xFFF5B638)),
    (icon: Icons.cookie_rounded, color: Color(0xFFF47B89)),
    (icon: Icons.breakfast_dining_rounded, color: Color(0xFF7AC96A)),
    (icon: Icons.icecream_rounded, color: Color(0xFF89B8E3)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final active = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active
                      ? AppColors.blueAccent
                      : const Color(0xFFDBEAF8),
                  width: active ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blueSoft.withValues(alpha: .12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_icons[i].icon, size: 18, color: _icons[i].color),
                  const SizedBox(width: 8),
                  Text(
                    categories[i],
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? AppColors.blueAccent
                          : AppColors.blueDeep,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

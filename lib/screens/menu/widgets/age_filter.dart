import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';

class AgeFilter extends StatelessWidget {
  final List<String> ages;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const AgeFilter({
    super.key,
    required this.ages,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(ages.length, (i) {
          final active = i == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                decoration: BoxDecoration(
                  color: active ? AppColors.blueAccent : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active
                        ? AppColors.blueAccent
                        : const Color(0xFFD6E6F7),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blueSoft.withValues(alpha: .15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  ages[i],
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.blueMid,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

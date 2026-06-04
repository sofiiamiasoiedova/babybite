import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';
import '../models/baby_info.dart';

class BabyCard extends StatelessWidget {
  final BabyInfo baby;
  final VoidCallback onEditTap;
  final String? ageDisplay;

  const BabyCard({
    super.key,
    required this.baby,
    required this.onEditTap,
    this.ageDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueSoft.withValues(alpha: .2),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6EDFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.child_care_rounded,
                      size: 20, color: AppColors.blueAccent),
                ),
                const SizedBox(width: 10),
                Text(
                  'Baby Info',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueDeep,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onEditTap,
                  child: Text(
                    'Edit',
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 14),
            _InfoRow(icon: Icons.cake_rounded, label: 'Name', value: baby.name),
            const SizedBox(height: 10),
            _InfoRow(
                icon: Icons.today_rounded,
                label: 'Age',
                value: ageDisplay ?? baby.age),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.warning_amber_rounded,
              label: 'Allergies',
              value: baby.allergies,
              valueColor: baby.allergies.toLowerCase() == 'none'
                  ? const Color(0xFF7AC96A)
                  : const Color(0xFFE57373),
            ),
            const SizedBox(height: 10),
            _InfoRow(
                icon: Icons.monitor_weight_outlined,
                label: 'Weight',
                value: baby.weight),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: AppColors.blueSoft),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.placeholder,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.blueDeep,
            ),
          ),
        ),
      ],
    );
  }
}

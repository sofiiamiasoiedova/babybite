import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';
import '../help_support_screen.dart';
import '../about_screen.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SettingsItemData(
        icon: Icons.help_outline_rounded,
        label: 'Help & Support',
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const HelpSupportScreen(),
        )),
      ),
      _SettingsItemData(
        icon: Icons.info_outline_rounded,
        label: 'About BabyBite',
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const AboutScreen(),
        )),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueSoft.withValues(alpha: .18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            return Column(
              children: [
                _SettingsItem(icon: item.icon, label: item.label, onTap: item.onTap),
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 16,
                    color: AppColors.cardBorder,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _SettingsItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsItemData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EDFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: AppColors.blueAccent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueDeep,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.placeholder, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

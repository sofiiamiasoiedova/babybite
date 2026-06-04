import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogoCard(),
                  const SizedBox(height: 24),
                  _sectionLabel('App Information'),
                  const SizedBox(height: 10),
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _sectionLabel('Legal'),
                  const SizedBox(height: 10),
                  _buildLegalCard(context),
                  const SizedBox(height: 24),
                  _buildSocialRow(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.heroTop, AppColors.heroBottom],
          ),
        ),
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 12, 20, 20),
        child: Row(
          children: [
            _iconBtn(Icons.arrow_back_ios_new_rounded,
                () => Navigator.of(context).pop()),
            Expanded(
              child: Text(
                'About BabyBite',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueDeep,
                ),
              ),
            ),
            const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withValues(alpha: .75),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.blueDeep, size: 20),
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueSoft.withValues(alpha: .15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7EC8F0), Color(0xFF4A9FD8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueAccent.withValues(alpha: .3),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.child_care_rounded,
                size: 42, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            'BabyBite',
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.blueDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Smart nutrition for your little one',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: AppColors.blueMid,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD6EDFB),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Version 1.0.0',
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.quicksand(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.blueMid,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildInfoCard() {
    final items = [
      (icon: Icons.update_rounded, label: 'Version', value: '1.0.0'),
      (icon: Icons.build_outlined, label: 'Build', value: '2026.04.12'),
      (icon: Icons.phone_android_rounded, label: 'Platform', value: 'Flutter'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueSoft.withValues(alpha: .15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6EDFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon,
                          size: 18, color: AppColors.blueAccent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label,
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueDeep,
                        ),
                      ),
                    ),
                    Text(
                      item.value,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.placeholder,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                const Divider(
                    height: 1,
                    indent: 66,
                    endIndent: 16,
                    color: AppColors.cardBorder),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLegalCard(BuildContext context) {
    final items = [
      (icon: Icons.policy_outlined, label: 'Privacy Policy'),
      (icon: Icons.description_outlined, label: 'Terms of Service'),
      (icon: Icons.copyright_rounded, label: 'Open Source Licenses'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueSoft.withValues(alpha: .15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showComingSoon(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6EDFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon,
                              size: 18, color: AppColors.blueAccent),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.label,
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
              ),
              if (i < items.length - 1)
                const Divider(
                    height: 1,
                    indent: 66,
                    endIndent: 16,
                    color: AppColors.cardBorder),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSocialRow(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Follow us',
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.blueMid,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialBtn(Icons.facebook_rounded, () => _showComingSoon(context)),
            const SizedBox(width: 16),
            _socialBtn(
                Icons.camera_alt_outlined, () => _showComingSoon(context)),
            const SizedBox(width: 16),
            _socialBtn(Icons.language_rounded, () => _showComingSoon(context)),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '© 2026 BabyBite. All rights reserved.',
          style: GoogleFonts.quicksand(
            fontSize: 12,
            color: AppColors.placeholder,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _socialBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xFFD6EDFB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.blueAccent, size: 22),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feature coming soon',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

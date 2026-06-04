import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodTrackerScreen extends StatefulWidget {
  const FoodTrackerScreen({super.key});

  @override
  State<FoodTrackerScreen> createState() => _FoodTrackerScreenState();
}

class _FoodTrackerScreenState extends State<FoodTrackerScreen> {
  final String _selectedDate = 'Monday, April 22';
  final double _nutritionProgress = 0.72;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEEEFA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Hero image
            _buildHeroImage(),
            // White card body
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F7FE),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: Column(
                    children: [
                      _buildDateCard(),
                      const SizedBox(height: 14),
                      _buildDeliveryStatusCard(),
                      const SizedBox(height: 14),
                      _buildInfoCard(
                        icon: Icons.face_rounded,
                        iconBgColor: const Color(0xFFCDE8F8),
                        iconColor: const Color(0xFF5AA3E8),
                        title: "Anna's Kitchen",
                        subtitle: 'Bergstraat 32, 1000 Brussels',
                      ),
                      const SizedBox(height: 14),
                      _buildInfoCard(
                        icon: Icons.pets_rounded,
                        iconBgColor: const Color(0xFFCDE8F8),
                        iconColor: const Color(0xFF5AA3E8),
                        title: 'Dietary Preferences:',
                        subtitle: 'Avoiding Caaning)',
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          _headerBtn(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Food Tracker',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3A5F),
              ),
            ),
          ),
          _headerBtn(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _headerBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF89B8E3).withValues(alpha: .2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF5AA3E8), size: 22),
      ),
    );
  }

  // ============================================================
  // HERO IMAGE
  // ============================================================
  Widget _buildHeroImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          height: 220,
          child: Image.asset(
            'assets/img/order_header.png',
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  // ============================================================
  // DATE + PROGRESS CARD
  // ============================================================
  Widget _buildDateCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF89B8E3).withValues(alpha: .10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date row
          Row(
            children: [
              Text(
                _selectedDate,
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A5F),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_drop_down_rounded,
                  color: Color(0xFF1E3A5F), size: 24),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _nutritionProgress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE0EFF9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7AC96A)),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Balanced Nutrition goal',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5AA3E8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELIVERY STATUS CARD
  // ============================================================
  Widget _buildDeliveryStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF89B8E3).withValues(alpha: .10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded,
              color: Color(0xFF5AA3E8), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Happy delivery Station',
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5AA3E8),
              ),
            ),
          ),
          // Warning badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                size: 16, color: Color(0xFFF5B638)),
          ),
          const SizedBox(width: 10),
          // Toggle switch style button
          Container(
            width: 44,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFCDE8F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(right: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFF5AA3E8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD (Kitchen / Dietary)
  // ============================================================
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF89B8E3).withValues(alpha: .10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: const Color(0xFF9EBAD4),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFF5AA3E8), size: 24),
        ],
      ),
    );
  }
}
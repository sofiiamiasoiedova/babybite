import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/order_service.dart';
import '../../services/favorite_service.dart';
import '../../services/health_condition_service.dart';
import '../../services/baby_age_service.dart';
import '../../models/health_condition.dart';
import 'models/user_profile.dart';
import 'models/baby_info.dart';
import 'widgets/profile_header.dart';
import 'widgets/stats_row.dart';
import 'widgets/baby_card.dart';
import 'widgets/settings_section.dart';
import 'widgets/logout_button.dart';
import 'edit_profile_screen.dart';
import 'edit_baby_screen.dart';
import '../order/order_history_screen.dart';
import 'favorite_meals_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile _profile = const UserProfile(
    name: 'Anna Johnson',
    email: 'anna.johnson@email.com',
    phone: '+32 470 000 000',
  );

  BabyInfo _baby = BabyInfo(
    name: 'Lily',
    birthDate: DateTime(2025, 8, 11),
    allergies: 'None',
    weight: '8.2 kg',
  );

  bool _showAgeInMonths = true;

  @override
  void initState() {
    super.initState();
    // Restore saved baby info so state survives tab switches
    final saved = BabyAgeService.instance.babyInfo;
    if (saved != null) {
      _baby = saved;
    } else {
      BabyAgeService.instance.update(_baby);
    }
    _showAgeInMonths = BabyAgeService.instance.showAgeInMonths;
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: _profile),
      ),
    );
    if (result != null) setState(() => _profile = result);
  }

  Future<void> _openEditBaby() async {
    final result = await Navigator.of(context).push<BabyInfo>(
      MaterialPageRoute(
        builder: (_) => EditBabyScreen(baby: _baby),
      ),
    );
    if (result != null) {
      setState(() => _baby = result);
      BabyAgeService.instance.update(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ProfileHeader(profile: _profile, onEditTap: _openEditProfile),
          const SizedBox(height: 20),
          const StatsRow(),
          const SizedBox(height: 20),
          BabyCard(
            baby: _baby,
            onEditTap: _openEditBaby,
            ageDisplay: _showAgeInMonths
                ? _baby.ageAsMonths
                : _baby.ageAsYears,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: _AgeFormatToggleRow(
              showInMonths: _showAgeInMonths,
              onToggle: (v) {
                setState(() => _showAgeInMonths = v);
                BabyAgeService.instance.showAgeInMonthsListenable.value = v;
              },
            ),
          ),
          const SizedBox(height: 20),
          const _HealthConditionsCard(),
          const SizedBox(height: 20),
          _MyOrdersButton(onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const OrderHistoryScreen(),
            ));
          }),
          const SizedBox(height: 12),
          _FavoriteMealsButton(onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const FavoriteMealsScreen(),
            ));
          }),
          const SizedBox(height: 20),
          const SettingsSection(),
          const SizedBox(height: 28),
          const LogoutButton(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// HEALTH CONDITIONS CARD
// ─────────────────────────────────────────────────────────
class _HealthConditionsCard extends StatelessWidget {
  const _HealthConditionsCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<HealthCondition>>(
      valueListenable: HealthConditionService.instance.selectedListenable,
      builder: (_, selected, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEAF2FB)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7EB8E8).withValues(alpha: .14),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
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
                        color: const Color(0xFFE8F4FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.health_and_safety_rounded,
                        size: 20,
                        color: Color(0xFF5AA3E8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Child\'s Health Conditions',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E3A5F),
                            ),
                          ),
                          Text(
                            'Select for personalized meal recommendations',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              color: const Color(0xFF9EBAD4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected.isNotEmpty)
                      GestureDetector(
                        onTap: HealthConditionService.instance.clearAll,
                        child: Text(
                          'Clear',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9EBAD4),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: HealthCondition.values.map((condition) {
                    final isSelected = selected.contains(condition);
                    return GestureDetector(
                      onTap: () =>
                          HealthConditionService.instance.toggle(condition),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? condition.color.withValues(alpha: .12)
                              : const Color(0xFFF5F9FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? condition.color.withValues(alpha: .6)
                                : const Color(0xFFD6E6F7),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              condition.icon,
                              size: 14,
                              color: isSelected
                                  ? condition.color
                                  : const Color(0xFF9EBAD4),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              condition.displayName,
                              style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? condition.color
                                    : const Color(0xFF6B8FAE),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 5),
                              Icon(
                                Icons.check_circle_rounded,
                                size: 13,
                                color: condition.color,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (selected.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 13, color: Color(0xFF43A047)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Meals are now labeled based on your selection. Check the menu for suitable options.',
                            style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 13, color: Color(0xFFD97706)),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'This app provides general nutritional guidance and does not replace medical advice.',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// MY ORDERS BUTTON
// ─────────────────────────────────────────────────────────
class _MyOrdersButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MyOrdersButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final activeCount = OrderService.instance.activeOrders.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEAF2FB)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7EB8E8).withValues(alpha: .14),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4E8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      size: 20, color: Color(0xFF5AA3E8)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'My Orders',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                if (activeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5AA3E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$activeCount delivering',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (activeCount == 0)
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF9EBAD4), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteMealsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FavoriteMealsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoriteService.instance.favoriteMealIdsListenable,
      builder: (_, favoriteIds, _) {
        final favoriteCount = favoriteIds.length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEAF2FB)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7EB8E8).withValues(alpha: .14),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          size: 20, color: Color(0xFFE86868)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Favorite Meals',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E3A5F),
                        ),
                      ),
                    ),
                    if (favoriteCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE86868),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$favoriteCount meals',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (favoriteCount == 0)
                      const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFF9EBAD4), size: 22),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// AGE FORMAT TOGGLE ROW (standalone, below BabyCard)
// ─────────────────────────────────────────────────────────
class _AgeFormatToggleRow extends StatelessWidget {
  final bool showInMonths;
  final ValueChanged<bool> onToggle;

  const _AgeFormatToggleRow({
    required this.showInMonths,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Age display',
          style: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9EBAD4),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD6E6F7)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7EB8E8).withValues(alpha: .10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToggleOption(
                label: 'months',
                active: showInMonths,
                onTap: () => onToggle(true),
              ),
              _ToggleOption(
                label: 'years',
                active: !showInMonths,
                onTap: () => onToggle(false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF5AA3E8) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF9EBAD4),
          ),
        ),
      ),
    );
  }
}

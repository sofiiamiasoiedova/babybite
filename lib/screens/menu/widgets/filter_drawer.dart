import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';
import '../../../models/health_condition.dart';
import '../../../services/health_condition_service.dart';
import '../../../services/baby_age_service.dart';

class FilterDrawer extends StatelessWidget {
  final List<String> ages;
  final int selectedAgeIndex;
  final List<String> categories;
  final int selectedCategoryIndex;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<int> onCategoryChanged;
  final bool favoritesOnly;
  final ValueChanged<bool> onFavoritesOnlyChanged;
  final bool halalOnly;
  final ValueChanged<bool> onHalalOnlyChanged;
  final bool kosherOnly;
  final ValueChanged<bool> onKosherOnlyChanged;
  final bool suitableOnly;
  final ValueChanged<bool> onSuitableOnlyChanged;
  final VoidCallback onReset;

  const FilterDrawer({
    super.key,
    required this.ages,
    required this.selectedAgeIndex,
    required this.categories,
    required this.selectedCategoryIndex,
    required this.onAgeChanged,
    required this.onCategoryChanged,
    required this.favoritesOnly,
    required this.onFavoritesOnlyChanged,
    required this.halalOnly,
    required this.onHalalOnlyChanged,
    required this.kosherOnly,
    required this.onKosherOnlyChanged,
    required this.suitableOnly,
    required this.onSuitableOnlyChanged,
    required this.onReset,
  });

  static const _categoryIcons = [
    (icon: Icons.apps_rounded, color: Color(0xFF5AA3E8)),
    (icon: Icons.blur_circular_rounded, color: Color(0xFFF5B638)),
    (icon: Icons.cookie_rounded, color: Color(0xFFF47B89)),
    (icon: Icons.breakfast_dining_rounded, color: Color(0xFF7AC96A)),
    (icon: Icons.icecream_rounded, color: Color(0xFF89B8E3)),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      backgroundColor: const Color(0xFFEAF4FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDrawerHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBabyQuickFilter(),
                    _buildSection(
                      label: 'Age Group',
                      icon: Icons.wb_sunny_outlined,
                      child: _buildAgeChips(),
                    ),
                    const SizedBox(height: 28),
                    _buildSection(
                      label: 'Category',
                      icon: Icons.restaurant_menu_rounded,
                      child: _buildCategoryChips(),
                    ),
                    const SizedBox(height: 28),
                    _buildSection(
                      label: 'Dietary',
                      icon: Icons.verified_rounded,
                      child: _buildDietaryToggles(),
                    ),
                    const SizedBox(height: 28),
                    _buildSection(
                      label: 'Health Conditions',
                      icon: Icons.health_and_safety_rounded,
                      child: _buildHealthConditions(),
                    ),
                    const SizedBox(height: 28),
                    _buildSection(
                      label: 'Favorites',
                      icon: Icons.favorite_rounded,
                      child: _buildFavoritesToggle(),
                    ),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.heroTop, AppColors.heroBottom],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded,
              color: AppColors.blueAccent, size: 22),
          const SizedBox(width: 10),
          Text(
            'Filters',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.blueDeep,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              HealthConditionService.instance.clearAll();
              onReset();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.blueMid,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(
              'Reset',
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.blueMid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.blueAccent),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.blueDeep,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }

  Widget _buildBabyQuickFilter() {
    final svc = BabyAgeService.instance;
    final babyName = svc.babyName;
    final ageGroup = svc.suggestedAgeGroup;
    if (babyName == null || ageGroup == null) return const SizedBox.shrink();

    final babyIdx = ages.indexOf(ageGroup);
    final isActive = selectedAgeIndex == babyIdx;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.child_care_rounded,
                size: 16, color: AppColors.blueAccent),
            const SizedBox(width: 8),
            Text(
              'Baby\'s Age',
              style: GoogleFonts.fredoka(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.blueDeep,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            if (isActive) {
              onAgeChanged(ages.indexOf('All'));
            } else {
              onAgeChanged(babyIdx);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.blueAccent.withValues(alpha: .10)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? AppColors.blueAccent.withValues(alpha: .5)
                    : const Color(0xFFD6E6F7),
                width: isActive ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueSoft.withValues(alpha: .12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  '$babyName · $ageGroup',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? AppColors.blueDeep
                        : AppColors.blueMid,
                  ),
                ),
                const Spacer(),
                if (isActive)
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.blueAccent)
                else
                  const Icon(Icons.radio_button_unchecked_rounded,
                      size: 16, color: AppColors.placeholder),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildAgeChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(ages.length, (i) {
        final active = i == selectedAgeIndex;
        return GestureDetector(
          onTap: () => onAgeChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
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
                  color: AppColors.blueSoft.withValues(alpha: .12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
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
        );
      }),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(categories.length, (i) {
        final active = i == selectedCategoryIndex;
        return GestureDetector(
          onTap: () => onCategoryChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
                  color: AppColors.blueSoft.withValues(alpha: .12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _categoryIcons[i].icon,
                  size: 16,
                  color: active
                      ? Colors.white
                      : _categoryIcons[i].color,
                ),
                const SizedBox(width: 8),
                Text(
                  categories[i],
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.blueDeep,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            'Apply Filters',
            style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDietaryToggles() {
    return Column(
      children: [
        _buildToggleTile(
          label: 'Halal',
          subtitle: 'Suitable for Muslim dietary requirements',
          value: halalOnly,
          onChanged: onHalalOnlyChanged,
          activeColor: const Color(0xFF3CB878),
          icon: Icons.mosque_rounded,
        ),
        const SizedBox(height: 10),
        _buildToggleTile(
          label: 'Kosher',
          subtitle: 'Suitable for Jewish dietary laws',
          value: kosherOnly,
          onChanged: onKosherOnlyChanged,
          activeColor: const Color(0xFF7B68EE),
          icon: Icons.hexagon_outlined,
        ),
      ],
    );
  }

  Widget _buildHealthConditions() {
    return ValueListenableBuilder<Set<HealthCondition>>(
      valueListenable: HealthConditionService.instance.selectedListenable,
      builder: (_, selected, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HealthCondition.values.map((condition) {
                final active = selected.contains(condition);
                return GestureDetector(
                  onTap: () =>
                      HealthConditionService.instance.toggle(condition),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: active
                          ? condition.color.withValues(alpha: .12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active
                            ? condition.color.withValues(alpha: .6)
                            : const Color(0xFFD6E6F7),
                        width: active ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blueSoft.withValues(alpha: .12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          condition.icon,
                          size: 14,
                          color: active
                              ? condition.color
                              : AppColors.blueMid,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          condition.displayName,
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: active
                                ? condition.color
                                : AppColors.blueDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (selected.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildToggleTile(
                label: 'Suitable meals only',
                subtitle: 'Hide meals not matching conditions',
                value: suitableOnly,
                onChanged: onSuitableOnlyChanged,
                activeColor: const Color(0xFF43A047),
                icon: Icons.filter_list_rounded,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildToggleTile({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? activeColor.withValues(alpha: .4) : const Color(0xFFD6E6F7),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueSoft.withValues(alpha: .12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: activeColor,
          activeTrackColor: activeColor.withValues(alpha: .3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.blueDeep,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              color: AppColors.placeholder,
            ),
          ),
          secondary: Icon(
            icon,
            color: value ? activeColor : AppColors.blueMid,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6E6F7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueSoft.withValues(alpha: .12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile.adaptive(
          value: favoritesOnly,
          onChanged: onFavoritesOnlyChanged,
          activeThumbColor: const Color(0xFFE86868),
          activeTrackColor: const Color(0xFFE86868).withValues(alpha: .3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Text(
            'Only favorites',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.blueDeep,
            ),
          ),
          secondary: Icon(
            favoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: favoritesOnly ? const Color(0xFFE86868) : AppColors.blueMid,
            size: 18,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';
import '../../../services/favorite_service.dart';
import '../../../services/health_condition_service.dart';
import '../../../services/baby_age_service.dart';
import '../../../models/health_condition.dart';
import '../models/meal.dart';
import '../meal_detail_screen.dart';

class MealCardItem extends StatelessWidget {
  final Meal meal;

  const MealCardItem({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MealDetailScreen(meal: meal),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueSoft.withValues(alpha: .2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final favoriteListenable = FavoriteService.instance.favoriteMealIdsListenable;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Stack(
        children: [
          Image.asset(
            meal.imagePath,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 12,
            right: 12,
            child: ValueListenableBuilder<bool>(
              valueListenable:
                  BabyAgeService.instance.showAgeInMonthsListenable,
              builder: (_, inMonths, _) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  meal.displayAge(inMonths: inMonths),
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueMid,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: ValueListenableBuilder<Set<String>>(
              valueListenable: favoriteListenable,
              builder: (_, favoriteIds, _) {
                if (!favoriteIds.contains(meal.id)) {
                  return const SizedBox.shrink();
                }
                return Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 17,
                    color: Color(0xFFE86868),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return ValueListenableBuilder<Set<HealthCondition>>(
      valueListenable: HealthConditionService.instance.selectedListenable,
      builder: (_, conditions, _) {
        final hasTags = meal.healthTagLabels.isNotEmpty;
        final hasConditions = conditions.isNotEmpty;
        final isSuitable = meal.isSuitableForAll(conditions);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.name,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blueDeep,
                  height: 1.25,
                ),
              ),
              // Suitability badge (only when conditions are selected)
              if (hasConditions) ...[
                const SizedBox(height: 7),
                _suitabilityBadge(isSuitable),
              ],
              // Dietary tags (Halal / Kosher)
              if (meal.isHalal || meal.isKosher) ...[
                const SizedBox(height: 7),
                Row(
                  children: [
                    if (meal.isHalal)
                      _dietaryTag(
                        label: 'Halal',
                        icon: Icons.mosque_rounded,
                        textColor: const Color(0xFF2E8B57),
                        bgColor: const Color(0xFFDFF5EA),
                      ),
                    if (meal.isHalal && meal.isKosher) const SizedBox(width: 6),
                    if (meal.isKosher)
                      _dietaryTag(
                        label: 'Kosher',
                        icon: Icons.hexagon_outlined,
                        textColor: const Color(0xFF5B4FCF),
                        bgColor: const Color(0xFFEDE9FF),
                      ),
                  ],
                ),
              ],
              // Health tags
              if (hasTags) ...[
                const SizedBox(height: 7),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: meal.healthTagLabels
                      .map((tag) => _healthTag(tag))
                      .toList(),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      size: 15, color: Color(0xFFF5B638)),
                  const SizedBox(width: 5),
                  Text(
                    '${meal.cookTime} min  •  ${meal.stage}',
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7A9BBF),
                    ),
                  ),
                  const Spacer(),
                  ...List.generate(
                    meal.rating.floor(),
                    (_) => const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.star),
                  ),
                  if (meal.rating % 1 >= 0.5)
                    const Icon(Icons.star_half_rounded,
                        size: 14, color: AppColors.star),
                  const SizedBox(width: 4),
                  Text(
                    '${meal.reviews}',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blueMid,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _suitabilityBadge(bool suitable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: suitable
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            suitable
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            size: 11,
            color: suitable
                ? const Color(0xFF43A047)
                : const Color(0xFFD97706),
          ),
          const SizedBox(width: 4),
          Text(
            suitable ? 'Suitable' : 'Not recommended',
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: suitable
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthTag(String label) {
    final (:Color color, :Color bgColor) = _healthTagStyle(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _dietaryTag({
    required String label,
    required IconData icon,
    required Color textColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
}

({Color color, Color bgColor}) _healthTagStyle(String label) {
  switch (label) {
    case 'Low Sugar':
      return (
        color: const Color(0xFF059669),
        bgColor: const Color(0xFFD1FAE5),
      );
    case 'Low GI':
      return (
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFDBEAFE),
      );
    case 'Anti-inflammatory':
      return (
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFEDE9FE),
      );
    case 'No Dairy':
      return (
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
      );
    default:
      return (
        color: const Color(0xFF5AA3E8),
        bgColor: const Color(0xFFDBEAFE),
      );
  }
}

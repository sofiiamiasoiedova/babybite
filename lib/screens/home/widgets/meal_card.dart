import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';
import '../../../services/favorite_service.dart';
import '../../../services/baby_age_service.dart';
import '../../menu/models/meal.dart';
import '../../menu/meal_detail_screen.dart';

class RecommendedMealsList extends StatelessWidget {
  final List<Meal> meals;
  final String emptyMessage;

  const RecommendedMealsList({
    super.key,
    required this.meals,
    this.emptyMessage = 'No meals for this age yet',
  });

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.no_meals_rounded,
                    size: 36, color: AppColors.placeholder),
                const SizedBox(height: 10),
                Text(
                  emptyMessage,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.placeholder,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: meals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _MealChip(meal: meals[i]),
      ),
    );
  }
}

class _MealChip extends StatelessWidget {
  final Meal meal;
  const _MealChip({required this.meal});

  Widget _dietaryTag({
    required String label,
    required IconData icon,
    required Color textColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteListenable = FavoriteService.instance.favoriteMealIdsListenable;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, animation, _) => MealDetailScreen(meal: meal),
          transitionsBuilder: (_, animation, _, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueSoft.withValues(alpha: .2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Image.asset(
                    meal.imagePath,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ValueListenableBuilder<bool>(
                      valueListenable:
                          BabyAgeService.instance.showAgeInMonthsListenable,
                      builder: (_, inMonths, _) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .85),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          meal.displayAge(inMonths: inMonths),
                          style: GoogleFonts.quicksand(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blueMid,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: ValueListenableBuilder<Set<String>>(
                      valueListenable: favoriteListenable,
                      builder: (_, favoriteIds, _) {
                        if (!favoriteIds.contains(meal.id)) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 13,
                            color: Color(0xFFE86868),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueDeep,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (meal.isHalal || meal.isKosher) ...[
                      Row(
                        children: [
                          if (meal.isHalal)
                            _dietaryTag(
                              label: 'Halal',
                              icon: Icons.mosque_rounded,
                              textColor: const Color(0xFF2E8B57),
                              bgColor: const Color(0xFFDFF5EA),
                            ),
                          if (meal.isHalal && meal.isKosher)
                            const SizedBox(width: 4),
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
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            size: 12, color: const Color(0xFFF5B638)),
                        const SizedBox(width: 3),
                        Text(
                          '${meal.cookTime}m',
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueMid,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded,
                            size: 12, color: AppColors.star),
                        const SizedBox(width: 2),
                        Text(
                          meal.rating.toStringAsFixed(1),
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blueMid,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

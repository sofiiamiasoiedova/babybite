import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../services/favorite_service.dart';
import '../menu/data/meal_data.dart';
import '../menu/widgets/meal_card_item.dart';

class FavoriteMealsScreen extends StatelessWidget {
  const FavoriteMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFEAF4FF),
        surfaceTintColor: const Color(0xFFEAF4FF),
        title: Text(
          'Favorite Meals',
          style: GoogleFonts.fredoka(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.blueDeep,
          ),
        ),
      ),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: FavoriteService.instance.favoriteMealIdsListenable,
        builder: (_, favoriteIds, _) {
          final meals = allMeals
              .where((meal) => favoriteIds.contains(meal.id))
              .toList()
            ..sort((a, b) => b.rating.compareTo(a.rating));

          if (meals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_border_rounded,
                    size: 56,
                    color: AppColors.placeholder,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No favorite meals yet',
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueMid,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap heart icon in meal details to add favorites',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: AppColors.placeholder,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: meals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (_, i) => MealCardItem(meal: meals[i]),
          );
        },
      ),
    );
  }
}

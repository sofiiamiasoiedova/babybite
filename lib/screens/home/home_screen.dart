import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../profile/models/user_profile.dart';
import '../profile/models/baby_info.dart';
import '../menu/data/meal_data.dart';
import '../menu/models/meal.dart';
import '../menu/meal_detail_screen.dart';
import '../../services/favorite_service.dart';
import '../../services/baby_age_service.dart';
import 'widgets/hero_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/section_head.dart';
import 'widgets/meal_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample data — thay bằng state management khi cần đồng bộ với ProfileScreen
  static final _profile = UserProfile(
    name: 'Anna Johnson',
    email: 'anna.johnson@email.com',
    phone: '+32 470 000 000',
  );

  static final _baby = BabyInfo(
    name: 'Lily',
    birthDate: DateTime(2025, 8, 11),
    allergies: 'None',
    weight: '8.2 kg',
  );

  String _selectedAge = '6m+';
  String _searchQuery = '';
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  List<Meal> get _recommendedMeals {
    final List<Meal> filtered;
    if (_selectedAge == 'All') {
      filtered = List.of(allMeals);
    } else {
      final targetMonths = _parseAge(_selectedAge);
      filtered =
          allMeals.where((m) => m.ageInMonths == targetMonths).toList();
    }
    // Sort by rating descending, take top 3
    filtered.sort((a, b) => b.rating.compareTo(a.rating));
    return filtered.take(3).toList();
  }

  List<Meal> get _searchSuggestions {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final results = allMeals
        .where((meal) => meal.name.toLowerCase().contains(query))
        .toList();
    results.sort((a, b) => b.rating.compareTo(a.rating));
    return results.take(5).toList();
  }

  bool get _showSearchDropdown {
    return _searchFocusNode.hasFocus && _searchQuery.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode()..addListener(_handleSearchFocusChanged);
  }

  void _handleSearchFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchFocusNode
      ..removeListener(_handleSearchFocusChanged)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openMealDetail(Meal meal) {
    _searchController.text = meal.name;
    _searchQuery = meal.name;
    _searchFocusNode.unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)),
    );
  }

  int _parseAge(String age) {
    switch (age) {
      case '6m+':
        return 6;
      case '12m+':
        return 12;
      case '18m+':
        return 18;
      case '24m+':
        return 24;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final meals = _recommendedMeals;
    final suggestions = _searchSuggestions;
    final showSearchDropdown = _showSearchDropdown;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: const Color(0xFFEAF4FF),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroHeader(profile: _profile, baby: _baby),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Hi, ${_profile.name.split(' ').first}!',
                  style: GoogleFonts.fredoka(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueDeep,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'What are we eating today?',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blueMid,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              HomeSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              if (showSearchDropdown)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: _SearchSuggestionsDropdown(
                    suggestions: suggestions,
                    onTapMeal: _openMealDetail,
                  ),
                ),
              const SizedBox(height: 28),
              SectionHead(
                selectedAge: _selectedAge,
                onAgeChanged: (age) => setState(() => _selectedAge = age),
              ),
              const SizedBox(height: 14),
              RecommendedMealsList(meals: meals),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Your Favorites',
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueDeep,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder<Set<String>>(
                valueListenable: FavoriteService.instance.favoriteMealIdsListenable,
                builder: (_, favoriteIds, _) {
                  final favoriteMeals = allMeals
                      .where((meal) => favoriteIds.contains(meal.id))
                      .toList()
                    ..sort((a, b) => b.rating.compareTo(a.rating));

                  return RecommendedMealsList(
                    meals: favoriteMeals,
                    emptyMessage: 'No favorite meals yet',
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSuggestionsDropdown extends StatelessWidget {
  final List<Meal> suggestions;
  final ValueChanged<Meal> onTapMeal;

  const _SearchSuggestionsDropdown({
    required this.suggestions,
    required this.onTapMeal,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueSoft.withValues(alpha: .22),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          'No matching meals found',
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.placeholder,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueSoft.withValues(alpha: .22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 1,
          color: AppColors.cardBorder.withValues(alpha: .7),
        ),
        itemBuilder: (context, index) {
          final meal = suggestions[index];
          return ValueListenableBuilder<Set<String>>(
            valueListenable: FavoriteService.instance.favoriteMealIdsListenable,
            builder: (_, favoriteIds, _) {
              final isFavorite = favoriteIds.contains(meal.id);
              return Material(
                color: Colors.transparent,
                child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    meal.imagePath,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  meal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueDeep,
                  ),
                ),
                subtitle: ValueListenableBuilder<bool>(
                  valueListenable:
                      BabyAgeService.instance.showAgeInMonthsListenable,
                  builder: (_, inMonths, _) => Text(
                    '${meal.displayAge(inMonths: inMonths)}+ • ${meal.category}',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueMid,
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFavorite)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 15,
                          color: Color(0xFFE86868),
                        ),
                      ),
                    const Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: AppColors.blueAccent,
                    ),
                  ],
                ),
                onTap: () => onTapMeal(meal),
              ),
              );
            },
          );
        },
      ),
    );
  }
}

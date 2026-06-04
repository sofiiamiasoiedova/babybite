import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../services/favorite_service.dart';
import '../../services/health_condition_service.dart';
import 'data/meal_data.dart';
import 'models/meal.dart';
import 'widgets/menu_header.dart';
import 'widgets/meal_card_item.dart';
import 'widgets/filter_drawer.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isSearching = false;
  final _searchController = TextEditingController();
  String _searchText = '';

  int _ageIndex = 4; // default: All
  int _categoryIndex = 0; // default: All
  bool _favoritesOnly = false;
  bool _halalOnly = false;
  bool _kosherOnly = false;
  bool _suitableOnly = false;

  static const _ages = ['6m', '12m', '18m', '24m', 'All'];
  static const _categories = ['All', 'Purees', 'Finger Foods', 'Breakfast', 'Snacks'];

  @override
  void initState() {
    super.initState();
    HealthConditionService.instance.selectedListenable
        .addListener(_onConditionsChanged);
  }

  @override
  void dispose() {
    HealthConditionService.instance.selectedListenable
        .removeListener(_onConditionsChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onConditionsChanged() => setState(() {});

  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _isSearching = false;
        _searchController.clear();
        _searchText = '';
      } else {
        _isSearching = true;
      }
    });
  }

  int get _activeFilterCount {
    int count = 0;
    if (_ageIndex != 4) count++;
    if (_categoryIndex != 0) count++;
    if (_favoritesOnly) count++;
    if (_halalOnly) count++;
    if (_kosherOnly) count++;
    if (_suitableOnly) count++;
    count += HealthConditionService.instance.selected.length;
    return count;
  }

  List<Meal> get _filtered {
    final selectedAge = _ages[_ageIndex];
    final selectedCategory = _categories[_categoryIndex];
    final favoriteIds = FavoriteService.instance.favoriteMealIdsListenable.value;
    final conditions = HealthConditionService.instance.selected;

    return allMeals.where((m) {
      final ageOk = selectedAge == 'All' ||
          m.ageInMonths == _ageInMonths(selectedAge);
      final catOk = selectedCategory == 'All' || m.category == selectedCategory;
      final favoriteOk = !_favoritesOnly || favoriteIds.contains(m.id);
      final halalOk = !_halalOnly || m.isHalal;
      final kosherOk = !_kosherOnly || m.isKosher;
      final healthOk = !_suitableOnly ||
          conditions.isEmpty ||
          m.isSuitableForAll(conditions);
      final searchOk = _searchText.isEmpty ||
          m.name.toLowerCase().contains(_searchText.toLowerCase());
      return ageOk && catOk && favoriteOk && halalOk && kosherOk && healthOk && searchOk;
    }).toList();
  }

  int _ageInMonths(String age) {
    switch (age) {
      case '6m':
        return 6;
      case '12m':
        return 12;
      case '18m':
        return 18;
      case '24m':
        return 24;
      default:
        return 99;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFEAF4FF),
      endDrawer: FilterDrawer(
        ages: _ages,
        selectedAgeIndex: _ageIndex,
        categories: _categories,
        selectedCategoryIndex: _categoryIndex,
        onAgeChanged: (i) => setState(() => _ageIndex = i),
        onCategoryChanged: (i) => setState(() => _categoryIndex = i),
        favoritesOnly: _favoritesOnly,
        onFavoritesOnlyChanged: (value) =>
            setState(() => _favoritesOnly = value),
        halalOnly: _halalOnly,
        onHalalOnlyChanged: (value) => setState(() => _halalOnly = value),
        kosherOnly: _kosherOnly,
        onKosherOnlyChanged: (value) => setState(() => _kosherOnly = value),
        suitableOnly: _suitableOnly,
        onSuitableOnlyChanged: (value) =>
            setState(() => _suitableOnly = value),
        onReset: () => setState(() {
          _ageIndex = 4;
          _categoryIndex = 0;
          _favoritesOnly = false;
          _halalOnly = false;
          _kosherOnly = false;
          _suitableOnly = false;
        }),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MenuHeader(
              isSearching: _isSearching,
              searchController: _searchController,
              onSearchToggle: _toggleSearch,
              onSearchChanged: (v) => setState(() => _searchText = v),
              onFilterTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              activeFilterCount: _activeFilterCount,
            ),
            Expanded(
              child: ValueListenableBuilder<Set<String>>(
                valueListenable: FavoriteService.instance.favoriteMealIdsListenable,
                builder: (_, _, _) {
                  final filteredMeals = _filtered;
                  return filteredMeals.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          itemCount: filteredMeals.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (_, i) =>
                              MealCardItem(meal: filteredMeals[i]),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: AppColors.blueSoft),
          const SizedBox(height: 12),
          Text(
            'No meals found',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.blueMid,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: AppColors.placeholder,
            ),
          ),
        ],
      ),
    );
  }
}

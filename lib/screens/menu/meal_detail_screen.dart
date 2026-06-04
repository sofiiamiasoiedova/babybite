import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/meal.dart';
import '../../services/cart_service.dart';
import '../../services/favorite_service.dart';
import '../../services/health_condition_service.dart';
import '../../models/health_condition.dart';

class MealDetailScreen extends StatefulWidget {
  final Meal meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  int _quantity = 1;

  void _addToCart() {
    CartService.instance.addMeal(widget.meal, _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.meal.name} added to cart!',
          style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5AA3E8),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, meal),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHero(meal),
                    _buildBadgesRow(meal),
                    if (meal.isHalal || meal.isKosher)
                      _buildDietaryBadgesRow(meal),
                    if (meal.healthTagLabels.isNotEmpty)
                      _buildHealthTagsRow(meal),
                    _buildInfoCard(meal),
                    _buildNutritionCard(meal),
                    if (meal.isHalal || meal.isKosher)
                      _buildDietaryCard(meal),
                    _buildHealthSuitabilityCard(meal),
                    _buildAllergenCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomBar(meal),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // HEADER
  // ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Meal meal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          _circleBtn(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Meal Details',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3A5F),
              ),
            ),
          ),
          ValueListenableBuilder<Set<String>>(
            valueListenable: FavoriteService.instance.favoriteMealIdsListenable,
            builder: (_, favoriteIds, _) {
              final isFavorite = favoriteIds.contains(meal.id);
              return _circleBtn(
                icon: isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                iconColor:
                    isFavorite ? const Color(0xFFE86868) : const Color(0xFF5AA3E8),
                onTap: () => _toggleFavorite(meal, isFavorite),
              );
            },
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(Meal meal, bool isFavorite) {
    FavoriteService.instance.toggleFavorite(meal);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '${meal.name} removed from favorites'
              : '${meal.name} added to favorites',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: isFavorite
            ? const Color(0xFF8FA8BF)
            : const Color(0xFFE86868),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF5AA3E8),
  }) {
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
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // HERO
  // ────────────────────────────────────────────────────────
  Widget _buildHero(Meal meal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              meal.imagePath,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF1E3A5F).withValues(alpha: .55),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .92),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      size: 15, color: Color(0xFFF5B638)),
                  const SizedBox(width: 4),
                  Text(
                    meal.rating.toString(),
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                  Text(
                    ' (${meal.reviews})',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: const Color(0xFF9EBAD4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 16,
            right: 16,
            child: Text(
              meal.name,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  const Shadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // BADGES ROW – age, category, stage
  // ────────────────────────────────────────────────────────
  Widget _buildBadgesRow(Meal meal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          _badge(meal.age, const Color(0xFF5AA3E8), const Color(0xFFDCEEFB)),
          const SizedBox(width: 8),
          _badge(meal.category, const Color(0xFF7AC96A),
              const Color(0xFFE4F8DF)),
          const SizedBox(width: 8),
          _badge(meal.stage, const Color(0xFFE8934A),
              const Color(0xFFFFF0E6)),
        ],
      ),
    );
  }

  Widget _badge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // DIETARY BADGES ROW – Halal / Kosher
  // ────────────────────────────────────────────────────────
  Widget _buildDietaryBadgesRow(Meal meal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          if (meal.isHalal) ...[
            _dietaryBadge(
              label: 'Halal',
              icon: Icons.mosque_rounded,
              textColor: const Color(0xFF2E8B57),
              bgColor: const Color(0xFFDFF5EA),
            ),
            const SizedBox(width: 8),
          ],
          if (meal.isKosher)
            _dietaryBadge(
              label: 'Kosher',
              icon: Icons.hexagon_outlined,
              textColor: const Color(0xFF5B4FCF),
              bgColor: const Color(0xFFEDE9FF),
            ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // HEALTH TAGS ROW
  // ────────────────────────────────────────────────────────
  Widget _buildHealthTagsRow(Meal meal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: meal.healthTagLabels.map((tag) {
          final style = _healthTagStyle(tag);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: style.bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: style.color,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  ({Color color, Color bgColor}) _healthTagStyle(String label) {
    switch (label) {
      case 'Low Sugar':
        return (color: const Color(0xFF059669), bgColor: const Color(0xFFD1FAE5));
      case 'Low GI':
        return (color: const Color(0xFF2563EB), bgColor: const Color(0xFFDBEAFE));
      case 'Anti-inflammatory':
        return (color: const Color(0xFF7C3AED), bgColor: const Color(0xFFEDE9FE));
      case 'No Dairy':
        return (color: const Color(0xFFD97706), bgColor: const Color(0xFFFEF3C7));
      default:
        return (color: const Color(0xFF5AA3E8), bgColor: const Color(0xFFDBEAFE));
    }
  }

  Widget _dietaryBadge({
    required String label,
    required IconData icon,
    required Color textColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // DIETARY CARD – Halal / Kosher suitability note
  // ────────────────────────────────────────────────────────
  Widget _buildDietaryCard(Meal meal) {
    final labels = <({String title, String note, Color color, IconData icon})>[];
    if (meal.isHalal) {
      labels.add((
        title: 'Halal',
        note: 'Suitable for Muslim dietary requirements',
        color: const Color(0xFF2E8B57),
        icon: Icons.mosque_rounded,
      ));
    }
    if (meal.isKosher) {
      labels.add((
        title: 'Kosher',
        note: 'Suitable for Jewish dietary laws',
        color: const Color(0xFF5B4FCF),
        icon: Icons.hexagon_outlined,
      ));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dietary Suitability',
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 12),
            ...labels.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: e.color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(e.icon, color: e.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: e.color,
                        ),
                      ),
                      Text(
                        e.note,
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          color: const Color(0xFF9EBAD4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // HEALTH SUITABILITY CARD
  // ────────────────────────────────────────────────────────
  Widget _buildHealthSuitabilityCard(Meal meal) {
    return ValueListenableBuilder<Set<HealthCondition>>(
      valueListenable: HealthConditionService.instance.selectedListenable,
      builder: (_, conditions, _) {
        final tags = meal.healthTagLabels;
        final hasContent = conditions.isNotEmpty || tags.isNotEmpty;
        if (!hasContent) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.health_and_safety_rounded,
                        size: 18, color: Color(0xFF5AA3E8)),
                    const SizedBox(width: 8),
                    Text(
                      'Health Suitability',
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ),
                  ],
                ),
                if (conditions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...conditions.map((condition) {
                    final suitable = meal.isSuitableFor(condition);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: condition.color.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(condition.icon,
                                color: condition.color, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      condition.displayName,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: condition.color,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
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
                                            size: 10,
                                            color: suitable
                                                ? const Color(0xFF43A047)
                                                : const Color(0xFFD97706),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            suitable ? 'Suitable' : 'Check',
                                            style: GoogleFonts.quicksand(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: suitable
                                                  ? const Color(0xFF2E7D32)
                                                  : const Color(0xFF92400E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  meal.suitabilityNote(condition),
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    color: const Color(0xFF9EBAD4),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ] else ...[
                  const SizedBox(height: 10),
                  Text(
                    'Select health conditions in your profile to see personalised meal guidance here.',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: const Color(0xFF9EBAD4),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
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

  // ────────────────────────────────────────────────────────
  // INFO CARD – stats chips
  // ────────────────────────────────────────────────────────
  Widget _buildInfoCard(Meal meal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statChip(Icons.local_fire_department_rounded,
                '${meal.calories} kcal', 'Calories'),
            _divider(),
            _statChip(
                Icons.timer_rounded, '${meal.cookTime} min', 'Cook time'),
            _divider(),
            _statChip(Icons.child_care_rounded, meal.age, 'Age'),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF5AA3E8), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E3A5F),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 11,
            color: const Color(0xFF9EBAD4),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 40,
      width: 1,
      color: const Color(0xFFD4E8F8),
    );
  }

  // ────────────────────────────────────────────────────────
  // NUTRITION CARD
  // ────────────────────────────────────────────────────────
  Widget _buildNutritionCard(Meal meal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Info',
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 12),
            _nutritionRow('Calories per serving', '${meal.calories} kcal'),
            const SizedBox(height: 8),
            _nutritionRow('Cook time', '${meal.cookTime} min'),
            const SizedBox(height: 8),
            _nutritionRow('Development stage', meal.stage),
          ],
        ),
      ),
    );
  }

  Widget _nutritionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            color: const Color(0xFF9EBAD4),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3A5F),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────
  // ALLERGEN CARD
  // ────────────────────────────────────────────────────────
  Widget _buildAllergenCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE4F8DF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF7AC96A), size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allergens',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: const Color(0xFF9EBAD4),
                  ),
                ),
                Text(
                  'None identified',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7AC96A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // BOTTOM BAR
  // ────────────────────────────────────────────────────────
  Widget _buildBottomBar(Meal meal) {
    final totalPrice = meal.price * _quantity;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF89B8E3).withValues(alpha: .15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _stepperBtn(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    '$_quantity',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                _stepperBtn(
                  icon: Icons.add_rounded,
                  onTap: () => setState(() => _quantity++),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: _addToCart,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7BB8E8), Color(0xFF5AA3E8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5AA3E8).withValues(alpha: .4),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Add to Cart  •  €${totalPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF89B8E3).withValues(alpha: .2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF5AA3E8)),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF89B8E3).withValues(alpha: .12),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

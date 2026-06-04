import 'package:flutter/foundation.dart';
import '../screens/menu/models/meal.dart';

class FavoriteService {
  FavoriteService._();

  static final FavoriteService instance = FavoriteService._();

  final ValueNotifier<Set<String>> _favoriteMealIds =
      ValueNotifier<Set<String>>(<String>{});

  ValueListenable<Set<String>> get favoriteMealIdsListenable => _favoriteMealIds;

  bool isFavorite(Meal meal) => _favoriteMealIds.value.contains(meal.id);

  void toggleFavorite(Meal meal) {
    final updated = Set<String>.from(_favoriteMealIds.value);
    if (updated.contains(meal.id)) {
      updated.remove(meal.id);
    } else {
      updated.add(meal.id);
    }
    _favoriteMealIds.value = updated;
  }
}

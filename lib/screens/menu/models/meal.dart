import '../../../models/health_condition.dart';

class Meal {
  final String id;
  final String name;
  final String emoji;
  final String age; // '6m', '12m', '18m', '24m'
  final String category; // 'Purees', 'Finger Foods', 'Breakfast', 'Snacks'
  final int calories;
  final int cookTime;
  final String stage;
  final double rating;
  final int reviews;
  final String imagePath;
  final double price;
  final bool isHalal;
  final bool isKosher;
  // Health tags
  final bool isLowSugar;
  final bool isLowGlycemicIndex;
  final bool isAntiInflammatory;
  final bool noDairy;
  final bool noCommonAllergens;

  const Meal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.age,
    required this.category,
    required this.calories,
    required this.cookTime,
    required this.stage,
    required this.rating,
    required this.reviews,
    required this.imagePath,
    required this.price,
    this.isHalal = false,
    this.isKosher = false,
    this.isLowSugar = false,
    this.isLowGlycemicIndex = false,
    this.isAntiInflammatory = false,
    this.noDairy = false,
    this.noCommonAllergens = false,
  });

  String displayAge({bool inMonths = true}) {
    if (inMonths) return age;
    switch (age) {
      case '12m':
        return '1 yr';
      case '18m':
        return '1.5 yr';
      case '24m':
        return '2 yr';
      default:
        return age; // 6m stays as months since < 1 year
    }
  }

  int get ageInMonths {
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
        return 0;
    }
  }

  List<String> get healthTagLabels {
    return [
      if (isLowSugar) 'Low Sugar',
      if (isLowGlycemicIndex) 'Low GI',
      if (isAntiInflammatory) 'Anti-inflammatory',
      if (noDairy) 'No Dairy',
    ];
  }

  bool isSuitableFor(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.diabetes:
        return isLowSugar && isLowGlycemicIndex;
      case HealthCondition.psoriasis:
        return isAntiInflammatory;
      case HealthCondition.lactoseIntolerance:
        return noDairy;
      case HealthCondition.allergies:
        return noCommonAllergens;
    }
  }

  bool isSuitableForAll(Set<HealthCondition> conditions) {
    if (conditions.isEmpty) return true;
    return conditions.every(isSuitableFor);
  }

  String suitabilityNote(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.diabetes:
        return isLowSugar && isLowGlycemicIndex
            ? 'Low in sugar with slow-digesting carbohydrates, helping maintain stable blood sugar levels.'
            : 'This meal may contain higher sugar or fast-digesting carbs. Consider offering in moderation.';
      case HealthCondition.psoriasis:
        return isAntiInflammatory
            ? 'Contains anti-inflammatory ingredients that may help support healthy skin.'
            : 'Limited anti-inflammatory properties. Best offered alongside other skin-friendly foods.';
      case HealthCondition.lactoseIntolerance:
        return noDairy
            ? 'Completely dairy-free and safe for children with lactose intolerance.'
            : 'Contains dairy products. Not suitable for children with lactose intolerance.';
      case HealthCondition.allergies:
        return noCommonAllergens
            ? 'Free from common allergens including dairy, gluten, and shellfish.'
            : 'May contain common allergens. Please check all ingredients carefully before serving.';
    }
  }
}

import 'package:flutter/material.dart';

enum HealthCondition {
  diabetes,
  psoriasis,
  allergies,
  lactoseIntolerance,
}

extension HealthConditionX on HealthCondition {
  String get displayName {
    switch (this) {
      case HealthCondition.diabetes:
        return 'Diabetes';
      case HealthCondition.psoriasis:
        return 'Psoriasis';
      case HealthCondition.allergies:
        return 'Allergies';
      case HealthCondition.lactoseIntolerance:
        return 'Lactose Intolerance';
    }
  }

  String get description {
    switch (this) {
      case HealthCondition.diabetes:
        return 'Low sugar & low glycemic meals';
      case HealthCondition.psoriasis:
        return 'Anti-inflammatory meals';
      case HealthCondition.allergies:
        return 'Free from common allergens';
      case HealthCondition.lactoseIntolerance:
        return 'Dairy-free meals only';
    }
  }

  IconData get icon {
    switch (this) {
      case HealthCondition.diabetes:
        return Icons.water_drop_outlined;
      case HealthCondition.psoriasis:
        return Icons.spa_outlined;
      case HealthCondition.allergies:
        return Icons.warning_amber_rounded;
      case HealthCondition.lactoseIntolerance:
        return Icons.no_drinks_outlined;
    }
  }

  Color get color {
    switch (this) {
      case HealthCondition.diabetes:
        return const Color(0xFF2563EB);
      case HealthCondition.psoriasis:
        return const Color(0xFF7C3AED);
      case HealthCondition.allergies:
        return const Color(0xFFD97706);
      case HealthCondition.lactoseIntolerance:
        return const Color(0xFF059669);
    }
  }

  Color get bgColor {
    switch (this) {
      case HealthCondition.diabetes:
        return const Color(0xFFDBEAFE);
      case HealthCondition.psoriasis:
        return const Color(0xFFEDE9FE);
      case HealthCondition.allergies:
        return const Color(0xFFFEF3C7);
      case HealthCondition.lactoseIntolerance:
        return const Color(0xFFD1FAE5);
    }
  }
}

import 'package:flutter/foundation.dart';
import '../screens/profile/models/baby_info.dart';

class BabyAgeService {
  static final instance = BabyAgeService._();
  BabyAgeService._();

  BabyInfo? _babyInfo;
  final ValueNotifier<int?> ageMonthsListenable = ValueNotifier(null);
  final ValueNotifier<String?> nameListenable = ValueNotifier(null);
  final ValueNotifier<bool> showAgeInMonthsListenable = ValueNotifier(true);

  BabyInfo? get babyInfo => _babyInfo;
  int? get ageMonths => ageMonthsListenable.value;
  String? get babyName => nameListenable.value;
  bool get showAgeInMonths => showAgeInMonthsListenable.value;

  void update(BabyInfo baby) {
    _babyInfo = baby;
    ageMonthsListenable.value = baby.totalMonths;
    nameListenable.value = baby.name;
  }

  // Maps baby's age to the closest meal filter group
  String? get suggestedAgeGroup {
    final m = ageMonths;
    if (m == null) return null;
    if (m < 12) return '6m';
    if (m < 18) return '12m';
    if (m < 24) return '18m';
    return '24m';
  }
}

import 'package:flutter/foundation.dart';
import '../models/health_condition.dart';

class HealthConditionService {
  static final HealthConditionService instance = HealthConditionService._();
  HealthConditionService._()
      : _selected = ValueNotifier<Set<HealthCondition>>({});

  final ValueNotifier<Set<HealthCondition>> _selected;

  ValueListenable<Set<HealthCondition>> get selectedListenable => _selected;
  Set<HealthCondition> get selected => _selected.value;

  bool isSelected(HealthCondition condition) =>
      _selected.value.contains(condition);

  void toggle(HealthCondition condition) {
    final updated = Set<HealthCondition>.from(_selected.value);
    if (updated.contains(condition)) {
      updated.remove(condition);
    } else {
      updated.add(condition);
    }
    _selected.value = updated;
  }

  void clearAll() => _selected.value = {};
}

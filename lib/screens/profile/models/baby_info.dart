class BabyInfo {
  final String name;
  final DateTime? birthDate;
  final String allergies;
  final String weight;

  const BabyInfo({
    required this.name,
    this.birthDate,
    required this.allergies,
    required this.weight,
  });

  int? get totalMonths {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int months = (now.year - birthDate!.year) * 12 + (now.month - birthDate!.month);
    if (now.day < birthDate!.day) months--;
    return months < 0 ? 0 : months;
  }

  String get ageAsMonths {
    final m = totalMonths;
    if (m == null) return '—';
    if (m < 1) {
      final days = DateTime.now().difference(birthDate!).inDays;
      return '$days days old';
    }
    return '$m months old';
  }

  String get ageAsYears {
    final m = totalMonths;
    if (m == null) return '—';
    if (m < 12) return ageAsMonths;
    final years = m ~/ 12;
    final rem = m % 12;
    if (rem == 0) return '$years year${years > 1 ? 's' : ''} old';
    return '$years year${years > 1 ? 's' : ''} $rem month${rem > 1 ? 's' : ''} old';
  }

  /// Tính tuổi từ ngày sinh, trả về chuỗi hiển thị.
  String get age {
    if (birthDate == null) return '—';
    final now = DateTime.now();
    final days = now.difference(birthDate!).inDays;

    if (days < 30) return '$days days old';

    int months = (now.year - birthDate!.year) * 12 +
        (now.month - birthDate!.month);
    if (now.day < birthDate!.day) months--;

    if (months < 24) return '$months months old';

    final years = months ~/ 12;
    final remMonths = months % 12;
    if (remMonths == 0) return '$years years old';
    return '$years years $remMonths months old';
  }

  BabyInfo copyWith({
    String? name,
    DateTime? birthDate,
    bool clearBirthDate = false,
    String? allergies,
    String? weight,
  }) {
    return BabyInfo(
      name: name ?? this.name,
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      allergies: allergies ?? this.allergies,
      weight: weight ?? this.weight,
    );
  }
}

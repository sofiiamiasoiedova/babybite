class DeliveryTime {
  final bool isAsap;
  final DateTime? scheduledDate;
  final String? scheduledSlot;

  const DeliveryTime({
    required this.isAsap,
    this.scheduledDate,
    this.scheduledSlot,
  });

  String get displayLabel {
    if (isAsap) return 'As soon as possible (est. 25–40 min)';
    if (scheduledDate != null && scheduledSlot != null) {
      return '${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}  $scheduledSlot';
    }
    return 'Scheduled';
  }
}

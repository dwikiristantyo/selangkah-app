class MemorialSchedule {
  const MemorialSchedule({
    required this.id,
    required this.deceasedId,
    required this.eventName,
    required this.targetDate,
    required this.reminderSent,
  });

  final String id;
  final String deceasedId;
  final String eventName;
  final DateTime targetDate;
  final bool reminderSent;

  factory MemorialSchedule.fromMap(Map<String, dynamic> map) {
    return MemorialSchedule(
      id: map['id'] as String,
      deceasedId: map['deceased_id'] as String,
      eventName: map['event_name'] as String,
      targetDate: DateTime.parse(map['target_date'] as String),
      reminderSent: map['reminder_sent'] as bool? ?? false,
    );
  }
}

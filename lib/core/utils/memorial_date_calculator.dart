enum MemorialEvent {
  oneDay('1 Hari', 1),
  threeDays('3 Hari', 3),
  sevenDays('7 Hari', 7),
  fortyDays('40 Hari', 40),
  oneHundredDays('100 Hari', 100),
  firstHaul('Haul 1', null);

  const MemorialEvent(this.label, this.dayOffset);

  final String label;
  final int? dayOffset;
}

class MemorialDate {
  const MemorialDate({required this.event, required this.date});

  final MemorialEvent event;
  final DateTime date;
}

abstract final class MemorialDateCalculator {
  static List<MemorialDate> calculate(DateTime deathDate) {
    final date = DateTime(deathDate.year, deathDate.month, deathDate.day);
    return MemorialEvent.values
        .map(
          (event) => MemorialDate(
            event: event,
            date: event.dayOffset == null
                ? _firstHaul(date)
                : date.add(Duration(days: event.dayOffset!)),
          ),
        )
        .toList(growable: false);
  }

  static DateTime _firstHaul(DateTime deathDate) {
    final nextYear = deathDate.year + 1;
    final lastDayOfMonth = DateTime(nextYear, deathDate.month + 1, 0).day;
    return DateTime(
      nextYear,
      deathDate.month,
      deathDate.day.clamp(1, lastDayOfMonth).toInt(),
    );
  }
}

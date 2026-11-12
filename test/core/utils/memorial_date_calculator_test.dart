import 'package:flutter_test/flutter_test.dart';
import 'package:selangkah/core/utils/memorial_date_calculator.dart';

void main() {
  group('MemorialDateCalculator', () {
    test('calculates requested day-count dates and first haul', () {
      final dates = MemorialDateCalculator.calculate(DateTime(2024, 1, 10));

      expect(dates.map((item) => item.date), [
        DateTime(2024, 1, 11),
        DateTime(2024, 1, 13),
        DateTime(2024, 1, 17),
        DateTime(2024, 2, 19),
        DateTime(2024, 4, 19),
        DateTime(2025, 1, 10),
      ]);
    });

    test('clamps a leap-day haul to the last valid day of February', () {
      final dates = MemorialDateCalculator.calculate(DateTime(2024, 2, 29));

      expect(dates.last.date, DateTime(2025, 2, 28));
    });
  });
}

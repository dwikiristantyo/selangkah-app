import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:selangkah/core/utils/app_date_formatter.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id'));

  test('formats Umm al-Qura dates with Indonesian Hijri month names', () {
    expect(
      AppDateFormatter.hijri(DateTime(2024, 3, 11)),
      '1 Ramadan 1445 H',
    );
  });

  test('shows both Gregorian and Hijri dates', () {
    final label = AppDateFormatter.dual(DateTime(2024, 3, 11));

    expect(label, contains('11 Maret 2024 M'));
    expect(label, contains('1 Ramadan 1445 H'));
  });
}

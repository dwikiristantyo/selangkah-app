import 'package:hijri_core/hijri_core.dart';
import 'package:intl/intl.dart';

abstract final class AppDateFormatter {
  static const _hijriMonths = [
    'Muharam',
    'Safar',
    'Rabiulawal',
    'Rabiulakhir',
    'Jumadilawal',
    'Jumadilakhir',
    'Rajab',
    'Syakban',
    'Ramadan',
    'Syawal',
    'Zulkaidah',
    'Zulhijah',
  ];

  static String dual(DateTime date, {bool abbreviated = false}) {
    final formatter =
        abbreviated ? DateFormat.yMMMd('id') : DateFormat.yMMMMd('id');
    return '${formatter.format(date)} M • ${hijri(date)}';
  }

  static String hijri(DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day);
    final converted = toHijri(day) ??
        toHijri(
          day,
          options: const ConversionOptions(calendar: 'fcna'),
        );
    if (converted == null) return 'Tanggal Hijriah tidak tersedia';

    return '${converted.hd} ${_hijriMonths[converted.hm - 1]} '
        '${converted.hy} H';
  }
}

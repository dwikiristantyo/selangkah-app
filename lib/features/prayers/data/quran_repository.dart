import 'dart:convert';

import 'package:http/http.dart' as http;

class QuranPassage {
  const QuranPassage({
    required this.title,
    required this.description,
    required this.chapter,
    this.verse,
    this.verseCount,
  });

  final String title;
  final String description;
  final int chapter;
  final int? verse;
  final int? verseCount;
}

class QuranVerse {
  const QuranVerse({
    required this.verseKey,
    required this.verseNumber,
    required this.arabic,
    required this.transliteration,
    required this.translation,
  });

  final String verseKey;
  final int verseNumber;
  final String arabic;
  final String transliteration;
  final String translation;

  factory QuranVerse.fromMap(Map<String, dynamic> map) {
    final words = (map['words'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .where((word) => word['char_type_name'] == 'word')
        .map((word) {
          final item = word['transliteration'] as Map<String, dynamic>?;
          return item?['text'] as String?;
        })
        .whereType<String>()
        .where((text) => text.isNotEmpty)
        .toList(growable: false);
    final translations = (map['translations'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();

    return QuranVerse(
      verseKey: map['verse_key'] as String,
      verseNumber: map['verse_number'] as int,
      arabic: (map['text_uthmani'] as String).trim(),
      transliteration: words.join(' '),
      translation: translations.isEmpty
          ? ''
          : _plainText(translations.first['text'] as String),
    );
  }

  static String _plainText(String value) => value
      .replaceAll(
        RegExp(r'<sup\b[^>]*>.*?</sup>', caseSensitive: false, dotAll: true),
        '',
      )
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
}

class QuranRepository {
  static final Map<String, List<QuranVerse>> _cache = {};

  Future<List<QuranVerse>> load(QuranPassage passage) async {
    final key =
        '${passage.chapter}:${passage.verse ?? 0}:${passage.verseCount ?? 0}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final path = passage.verse == null
        ? '/api/v4/verses/by_chapter/${passage.chapter}'
        : '/api/v4/verses/by_key/${passage.chapter}:${passage.verse}';
    final queryParameters = <String, String>{
      'language': 'id',
      'fields': 'text_uthmani',
      'words': 'true',
      'word_fields': 'transliteration',
      'translations': '33',
      'per_page': '${passage.verseCount ?? 300}',
    };
    final response = await http.get(
      Uri.https('api.quran.com', path, queryParameters),
      headers: const {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Layanan teks Al-Qur’an merespons '
          'HTTP ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final rawVerses = passage.verse == null
        ? decoded['verses'] as List<dynamic>
        : [decoded['verse']];
    final verses = rawVerses
        .whereType<Map<String, dynamic>>()
        .map(QuranVerse.fromMap)
        .toList(growable: false);
    if (verses.isEmpty) {
      throw const FormatException('Layanan tidak mengembalikan ayat.');
    }

    _cache[key] = verses;
    return verses;
  }
}

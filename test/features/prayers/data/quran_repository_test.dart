import 'package:flutter_test/flutter_test.dart';
import 'package:selangkah/features/prayers/data/quran_repository.dart';

void main() {
  test('maps Arabic, transliteration, and Indonesian translation', () {
    final verse = QuranVerse.fromMap({
      'verse_key': '3:185',
      'verse_number': 185,
      'text_uthmani': 'كُلُّ نَفْسٍ ذَآئِقَةُ ٱلْمَوْتِ',
      'words': [
        {
          'char_type_name': 'word',
          'transliteration': {'text': 'kullu'},
        },
        {
          'char_type_name': 'word',
          'transliteration': {'text': 'nafsin'},
        },
        {
          'char_type_name': 'end',
          'transliteration': {'text': null},
        },
      ],
      'translations': [
        {
          'text': 'Setiap yang bernyawa akan merasakan mati.'
              '<sup foot_note=1>1</sup>',
        },
      ],
    });

    expect(verse.verseKey, '3:185');
    expect(verse.arabic, 'كُلُّ نَفْسٍ ذَآئِقَةُ ٱلْمَوْتِ');
    expect(verse.transliteration, 'kullu nafsin');
    expect(verse.translation, 'Setiap yang bernyawa akan merasakan mati.');
  });
}

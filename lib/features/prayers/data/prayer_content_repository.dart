import '../../../core/services/supabase_service.dart';

class PrayerContent {
  const PrayerContent({
    required this.category,
    required this.title,
    required this.arabicText,
    required this.latinText,
    required this.translation,
    required this.sequenceOrder,
  });

  final String category;
  final String title;
  final String arabicText;
  final String latinText;
  final String translation;
  final int sequenceOrder;

  factory PrayerContent.fromMap(Map<String, dynamic> map) => PrayerContent(
        category: map['category'] as String,
        title: map['title'] as String,
        arabicText: map['arabic_text'] as String,
        latinText: map['latin_text'] as String,
        translation: map['translation'] as String,
        sequenceOrder: map['sequence_order'] as int,
      );
}

class PrayerContentRepository {
  Future<List<PrayerContent>> load() async {
    final response = await SupabaseService.client
        .from('prayers_content')
        .select(
          'category, title, arabic_text, latin_text, translation, sequence_order',
        )
        .order('sequence_order');
    return List<Map<String, dynamic>>.from(response)
        .map(PrayerContent.fromMap)
        .toList(growable: false);
  }
}

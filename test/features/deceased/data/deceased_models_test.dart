import 'package:flutter_test/flutter_test.dart';
import 'package:selangkah/features/deceased/data/deceased_models.dart';

void main() {
  test('maps a Supabase deceased profile and its photo rows', () {
    final profile = DeceasedProfile.fromMap({
      'id': 'profile-1',
      'name': 'Siti Aminah',
      'birth_date': '1940-03-02',
      'death_date': '2024-08-15',
      'quote': 'Selalu dalam doa.',
      'deceased_photos': [
        {
          'id': 'photo-1',
          'deceased_id': 'profile-1',
          'photo_url': 'profile-1/memories.jpg',
          'is_primary': true,
          'caption': null,
        },
      ],
    });

    expect(profile.id, 'profile-1');
    expect(profile.name, 'Siti Aminah');
    expect(profile.birthDate, DateTime(1940, 3, 2));
    expect(profile.deathDate, DateTime(2024, 8, 15));
    expect(profile.quote, 'Selalu dalam doa.');
    expect(profile.photos, hasLength(1));
    expect(profile.photos.single.storagePath, 'profile-1/memories.jpg');
    expect(profile.photos.single.isPrimary, isTrue);
  });

  test('accepts profiles without photo rows or a quote', () {
    final profile = DeceasedProfile.fromMap({
      'id': 'profile-2',
      'name': 'Ahmad',
      'birth_date': '1950-01-01',
      'death_date': '2020-01-01',
    });

    expect(profile.quote, isNull);
    expect(profile.photos, isEmpty);
  });
}

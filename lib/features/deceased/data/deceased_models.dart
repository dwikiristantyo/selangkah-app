class DeceasedPhoto {
  const DeceasedPhoto({
    required this.id,
    required this.deceasedId,
    required this.storagePath,
    required this.isPrimary,
    this.caption,
  });

  final String id;
  final String deceasedId;
  final String storagePath;
  final bool isPrimary;
  final String? caption;

  factory DeceasedPhoto.fromMap(Map<String, dynamic> map) {
    return DeceasedPhoto(
      id: map['id'] as String,
      deceasedId: map['deceased_id'] as String,
      storagePath: map['photo_url'] as String,
      isPrimary: map['is_primary'] as bool? ?? false,
      caption: map['caption'] as String?,
    );
  }
}

class DeceasedProfile {
  const DeceasedProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.deathDate,
    required this.photos,
    this.quote,
  });

  final String id;
  final String name;
  final DateTime birthDate;
  final DateTime deathDate;
  final String? quote;
  final List<DeceasedPhoto> photos;

  factory DeceasedProfile.fromMap(Map<String, dynamic> map) {
    final photoRows = map['deceased_photos'] as List<dynamic>? ?? const [];
    return DeceasedProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      birthDate: DateTime.parse(map['birth_date'] as String),
      deathDate: DateTime.parse(map['death_date'] as String),
      quote: map['quote'] as String?,
      photos: photoRows
          .map(
            (row) => DeceasedPhoto.fromMap(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}

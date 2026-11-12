import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import 'deceased_models.dart';

class DeceasedRepository {
  static const _bucket = 'memorial-photos';
  static const _profileSelection = '*, deceased_photos(*)';

  SupabaseClient get _client => SupabaseService.client;

  Future<List<DeceasedProfile>> getProfiles() async {
    final response = await _client
        .from('deceased_profiles')
        .select(_profileSelection)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response)
        .map(DeceasedProfile.fromMap)
        .toList(growable: false);
  }

  Future<DeceasedProfile> getProfile(String id) async {
    final response = await _client
        .from('deceased_profiles')
        .select(_profileSelection)
        .eq('id', id)
        .single();
    return DeceasedProfile.fromMap(response);
  }

  Future<DeceasedProfile> createProfile({
    required String name,
    required DateTime birthDate,
    required DateTime deathDate,
    String? quote,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Anda harus masuk untuk menambahkan profil.');
    }

    final response = await _client
        .from('deceased_profiles')
        .insert({
          'user_id': userId,
          'name': name.trim(),
          'birth_date': _formatDate(birthDate),
          'death_date': _formatDate(deathDate),
          'quote': _optionalText(quote),
        })
        .select(_profileSelection)
        .single();
    return DeceasedProfile.fromMap(response);
  }

  Future<DeceasedProfile> updateProfile({
    required String id,
    required String name,
    required DateTime birthDate,
    required DateTime deathDate,
    String? quote,
  }) async {
    final response = await _client
        .from('deceased_profiles')
        .update({
          'name': name.trim(),
          'birth_date': _formatDate(birthDate),
          'death_date': _formatDate(deathDate),
          'quote': _optionalText(quote),
        })
        .eq('id', id)
        .select(_profileSelection)
        .single();
    return DeceasedProfile.fromMap(response);
  }

  Future<void> deleteProfile(DeceasedProfile profile) async {
    final photoRows = await _client
        .from('deceased_photos')
        .select('photo_url')
        .eq('deceased_id', profile.id);
    final paths = List<Map<String, dynamic>>.from(photoRows)
        .map((row) => row['photo_url'] as String)
        .toList(growable: false);

    if (paths.isNotEmpty) {
      await _client.storage.from(_bucket).remove(paths);
    }
    await _client.from('deceased_profiles').delete().eq('id', profile.id);
  }

  Future<DeceasedPhoto> uploadPhoto({
    required String deceasedId,
    required XFile file,
    required bool isPrimary,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Anda harus masuk untuk mengunggah foto.');
    }

    final extension = _imageExtension(file.name);
    final path =
        '$userId/$deceasedId/${DateTime.now().microsecondsSinceEpoch}.$extension';
    await _client.storage.from(_bucket).uploadBinary(
          path,
          Uint8List.fromList(await file.readAsBytes()),
          fileOptions: FileOptions(
            contentType: file.mimeType ?? 'image/$extension',
            upsert: false,
          ),
        );

    try {
      final response = await _client
          .from('deceased_photos')
          .insert({
            'deceased_id': deceasedId,
            'photo_url': path,
            'is_primary': isPrimary,
          })
          .select()
          .single();
      return DeceasedPhoto.fromMap(response);
    } catch (error, stackTrace) {
      try {
        await _client.storage.from(_bucket).remove([path]);
      } catch (cleanupError) {
        Error.throwWithStackTrace(
          StateError(
            'Foto gagal disimpan ($error) dan berkas Storage gagal dibersihkan '
            '($cleanupError).',
          ),
          stackTrace,
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> deletePhoto(DeceasedPhoto photo) async {
    await _client.storage.from(_bucket).remove([photo.storagePath]);
    await _client.from('deceased_photos').delete().eq('id', photo.id);

    if (photo.isPrimary) {
      final remaining = await _client
          .from('deceased_photos')
          .select('id')
          .eq('deceased_id', photo.deceasedId)
          .order('created_at')
          .limit(1);
      if (remaining.isNotEmpty) {
        await _client.from('deceased_photos').update({'is_primary': true}).eq(
            'id', remaining.first['id'] as String);
      }
    }
  }

  Future<String> getPhotoUrl(String storagePath) {
    return _client.storage.from(_bucket).createSignedUrl(storagePath, 3600);
  }

  static String _formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static String? _optionalText(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String _imageExtension(String fileName) {
    final extension =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    const supported = {'jpg', 'jpeg', 'png', 'webp', 'gif', 'heic', 'heif'};
    if (!supported.contains(extension)) {
      throw FormatException('Format foto .$extension tidak didukung.');
    }
    return extension;
  }
}

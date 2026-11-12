import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

class DeceasedRepository {
  SupabaseClient get _client => SupabaseService.client;

  Future<List<Map<String, dynamic>>> getProfiles() async {
    final response = await _client
        .from('deceased_profiles')
        .select('*, deceased_photos(*)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<String> uploadPhoto({
    required String deceasedId,
    required String fileName,
    required List<int> bytes,
  }) async {
    final path = '$deceasedId/$fileName';
    await _client.storage.from('memorial-photos').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(upsert: false),
        );
    return path;
  }

  Future<String> getPhotoUrl(String storagePath) {
    return _client.storage
        .from('memorial-photos')
        .createSignedUrl(storagePath, 3600);
  }
}

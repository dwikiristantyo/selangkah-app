import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_config.dart';

abstract final class SupabaseService {
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase is not configured. Provide SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY using --dart-define.',
      );
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

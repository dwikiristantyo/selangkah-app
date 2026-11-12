abstract final class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ercsvnbwneptosgrvlzd.supabase.co',
  );
  static const publishableKey =
      String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_Rx2ulk7_vMY3D4EhbyqzdQ_ZDUopwyK',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}

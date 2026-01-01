class SupabaseConfig {
  const SupabaseConfig._();

  static const url = '';
  static const anonKey = '';

  /// Deeplink used by Supabase OAuth callbacks.
  ///
  /// Make sure the scheme/host pair matches platform-specific configuration
  /// (Android intent filter, iOS URL type, etc.).
  static const authRedirectUri = 'us://login-callback';
}

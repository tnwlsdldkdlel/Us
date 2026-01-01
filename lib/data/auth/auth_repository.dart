import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../user/user_repository.dart';

class AuthRepository {
  AuthRepository({SupabaseClient? client, UserRepository? userRepository})
    : _client = client ?? Supabase.instance.client,
      _userRepository =
          userRepository ??
          UserRepository(client: client ?? Supabase.instance.client);

  final SupabaseClient _client;
  final UserRepository _userRepository;

  Future<void> signInWithGoogle() async {
    await _signInWithGoogleNative();
  }

  Future<void> signInWithApple() =>
      _signInWithProvider(OAuthProvider.apple, scopes: 'name email');

  Future<void> signOut() async {
    await _client.auth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore if google sign in was not used
    }
  }

  Future<void> ensureUserProfile(User user) async {
    await _userRepository.ensureUserProfile(user);
  }

  Future<void> _signInWithGoogleNative() async {
    // iOS Client ID provided by user
    const iosClientId =
        '375499564191-hf26n9atrnf4kjaoq897tltd9nuomllv.apps.googleusercontent.com';

    const webClientId =
        '375499564191-79rdiu5ufr6de1jl5t694n8fbjul5e1r.apps.googleusercontent.com';

    // Web Client ID (Supabase Project) - needed for the idToken to be valid for Supabase
    // We should ideally get this from config, but for now we'll let the user know if it's missing.
    // Actually, for Supabase Auth with Google, we usually need the Web Client ID as the 'serverClientId'
    // if we want to verify the token on the backend, but Supabase's signInWithIdToken handles it.
    // However, GoogleSignIn needs the iOS client ID to launch the consent screen on iOS.

    final scopes = ['email', 'profile'];
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      serverClientId: webClientId,
      clientId: iosClientId,
    );
    // final googleUser = await googleSignIn.attemptLightweightAuthentication();
    final googleUser = await googleSignIn.authenticate();
    // or await googleSignIn.authenticate(); which will return a GoogleSignInAccount or throw an exception
    // if (googleUser == null) {
    //   throw AuthException('Failed to sign in with Google.');
    // }

    /// Authorization is required to obtain the access token with the appropriate scopes for Supabase authentication,
    /// while also granting permission to access user information.
    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
        await googleUser.authorizationClient.authorizeScopes(scopes);
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw AuthException('No ID Token found.');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );
  }

  Future<void> _signInWithProvider(
    OAuthProvider provider, {
    String? scopes,
  }) async {
    await _client.auth.signInWithOAuth(
      provider,
      redirectTo: SupabaseConfig.authRedirectUri,
      scopes: scopes,
    );
  }
}

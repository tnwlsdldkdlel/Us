import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:us/data/auth/auth_repository.dart';
import 'package:us/screens/auth/login_screen.dart';
import 'package:us/screens/home/screens/home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthRepository _authRepository = AuthRepository();
  StreamSubscription<AuthState>? _authSubscription;
  Session? _session;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _listenAuthState();
    _bootstrapSession();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _listenAuthState() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      authState,
    ) async {
      final session = authState.session;

      if (authState.event == AuthChangeEvent.signedIn &&
          session?.user != null) {
        try {
          await _authRepository.ensureUserProfile(session!.user);
        } catch (error, stackTrace) {
          debugPrint('Failed to sync user profile: $error\n$stackTrace');
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _session = session;
        _loading = false;
        _error = null;
      });
    });
  }

  Future<void> _bootstrapSession() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session?.user != null) {
      try {
        await _authRepository.ensureUserProfile(session!.user);
      } catch (error, stackTrace) {
        debugPrint('Failed to bootstrap user profile: $error\n$stackTrace');
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _session = session;
      _loading = false;
      _error = null;
    });
  }

  Future<void> _retry() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _bootstrapSession();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _retry, child: const Text('다시 시도')),
              ],
            ),
          ),
        ),
      );
    }

    if (_session == null) {
      return const LoginScreen();
    }

    return HomeScreen();
  }
}

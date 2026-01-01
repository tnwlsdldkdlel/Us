import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:us/data/auth/auth_repository.dart';
import 'package:us/theme/us_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isProcessing = false;
  String? _error;

  Future<void> _handleSignIn(Future<void> Function() action) async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      await action();
    } on AuthException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = '로그인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.colorBackgroundDefault,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.spacingL),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Us에 오신 것을 환영합니다',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.spacingS),
                  Text(
                    '친구들과 약속을 만들고 공유하며 일정 관리를 시작해보세요.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.colorTextBody,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.spacingXl),
                  _ProviderSignInButton(
                    label: 'Google 계정으로 계속하기',
                    onPressed: _isProcessing
                        ? null
                        : () => _handleSignIn(_authRepository.signInWithGoogle),
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.colorTextBody,
                    icon: Icons.account_circle_outlined,
                  ),
                  const SizedBox(height: AppSpacing.spacingS),
                  _ProviderSignInButton(
                    label: 'Apple 계정으로 계속하기',
                    onPressed: _isProcessing
                        ? null
                        : () => _handleSignIn(_authRepository.signInWithApple),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    icon: Icons.apple,
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  if (_error != null)
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.colorError,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (_isProcessing) ...[
                    const SizedBox(height: AppSpacing.spacingM),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  const SizedBox(height: AppSpacing.spacingXl),
                  Text(
                    '계속 진행하면 개인정보 처리방침과 이용약관에 동의하는 것으로 간주됩니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.colorTextCaption,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderSignInButton extends StatelessWidget {
  const _ProviderSignInButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: foregroundColor),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
          ),
          side: BorderSide(
            color: AppColors.colorGray300.withValues(alpha: 0.5),
          ),
          elevation: 0,
        ),
        label: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:us/data/auth/auth_repository.dart';
import 'package:us/theme/us_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthRepository _authRepository = AuthRepository();
  bool _pushNotificationEnabled = true;
  bool _emailNotificationEnabled = true;
  bool _reminderEnabled = true;
  bool _isSigningOut = false;
  String? _signOutError;

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
      _signOutError = null;
    });

    try {
      await _authRepository.signOut();
    } on AuthException catch (error) {
      if (mounted) {
        setState(() {
          _signOutError = error.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _signOutError = '로그아웃 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor;
    final currentUser = Supabase.instance.client.auth.currentUser;
    final providerLabel = _resolveProviderLabel(currentUser);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileSection(
                dividerColor: dividerColor,
                user: currentUser,
                providerLabel: providerLabel,
              ),
              const SizedBox(height: AppSpacing.spacingL),
              const _SectionHeader(title: '알림 설정'),
              const SizedBox(height: AppSpacing.spacingS),
              _NotificationSection(
                pushEnabled: _pushNotificationEnabled,
                emailEnabled: _emailNotificationEnabled,
                reminderEnabled: _reminderEnabled,
                onChanged: (push, email, reminder) {
                  setState(() {
                    _pushNotificationEnabled = push;
                    _emailNotificationEnabled = email;
                    _reminderEnabled = reminder;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.spacingL),
              const _SectionHeader(title: '앱 정보'),
              const SizedBox(height: AppSpacing.spacingS),
              const _AppInfoSection(),
              const SizedBox(height: AppSpacing.spacingL),
              if (_signOutError != null) ...[
                Text(
                  _signOutError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.colorError,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingS),
              ],
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSigningOut ? null : _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppRadius.radiusMedium,
                      ),
                    ),
                  ),
                  child: _isSigningOut
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          '로그아웃',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveProviderLabel(User? user) {
    final provider = user?.appMetadata['provider'];
    if (provider is String && provider.isNotEmpty) {
      return provider.toUpperCase();
    }
    return '미확인';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.dividerColor,
    required this.user,
    required this.providerLabel,
  });

  final Color dividerColor;
  final User? user;
  final String providerLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = _resolveDisplayName();
    final email = user?.email ?? '-';
    final avatarUrl = _resolveAvatarUrl();
    final avatarFallback = displayName.isNotEmpty ? displayName[0] : 'U';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.colorPrimary500,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? Text(
                        avatarFallback,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.spacingM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName.isNotEmpty ? displayName : '이름 미설정',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingXxs),
                  Text(
                    '프로필 편집',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Divider(color: dividerColor),
          const SizedBox(height: AppSpacing.spacingM),
          _ReadonlyField(
            icon: Icons.mail_outline_rounded,
            label: '이메일 주소',
            value: email,
          ),
          const SizedBox(height: AppSpacing.spacingS),
          _ReadonlyField(
            icon: Icons.link,
            label: '연결된 계정',
            value: providerLabel,
          ),
        ],
      ),
    );
  }

  String _resolveDisplayName() {
    final metadata = user?.userMetadata ?? <String, dynamic>{};
    final possibleKeys = ['nickname', 'full_name', 'name'];
    for (final key in possibleKeys) {
      final value = metadata[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final email = user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return '';
  }

  String? _resolveAvatarUrl() {
    final metadata = user?.userMetadata ?? <String, dynamic>{};
    final possibleKeys = ['avatar_url', 'picture'];
    for (final key in possibleKeys) {
      final value = metadata[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.colorGray300),
        const SizedBox(width: AppSpacing.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.colorTextCaption,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingXxs),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.colorTextBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.reminderEnabled,
    required this.onChanged,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool reminderEnabled;
  final void Function(bool push, bool email, bool reminder) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _NotificationTile(
            title: '푸시 알림',
            subtitle: '앱에서 보내는 알림을 받아보세요',
            value: pushEnabled,
            onChanged: (value) =>
                onChanged(value, emailEnabled, reminderEnabled),
          ),
          const Divider(height: 1, color: AppColors.colorGray300),
          _NotificationTile(
            title: '이메일 알림',
            subtitle: '이메일을 통해 주요 소식을 전달받아요',
            value: emailEnabled,
            onChanged: (value) =>
                onChanged(pushEnabled, value, reminderEnabled),
          ),
          const Divider(height: 1, color: AppColors.colorGray300),
          _NotificationTile(
            title: '약속 리마인더',
            subtitle: '약속 시간 전에 알려드릴게요',
            value: reminderEnabled,
            onChanged: (value) => onChanged(pushEnabled, emailEnabled, value),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.colorPrimary500,
      activeTrackColor: AppColors.colorPrimary500.withValues(alpha: 0.2),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingXs,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _AppInfoSection extends StatelessWidget {
  const _AppInfoSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = AppColors.colorGray300.withValues(alpha: 0.8);

    Widget buildTile({
      required IconData icon,
      required String title,
      Widget? trailing,
      VoidCallback? onTap,
    }) {
      return ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
          vertical: AppSpacing.spacingXs,
        ),
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          buildTile(
            icon: Icons.help_outline_rounded,
            title: '도움말',
            onTap: () {},
          ),
          Divider(height: 1, color: dividerColor),
          buildTile(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보 처리방침',
            onTap: () {},
          ),
          Divider(height: 1, color: dividerColor),
          buildTile(
            icon: Icons.info_outline_rounded,
            title: '버전 정보',
            trailing: Text(
              'v1.2.X',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.colorTextCaption,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

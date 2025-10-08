import 'package:flutter/material.dart';

import 'package:us/theme/us_colors.dart';

class CommonConfirmDialog extends StatelessWidget {
  const CommonConfirmDialog({
    super.key,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.confirmColor,
    required this.cancelColor,
    required this.onConfirm,
    required this.onCancel,
  });

  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;
  final Color cancelColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  static Future<bool?> show(
    BuildContext context, {
    required String message,
    String confirmLabel = '확인',
    String cancelLabel = '취소',
    Color confirmColor = AppColors.colorPrimary500,
    Color cancelColor = AppColors.colorGray300,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => CommonConfirmDialog(
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
        onConfirm: onConfirm,
        onCancel: onCancel ?? () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spacingL,
          AppSpacing.spacingL,
          AppSpacing.spacingL,
          AppSpacing.spacingL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      onCancel();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: cancelColor,
                      foregroundColor: colorScheme.onSurface.withOpacity(0.8),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppRadius.radiusMedium,
                        ),
                      ),
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.spacingM,
                      ),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: AppSpacing.spacingS),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmColor,
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.spacingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppRadius.radiusMedium,
                        ),
                      ),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

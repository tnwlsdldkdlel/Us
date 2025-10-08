import 'package:flutter/material.dart';

import 'package:us/models/appointment.dart';
import 'package:us/theme/us_colors.dart';

class UpcomingAppointmentTile extends StatelessWidget {
  const UpcomingAppointmentTile({
    super.key,
    required this.appointment,
    this.onTap,
  });

  final UpcomingAppointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
          border: Border.all(color: theme.dividerColor),
        ),
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacingXs),
                    Row(
                      children: [
                        Icon(
                          Icons.place_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.spacingXxs),
                        Text(
                          appointment.location,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.72),
                          ),
                        ),
                      ],
                    ),
                    if (appointment.note != null) ...[
                      const SizedBox(height: AppSpacing.spacingXs),
                      Text(
                        appointment.note!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacingS,
                    vertical: AppSpacing.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
                  ),
                  child: Text(
                    appointment.remaining,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

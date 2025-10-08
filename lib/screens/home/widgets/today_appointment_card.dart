import 'package:flutter/material.dart';

import 'package:us/models/appointment.dart';
import 'package:us/theme/us_colors.dart';

import 'participant_avatars.dart';

class TodayAppointmentCard extends StatelessWidget {
  const TodayAppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  final Appointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: AppSpacing.spacingXs,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(
                    AppRadius.radiusMedium / 2,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.title,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.72),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.spacingS,
                            vertical: AppSpacing.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(
                              AppRadius.radiusMedium,
                            ),
                          ),
                          child: Text(
                            appointment.timeLabel,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.spacingM),
                    if ((appointment.description ?? '').isNotEmpty ||
                        appointment.participants.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              appointment.description ?? '',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.72,
                                    ),
                                  ),
                            ),
                          ),
                          if (appointment.participants.isNotEmpty) ...[
                            const SizedBox(width: AppSpacing.spacingS),
                            ParticipantAvatars(appointment.participants),
                          ],
                          const SizedBox(width: AppSpacing.spacingXs),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:us/theme/us_colors.dart';

class CreateInviteCard extends StatelessWidget {
  const CreateInviteCard({super.key, required this.onCreateAppointment});
  final VoidCallback onCreateAppointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [UsColors.primaryLight, UsColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: UsColors.primary.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '새로운 약속 시작하기',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacingXs),
                    Text(
                      '친구와 시간을 정하고 간편하게 초대하세요.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingM),
          SizedBox(
            width: 140,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                minimumSize: const Size(140, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.radiusMedium),
                ),
              ),
              onPressed: () {
                onCreateAppointment();
              },
              child: const Text(
                '약속 만들기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

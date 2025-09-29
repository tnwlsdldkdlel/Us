import 'package:flutter/material.dart';
import 'package:us/theme/us_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Removed to allow Expanded to work
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Ensures 'Us' text is centered in the Expanded space
            children: [
              Text(
                'Us',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: UsColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

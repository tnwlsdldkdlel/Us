import 'package:flutter/material.dart';
import 'package:us/theme/us_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
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
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

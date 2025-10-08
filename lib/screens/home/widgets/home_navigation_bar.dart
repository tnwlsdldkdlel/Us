import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:us/theme/us_colors.dart';

class HomeNavigationBar extends StatelessWidget {
  const HomeNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spacingM,
          AppSpacing.spacingXs,
          AppSpacing.spacingM,
          AppSpacing.spacingM,
        ),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingL),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_filled,
                label: '',
                isActive: currentIndex == 0,
                onTap: () => onItemSelected(0),
              ),
              _NavItem(
                icon: Icons.calendar_month_rounded,
                label: '',
                isActive: currentIndex == 1,
                onTap: () => onItemSelected(1),
              ),
              _NavItem(
                icon: Icons.group_outlined,
                label: '',
                isActive: currentIndex == 2,
                onTap: () => onItemSelected(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: '',
                isActive: currentIndex == 3,
                onTap: () => onItemSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isActive
        ? colorScheme.primary
        : colorScheme.onSurface.withOpacity(0.4);

    Widget content;
    if (label.isEmpty) {
      content = Icon(icon, color: color, size: 24);
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.spacingXs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(width: 56, height: 48, child: Center(child: content)),
    );
  }
}

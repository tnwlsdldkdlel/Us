import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
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
    final color = isActive ? UsColors.primary : Colors.grey[500];

    Widget content;
    if (label.isEmpty) {
      content = Icon(icon, color: color, size: 24);
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
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
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(width: 56, height: 40, child: Center(child: content)),
    );
  }
}

import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  const Section({
    super.key,
    this.title,
    this.icon,
    this.iconColor,
    this.trailing,
    required this.child,
  });

  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null || icon != null || trailing != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasHeader)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor ?? Colors.black87, size: 22),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        if (hasHeader) const SizedBox(height: 12),
        child,
      ],
    );
  }
}

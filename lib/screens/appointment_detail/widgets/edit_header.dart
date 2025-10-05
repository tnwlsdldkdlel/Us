import 'package:flutter/material.dart';

class AppointmentEditHeader extends StatelessWidget {
  const AppointmentEditHeader({
    super.key,
    required this.onBackRequested,
    required this.title,
    this.onSubmit,
  });

  final VoidCallback onBackRequested;
  final String title;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBackRequested,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          if (onSubmit != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onSubmit,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('완료'),
              ),
            ),
        ],
      ),
    );
  }
}

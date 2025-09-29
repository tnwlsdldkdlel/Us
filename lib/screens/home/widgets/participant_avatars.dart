import 'package:flutter/material.dart';

class ParticipantAvatars extends StatelessWidget {
  const ParticipantAvatars(this.initials, {super.key});

  final List<String> initials;

  @override
  Widget build(BuildContext context) {
    if (initials.isEmpty) {
      return const SizedBox.shrink();
    }

    const double diameter = 32;
    const double overlap = 12;
    final int count = initials.length;
    final double width = diameter + (count - 1) * (diameter - overlap);

    return SizedBox(
      height: diameter,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              left: i * (diameter - overlap),
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials[i],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

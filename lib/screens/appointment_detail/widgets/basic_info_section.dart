import 'package:flutter/material.dart';

import 'package:us/theme/us_colors.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    super.key,
    required this.titleController,
    required this.locationController,
    required this.noteController,
    required this.onLocationTap,
    required this.onLocationClear,
    required this.selectedDate,
    required this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  final TextEditingController titleController;
  final TextEditingController locationController;
  final TextEditingController noteController;
  final VoidCallback onLocationTap;
  final VoidCallback onLocationClear;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${selectedDate.year}.${selectedDate.month}.${selectedDate.day}';
    final timePeriod = selectedTime.period == DayPeriod.am ? '오전' : '오후';
    final hour = selectedTime.hourOfPeriod == 0
        ? 12
        : selectedTime.hourOfPeriod;
    final minute = selectedTime.minute.toString().padLeft(2, '0');
    final timeLabel = '$timePeriod $hour:$minute';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(text: '제목'),
        const SizedBox(height: 8),
        _FilledField(
          controller: titleController,
          hintText: '제목을 입력하세요',
          onClear: () => titleController.clear(),
        ),
        const SizedBox(height: 20),
        const _FieldLabel(text: '장소'),
        const SizedBox(height: 8),
        _FilledField(
          controller: locationController,
          hintText: '장소를 입력하세요',
          readOnly: true,
          onTap: onLocationTap,
          onClear: onLocationClear,
        ),
        const SizedBox(height: 24),
        const _FieldLabel(text: '시작일'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ChipButton(
                label: dateLabel,
                foregroundColor: UsColors.primary,
                onTap: onSelectDate,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ChipButton(
                label: timeLabel,
                foregroundColor: UsColors.primary,
                onTap: onSelectTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _FieldLabel(text: '설명'),
        const SizedBox(height: 8),
        _MultiLineField(
          controller: noteController,
          hintText: '추가로 공유하고 싶은 내용을 적어주세요',
          onClear: () => noteController.clear(),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
      ),
    );
  }
}

class _FilledField extends StatelessWidget {
  const _FilledField({
    required this.controller,
    required this.hintText,
    required this.onClear,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onClear;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: readOnly,
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF4B5563),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.onTap,
    required this.foregroundColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MultiLineField extends StatelessWidget {
  const _MultiLineField({
    required this.controller,
    required this.hintText,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final hasText = value.text.isNotEmpty;
        return Stack(
          alignment: Alignment.topRight,
          children: [
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: hintText,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.fromLTRB(16, 14, 40, 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (hasText)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, color: Color(0xFF4B5563)),
              ),
          ],
        );
      },
    );
  }
}

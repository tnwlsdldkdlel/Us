import 'package:flutter/material.dart';

import 'package:us/theme/us_colors.dart';

class CustomCalendarDialog extends StatefulWidget {
  const CustomCalendarDialog({
    super.key,
    required this.initialDate,
    this.minDate,
    this.maxDate,
  });

  final DateTime initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;

  @override
  State<CustomCalendarDialog> createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<CustomCalendarDialog> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  late final DateTime _today;

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    _today = _normalizeDate(DateTime.now());
    _selectedDate = _normalizeDate(widget.initialDate);
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final dates = _visibleDates();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < _weekdayLabels.length; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        _weekdayLabels[i],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _weekdayColor(i),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 12,
              ),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isDisabled = !_isWithinBounds(date);
                return _CalendarDay(
                  date: date,
                  focusedMonth: _focusedMonth,
                  today: _today,
                  selectedDate: _selectedDate,
                  isDisabled: isDisabled,
                  onSelected: (picked) {
                    if (!_isWithinBounds(picked)) {
                      return;
                    }
                    Navigator.of(context).pop(picked);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final monthLabel = '${_focusedMonth.year}년 ${_focusedMonth.month}월';
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          monthLabel,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        _MonthIconButton(
          icon: Icons.chevron_left_rounded,
          onPressed: _canGoToMonth(-1) ? () => _goToMonth(-1) : null,
        ),
        const SizedBox(width: 4),
        _MonthIconButton(
          icon: Icons.chevron_right_rounded,
          onPressed: _canGoToMonth(1) ? () => _goToMonth(1) : null,
        ),
      ],
    );
  }

  void _goToMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );
    });
  }

  bool _canGoToMonth(int offset) {
    final candidate = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + offset,
    );
    if (offset < 0 && widget.minDate != null) {
      final minMonth = DateTime(widget.minDate!.year, widget.minDate!.month);
      if (candidate.isBefore(minMonth)) {
        return false;
      }
    }
    if (offset > 0 && widget.maxDate != null) {
      final maxMonth = DateTime(widget.maxDate!.year, widget.maxDate!.month);
      if (_isAfterMonth(candidate, maxMonth)) {
        return false;
      }
    }
    return true;
  }

  bool _isWithinBounds(DateTime date) {
    if (widget.minDate != null &&
        date.isBefore(_normalizeDate(widget.minDate!))) {
      return false;
    }
    if (widget.maxDate != null &&
        date.isAfter(_normalizeDate(widget.maxDate!))) {
      return false;
    }
    return true;
  }

  List<DateTime> _visibleDates() {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final firstGridDay = firstDayOfMonth.subtract(Duration(days: firstWeekday));

    return List<DateTime>.generate(
      42,
      (index) => _normalizeDate(firstGridDay.add(Duration(days: index))),
    );
  }

  bool _isAfterMonth(DateTime a, DateTime b) {
    if (a.year > b.year) {
      return true;
    }
    if (a.year < b.year) {
      return false;
    }
    return a.month > b.month;
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Color _weekdayColor(int index) {
    if (index == 0) {
      return const Color(0xFFDC2626);
    }
    if (index == 6) {
      return const Color(0xFF2563EB);
    }
    return Colors.grey[500]!;
  }
}

class _MonthIconButton extends StatelessWidget {
  const _MonthIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: onPressed != null
              ? Colors.grey[700]
              : Colors.grey[400],
          backgroundColor: const Color(0xFFE5E7EB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.focusedMonth,
    required this.today,
    required this.selectedDate,
    required this.isDisabled,
    required this.onSelected,
  });

  final DateTime date;
  final DateTime focusedMonth;
  final DateTime today;
  final DateTime selectedDate;
  final bool isDisabled;
  final ValueChanged<DateTime> onSelected;

  bool get _isCurrentMonth =>
      date.year == focusedMonth.year && date.month == focusedMonth.month;

  bool get _isToday => date == today;

  bool get _isSelected => date == selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color textColor;
    FontWeight fontWeight = FontWeight.w500;

    if (isDisabled) {
      textColor = Colors.grey.shade300;
    } else if (_isSelected) {
      textColor = Colors.white;
      fontWeight = FontWeight.w600;
    } else if (_isToday) {
      textColor = UsColors.primary;
      fontWeight = FontWeight.w700;
    } else if (!_isCurrentMonth) {
      textColor = Colors.grey.shade400;
    } else if (date.weekday == DateTime.sunday) {
      textColor = const Color(0xFFDC2626);
    } else if (date.weekday == DateTime.saturday) {
      textColor = const Color(0xFF2563EB);
    } else {
      textColor = const Color(0xFF1F2937);
    }

    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: textColor,
      fontWeight: fontWeight,
    );

    Widget child;
    if (_isSelected) {
      child = Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: UsColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text('${date.day}', style: textStyle),
      );
    } else {
      child = SizedBox(
        width: 36,
        height: 36,
        child: Center(child: Text('${date.day}', style: textStyle)),
      );
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => onSelected(date),
      behavior: HitTestBehavior.opaque,
      child: Center(child: child),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:us/theme/us_colors.dart';

class CustomCalendarDialog extends StatefulWidget {
  const CustomCalendarDialog({super.key, required this.initialDate});

  final DateTime initialDate;

  @override
  State<CustomCalendarDialog> createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<CustomCalendarDialog> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    final normalizedInitial = _normalizeDate(widget.initialDate);
    _focusedMonth = DateTime(normalizedInitial.year, normalizedInitial.month);
    _selectedDate = normalizedInitial;
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = '${_focusedMonth.year}년 ${_focusedMonth.month}월';
    final dates = _visibleDates();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  monthLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                _MonthButton(
                  icon: Icons.chevron_left,
                  onPressed: () => _goToMonth(-1),
                ),
                const SizedBox(width: 4),
                _MonthButton(
                  icon: Icons.chevron_right,
                  onPressed: () => _goToMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 12,
              ),
              itemCount: dates.length,
              itemBuilder: (context, index) => _CalendarDay(
                date: dates[index],
                focusedMonth: _focusedMonth,
                selectedDate: _selectedDate,
                onSelected: _onDaySelected,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(_selectedDate),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
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

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = _normalizeDate(date);
    });
  }

  List<DateTime> _visibleDates() {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday 0
    final firstGridDay = firstDayOfMonth.subtract(Duration(days: firstWeekday));
    return List.generate(
      42,
      (i) => _normalizeDate(firstGridDay.add(Duration(days: i))),
    );
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Color _weekdayColor(int index) {
    if (index == 0) return const Color(0xFFDC2626);
    if (index == 6) return const Color(0xFF2563EB);
    return Colors.grey[500]!;
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.icon, required this.onPressed});
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: onPressed != null
              ? Colors.grey[700]
              : Colors.grey[400],
          backgroundColor: const Color(0xFFF1F5F9),
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
    required this.selectedDate,
    required this.onSelected,
  });

  final DateTime date;
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = date == selectedDate;
    final isCurrentMonth =
        date.year == focusedMonth.year && date.month == focusedMonth.month;

    Color textColor;
    if (isSelected) {
      textColor = Colors.white;
    } else if (!isCurrentMonth) {
      textColor = Colors.grey.shade400;
    } else if (date.weekday == DateTime.sunday) {
      textColor = const Color(0xFFDC2626);
    } else if (date.weekday == DateTime.saturday) {
      textColor = const Color(0xFF2563EB);
    } else {
      textColor = const Color(0xFF1F2937);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelected(date),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? UsColors.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

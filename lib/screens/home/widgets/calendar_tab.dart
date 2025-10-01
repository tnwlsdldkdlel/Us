import 'package:flutter/material.dart';

import 'package:us/models/appointment.dart';
import 'package:us/theme/us_colors.dart';

import 'section.dart';
import 'today_appointment_card.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({
    super.key,
    required this.todayAppointments,
    required this.upcomingAppointments,
    required this.onTodayAppointmentTap,
    required this.onUpcomingAppointmentTap,
  });

  final List<Appointment> todayAppointments;
  final List<UpcomingAppointment> upcomingAppointments;
  final void Function(Appointment) onTodayAppointmentTap;
  final void Function(UpcomingAppointment) onUpcomingAppointmentTap;

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;
  late DateTime _today;

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    _today = _normalizeDate(DateTime.now());
    _focusedMonth = DateTime(_today.year, _today.month);
    _selectedDate = _today;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          _buildCalendarCard(context),
          const SizedBox(height: 24),
          Section(
            title: '🔥 오늘의 약속',
            child: Column(
              children: [
                for (final appointment in widget.todayAppointments) ...[
                  TodayAppointmentCard(
                    appointment: appointment,
                    onTap: () => widget.onTodayAppointmentTap(appointment),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    final monthLabel = '${_focusedMonth.year}년 ${_focusedMonth.month}월';
    final dates = _visibleDates();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3E7ED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
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
              today: _today,
              selectedDate: _selectedDate,
              onSelected: _onDaySelected,
            ),
          ),
        ],
      ),
    );
  }

  void _goToMonth(int offset) {
    setState(() {
      final newMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );
      _focusedMonth = newMonth;
      final isCurrentMonth =
          newMonth.year == _today.year && newMonth.month == _today.month;
      _selectedDate = isCurrentMonth
          ? _today
          : DateTime(newMonth.year, newMonth.month, 1);
    });
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      final normalized = _normalizeDate(date);
      if (_isAfterCurrentMonth(normalized)) {
        return;
      }
      _selectedDate = normalized;
      if (normalized.year != _focusedMonth.year ||
          normalized.month != _focusedMonth.month) {
        _focusedMonth = DateTime(normalized.year, normalized.month);
      }
    });
  }

  List<DateTime> _visibleDates() {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7; // Make Sunday 0.
    final firstGridDay = firstDayOfMonth.subtract(Duration(days: firstWeekday));

    return List<DateTime>.generate(
      42,
      (index) => _normalizeDate(firstGridDay.add(Duration(days: index))),
    );
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _canGoToMonth(int offset) {
    final candidate = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + offset,
    );
    return !_isAfterCurrentMonth(candidate);
  }

  bool _isAfterCurrentMonth(DateTime date) {
    if (date.year > _today.year) {
      return true;
    }
    if (date.year < _today.year) {
      return false;
    }
    return date.month > _today.month;
  }

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
          backgroundColor: const Color(0xFFE5E7EB),
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
    required this.onSelected,
  });

  final DateTime date;
  final DateTime focusedMonth;
  final DateTime today;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  bool get _isCurrentMonth =>
      date.year == focusedMonth.year && date.month == focusedMonth.month;

  bool get _isToday => date == today;

  bool get _isSelected => date == selectedDate;

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday;
    final isSelected = _isSelected;
    final isCurrentMonth = _isCurrentMonth;

    Color textColor;
    FontWeight fontWeight = FontWeight.w500;

    if (isSelected) {
      textColor = Colors.white;
      fontWeight = FontWeight.w600;
    } else if (isToday) {
      textColor = UsColors.primary;
      fontWeight = FontWeight.w700;
    } else if (!isCurrentMonth) {
      textColor = Colors.grey.shade400;
    } else {
      if (date.weekday == DateTime.sunday) {
        textColor = const Color(0xFFDC2626);
      } else if (date.weekday == DateTime.saturday) {
        textColor = const Color(0xFF2563EB);
      } else {
        textColor = const Color(0xFF1F2937);
      }
    }

    final baseStyle =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
    final textStyle = baseStyle.copyWith(
      color: textColor,
      fontWeight: fontWeight,
    );

    Widget child;
    if (isSelected) {
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
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelected(date),
      child: Center(child: child),
    );
  }
}

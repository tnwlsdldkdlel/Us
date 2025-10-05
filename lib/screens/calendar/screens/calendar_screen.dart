import 'package:flutter/material.dart';

import 'package:us/screens/home/widgets/section.dart';
import 'package:us/screens/home/widgets/today_appointment_card.dart';
import 'package:us/screens/calendar/models/calendar_view_model.dart';
import 'package:us/theme/us_colors.dart';

import 'package:us/models/appointment.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    required this.todayAppointments,
    required this.upcomingAppointments,
    required this.onTodayAppointmentTap,
    required this.onUpcomingAppointmentTap,
    required this.onCreateAppointment,
  });

  final List<Appointment> todayAppointments;
  final List<UpcomingAppointment> upcomingAppointments;
  final void Function(Appointment) onTodayAppointmentTap;
  final void Function(UpcomingAppointment) onUpcomingAppointmentTap;
  final VoidCallback onCreateAppointment;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarViewModel _viewModel = CalendarViewModel();

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final monthLabel =
            '${_viewModel.focusedMonth.year}년 ${_viewModel.focusedMonth.month}월';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    monthLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onCreateAppointment,
                    icon: const Icon(Icons.add_rounded),
                    color: UsColors.primary,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCalendarCard(context, _viewModel.visibleDates),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                children: [
                  Section(
                    child: Column(
                      children: [
                        for (final appointment in widget.todayAppointments) ...[
                          TodayAppointmentCard(
                            appointment: appointment,
                            onTap: () =>
                                widget.onTodayAppointmentTap(appointment),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarCard(BuildContext context, List<DateTime> dates) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            SizedBox(
              height: 300,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 12,
                ),
                itemCount: dates.length,
                itemBuilder: (context, index) => _CalendarDay(
                  date: dates[index],
                  focusedMonth: _viewModel.focusedMonth,
                  today: _viewModel.today,
                  selectedDate: _viewModel.selectedDate,
                  onSelected: _viewModel.selectDate,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 200) {
      return;
    }
    if (velocity < 0) {
      _viewModel.goToMonth(1);
    } else {
      _viewModel.goToMonth(-1);
    }
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

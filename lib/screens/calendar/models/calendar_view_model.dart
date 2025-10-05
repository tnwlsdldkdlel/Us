import 'package:flutter/material.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarViewModel({DateTime? today})
    : _today = _normalize(today ?? DateTime.now()),
      _focusedMonth = DateTime(
        (today ?? DateTime.now()).year,
        (today ?? DateTime.now()).month,
      ),
      _selectedDate = _normalize(today ?? DateTime.now());

  DateTime _focusedMonth;
  DateTime _selectedDate;
  final DateTime _today;

  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDate => _selectedDate;
  DateTime get today => _today;

  List<DateTime> get visibleDates {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final firstGridDay = firstDayOfMonth.subtract(Duration(days: firstWeekday));

    return List<DateTime>.generate(
      42,
      (index) => _normalize(firstGridDay.add(Duration(days: index))),
    );
  }

  bool isAfterCurrentMonth(DateTime date) {
    if (date.year > _today.year) {
      return true;
    }
    if (date.year < _today.year) {
      return false;
    }
    return date.month > _today.month;
  }

  void goToMonth(int offset) {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset);
    final isCurrentMonth =
        _focusedMonth.year == _today.year &&
        _focusedMonth.month == _today.month;
    if (isCurrentMonth) {
      _selectedDate = _today;
    }
    notifyListeners();
  }

  void selectDate(DateTime date) {
    final normalized = _normalize(date);
    if (isAfterCurrentMonth(normalized)) {
      return;
    }
    _selectedDate = normalized;
    if (normalized.year != _focusedMonth.year ||
        normalized.month != _focusedMonth.month) {
      _focusedMonth = DateTime(normalized.year, normalized.month);
    }
    notifyListeners();
  }

  static DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

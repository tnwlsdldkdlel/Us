import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:us/data/mock_friends.dart';
import 'package:us/models/appointment.dart';
import 'package:us/models/friend.dart';
import 'package:us/models/place_suggestion.dart';
import 'package:us/widgets/common_confirm_dialog.dart';
import 'package:us/widgets/custom_calendar_dialog.dart';
import 'package:us/widgets/location_picker_bottom_sheet.dart';
import 'package:us/widgets/people_picker_bottom_sheet.dart';

import 'widgets/basic_info_section.dart';
import 'widgets/edit_header.dart';
import 'widgets/participant_section.dart';

class AppointmentEditScreen extends StatefulWidget {
  const AppointmentEditScreen({super.key, required this.detail});

  final AppointmentDetail detail;

  @override
  State<AppointmentEditScreen> createState() => _AppointmentEditScreenState();
}

class _AppointmentEditScreenState extends State<AppointmentEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _noteController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  List<Friend> _selectedFriends = const [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.detail.title);
    _locationController = TextEditingController(text: widget.detail.location);
    _noteController = TextEditingController()
      ..text = widget.detail.description ?? '';
    _selectedDate = widget.detail.date;
    _selectedTime = widget.detail.startTime;

    final participantNames = widget.detail.participants
        .map((p) => p.name)
        .toSet();
    _selectedFriends = [
      for (final friend in mockFriends)
        if (participantNames.contains(friend.name)) friend,
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();
    final pickedDate = await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (_) => CustomCalendarDialog(
        initialDate: _selectedDate,
        minDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
        maxDate: DateTime.now().add(const Duration(days: 365 * 5)),
      ),
    );

    if (pickedDate != null && mounted) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime() async {
    FocusScope.of(context).unfocus();
    final initialDateTime = DateTime(
      0,
      1,
      1,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final pickedTime = await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (popupContext) {
        TimeOfDay temporaryTime = _selectedTime;
        return Container(
          height: 304,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(popupContext).pop(),
                      child: const Text(
                        '취소',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                    Text(
                      '시간 선택',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () =>
                          Navigator.of(popupContext).pop(temporaryTime),
                      child: const Text(
                        '완료',
                        style: TextStyle(color: Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: false,
                  initialDateTime: initialDateTime,
                  minuteInterval: 5,
                  onDateTimeChanged: (dateTime) {
                    temporaryTime = TimeOfDay.fromDateTime(dateTime);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (pickedTime != null && mounted) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  Future<void> _selectLocation() async {
    FocusScope.of(context).unfocus();
    final suggestion = await showModalBottomSheet<PlaceSuggestion>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.8,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: LocationPickerBottomSheet(
            initialQuery: _locationController.text,
          ),
        ),
      ),
    );

    if (suggestion != null && mounted) {
      setState(() => _locationController.text = suggestion.name);
    }
  }

  Future<void> _selectParticipants() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<List<Friend>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.8,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: PeoplePickerBottomSheet(initialSelected: _selectedFriends),
        ),
      ),
    );

    if (picked != null && mounted) {
      setState(() => _selectedFriends = picked);
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await CommonConfirmDialog.show(
      context,
      message: '약속수정을 취소할까요?',
      confirmLabel: '계속하기',
      cancelLabel: '취소',
      confirmColor: const Color(0xFF10B981),
      cancelColor: const Color(0xFFE5E7EB),
      onConfirm: () => {},
      onCancel: () => Navigator.of(context).maybePop(),
    );

    if (shouldExit == true) {
      // Pop already handled in dialog via onConfirm
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppointmentEditHeader(
                onBackRequested: () => _confirmExit(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BasicInfoSection(
                        titleController: _titleController,
                        locationController: _locationController,
                        noteController: _noteController,
                        onLocationTap: _selectLocation,
                        onLocationClear: () =>
                            setState(() => _locationController.clear()),
                        selectedDate: _selectedDate,
                        selectedTime: _selectedTime,
                        onSelectDate: _selectDate,
                        onSelectTime: _selectTime,
                      ),
                      const SizedBox(height: 28),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 24),
                      ParticipantSection(
                        friends: _selectedFriends,
                        onAdd: _selectParticipants,
                        onRemove: (friend) => setState(() {
                          _selectedFriends = List.of(_selectedFriends)
                            ..removeWhere((f) => f.id == friend.id);
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:us/models/appointment.dart';
import 'package:us/theme/us_colors.dart';
import 'package:us/widgets/custom_calendar_dialog.dart';

class AppointmentEditScreen extends StatefulWidget {
  const AppointmentEditScreen({super.key, required this.detail});

  final AppointmentDetail detail;

  @override
  State<AppointmentEditScreen> createState() => _AppointmentEditScreenState();
}

class _AppointmentEditScreenState extends State<AppointmentEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isPickingTime = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.detail.title);
    _locationController = TextEditingController(text: widget.detail.location);
    _selectedDate = widget.detail.date;
    _selectedTime = widget.detail.startTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
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

    if (!mounted) {
      return;
    }

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _showLocationPicker() async {
    FocusScope.of(context).unfocus();
    final location = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LocationPickerBottomSheet(),
    );

    if (location != null) {
      setState(() {
        _locationController.text = location;
      });
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
      // TODO: Implement time picker UI
      context: context,
      builder: (popupContext) {
        TimeOfDay temporaryTime = _selectedTime;
        return Container(
          height: 304,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
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
                        style: TextStyle(color: UsColors.primary),
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

    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_selectedDate.year}.${_selectedDate.month}.${_selectedDate.day}';
    final timePeriod = _selectedTime.period == DayPeriod.am ? '오전' : '오후';
    final timeText =
        '$timePeriod ${_twoDigits(_selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod)}:${_twoDigits(_selectedTime.minute)}';

    final timeForegroundColor = _isPickingTime
        ? UsColors.primary
        : Colors.black87;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EditTopBar(onBackPressed: Navigator.of(context).pop),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: '제목'),
                    const SizedBox(height: 8),
                    _FilledField(
                      controller: _titleController,
                      hintText: '제목을 입력하세요',
                      onClear: () => _titleController.clear(),
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel(text: '장소'),
                    const SizedBox(height: 8),
                    _FilledField(
                      controller: _locationController,
                      readOnly: true,
                      hintText: '장소를 입력하세요',
                      onTap: _showLocationPicker,
                    ),
                    const SizedBox(height: 24),
                    _FieldLabel(text: '시작일'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ChipButton(
                            label: dateLabel,
                            foregroundColor: Colors.black87,
                            onTap: _selectDate,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ChipButton(
                            label: timeText,
                            foregroundColor: timeForegroundColor,
                            onTap: _selectTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: _FieldLabel(text: '참여자')),
                        _AddParticipantButton(onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _EditTopBar extends StatelessWidget {
  const _EditTopBar({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
        ],
      ),
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
    this.onClear,
    this.onTap,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: onTap == null ? controller : null,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFE5E7EB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        suffixIcon: onClear != null
            ? IconButton(
                onPressed: onClear,
                icon: Icon(Icons.close_rounded, color: Colors.grey[600]),
              )
            : null,
      ),
      readOnly: readOnly,
      onTap: onTap,
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LocationPickerBottomSheet extends StatefulWidget {
  const _LocationPickerBottomSheet();

  @override
  State<_LocationPickerBottomSheet> createState() =>
      _LocationPickerBottomSheetState();
}

class _LocationPickerBottomSheetState
    extends State<_LocationPickerBottomSheet> {
  // Mock data for recent locations
  final _recentLocations = [
    const _RecentLocation(name: '강남역', address: '서울 강남구 강남대로 396'),
    const _RecentLocation(name: '코엑스', address: '서울 강남구 영동대로 513'),
    const _RecentLocation(name: '서울숲', address: '서울 성동구 뚝섬로 273'),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchField(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Text(
                      '최근 검색된 위치',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    for (final location in _recentLocations) ...[
                      _LocationTile(
                        location: location,
                        onTap: () => Navigator.of(context).pop(location.name),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: Colors.grey[700],
          ),
          Text(
            '장소',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 48), // For alignment
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: '장소를 입력하세요',
        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500]),
        filled: true,
        fillColor: const Color.fromARGB(232, 230, 233, 237),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({required this.location, this.onTap});

  final _RecentLocation location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.history_rounded, color: Colors.grey[500]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location.address,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentLocation {
  const _RecentLocation({required this.name, required this.address});
  final String name;
  final String address;
}

class _AddParticipantButton extends StatelessWidget {
  const _AddParticipantButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: UsColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '+ 추가',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

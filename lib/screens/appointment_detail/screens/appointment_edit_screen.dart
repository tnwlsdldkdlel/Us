import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:us/data/appointments/appointment_repository.dart';
import 'package:us/data/appointments/supabase_appointment_repository.dart';
import 'package:us/data/friends/friend_repository.dart';
import 'package:us/data/friends/supabase_friend_repository.dart';
import 'package:us/models/appointment.dart';
import 'package:us/models/appointment_draft.dart';
import 'package:us/models/friend.dart';
import 'package:us/models/place_suggestion.dart';
import 'package:us/widgets/common_confirm_dialog.dart';
import 'package:us/widgets/custom_calendar_dialog.dart';
import 'package:us/widgets/location_picker_bottom_sheet.dart';
import 'package:us/widgets/people_picker_bottom_sheet.dart';
import 'package:us/theme/us_colors.dart';

import 'package:us/screens/appointment_detail/widgets/basic_info_section.dart';
import 'package:us/screens/appointment_detail/widgets/edit_header.dart';
import 'package:us/screens/appointment_detail/widgets/participant_section.dart';

class AppointmentEditScreen extends StatefulWidget {
  AppointmentEditScreen({
    super.key,
    required this.detail,
    this.isNew = false,
    AppointmentRepository? appointmentRepository,
    FriendRepository? friendRepository,
  })  : appointmentRepository =
          appointmentRepository ?? SupabaseAppointmentRepository(),
        friendRepository = friendRepository ?? SupabaseFriendRepository();

  final AppointmentDetail detail;
  final bool isNew;
  final AppointmentRepository appointmentRepository;
  final FriendRepository friendRepository;

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
  List<Friend> _allFriends = const [];
  bool _isFriendsLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  PlaceSuggestion? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.detail.title);
    _locationController = TextEditingController(text: widget.detail.location);
    _noteController = TextEditingController()
      ..text = widget.detail.description ?? '';
    _selectedDate = widget.detail.date;
    _selectedTime = widget.detail.startTime;
    _selectedPlace = null;

    _loadFriends();
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
      setState(() {
        _selectedPlace = suggestion;
        _locationController.text = suggestion.name;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSaving) {
      return;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showError('약속 제목을 입력해주세요.');
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      _showError('약속 장소를 선택해주세요.');
      return;
    }

    final startAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final invitedIds = _selectedFriends
        .map((friend) => friend.userId)
        .where((id) => id != widget.detail.creatorId)
        .toSet()
        .toList(growable: false);

    final draft = AppointmentDraft(
      title: title,
      startAt: startAt,
      duration: const Duration(hours: 1),
      locationName: _locationController.text.trim(),
      description: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      address: _selectedPlace?.roadAddress ?? _selectedPlace?.address,
      latitude: _selectedPlace?.latitude,
      longitude: _selectedPlace?.longitude,
      invitedFriendIds: invitedIds,
    );

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final result = widget.isNew
          ? await widget.appointmentRepository.createAppointment(draft)
          : await widget.appointmentRepository.updateAppointment(
              appointmentId: widget.detail.id,
              draft: draft,
            );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(result);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showError('약속을 저장하지 못했습니다. 잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await widget.friendRepository.fetchAllFriends();
      if (!mounted) {
        return;
      }

      final participantIds = widget.detail.participants
          .where((participant) => participant.userId != widget.detail.creatorId)
          .map((participant) => participant.userId)
          .toSet();

      setState(() {
        _allFriends = friends;
        _selectedFriends = [
          for (final friend in friends)
            if (participantIds.contains(friend.userId)) friend,
        ];
        _isFriendsLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _allFriends = const [];
        _selectedFriends = const [];
        _isFriendsLoading = false;
      });
    }
  }

  Future<void> _selectParticipants() async {
    FocusScope.of(context).unfocus();
    if (_isFriendsLoading) {
      await _loadFriends();
      if (!mounted) {
        return;
      }
    }
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
          child: PeoplePickerBottomSheet(
            initialSelected: _selectedFriends,
            friends: _allFriends,
          ),
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
      message: widget.isNew ? '약속 만들기를 취소할까요?' : '약속 수정을 취소할까요?',
      confirmLabel: '계속하기',
      cancelLabel: '취소',
      confirmColor: const Color(0xFF10B981),
      cancelColor: const Color(0xFFE5E7EB),
      onConfirm: () {},
      onCancel: () {
        Navigator.of(context).maybePop();
      },
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
                title: widget.isNew ? '약속 만들기' : '약속 수정하기',
                onSubmit: _isSaving ? null : _handleSubmit,
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
                        onLocationClear: () => setState(() {
                          _locationController.clear();
                          _selectedPlace = null;
                        }),
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
                            ..removeWhere((f) => f.userId == friend.userId);
                        }),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF97316)),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFFB45309),
                                ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isSaving ? null : _handleSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: UsColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.isNew ? '약속 만들기' : '저장하기',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}

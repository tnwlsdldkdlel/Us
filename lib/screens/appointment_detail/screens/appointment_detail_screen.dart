import 'package:flutter/material.dart';

import 'package:us/data/appointments/appointment_repository.dart';
import 'package:us/models/appointment.dart';
import 'package:us/screens/appointment_detail/screens/appointment_edit_screen.dart';
import 'package:us/screens/appointment_detail/widgets/kakao_map_preview.dart';
import 'package:us/theme/us_colors.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({
    super.key,
    required this.detail,
    required this.title,
    required this.appointmentRepository,
  });

  final AppointmentDetail detail;
  final String title;
  final AppointmentRepository appointmentRepository;

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late final ScrollController _scrollController;
  late final FocusNode _commentFocusNode;
  late AppointmentDetail _detail;
  bool _isUpdating = false;
  String? _errorMessage;
  late final TextEditingController _commentController;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _commentFocusNode = FocusNode();
    _commentFocusNode.addListener(_onCommentFocusChange);
    _detail = widget.detail;
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentFocusNode.removeListener(_onCommentFocusChange);
    _commentFocusNode.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool get _isCreator {
    final uid = widget.appointmentRepository.currentUserId;
    return uid != null && uid == _detail.creatorId;
  }

  void _onCommentFocusChange() {
    if (_commentFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  ParticipantStatus? _viewerParticipant() {
    final candidates = <String>{
      if (widget.appointmentRepository.currentUserId != null)
        widget.appointmentRepository.currentUserId!,
      'current-user',
    };

    for (final participant in _detail.participants) {
      if (candidates.contains(participant.userId)) {
        return participant;
      }
    }
    return null;
  }

  AttendanceStatus? get _viewerStatus => _viewerParticipant()?.status;

  Future<void> _updateAttendance(AttendanceStatus status) async {
    final current = _viewerStatus;
    if (_isUpdating || current == status) {
      return;
    }

    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    try {
      await widget.appointmentRepository.updateRsvp(
        appointmentId: _detail.id,
        status: status,
      );
      final refreshed =
          await widget.appointmentRepository.fetchDetailById(_detail.id);
      if (!mounted) {
        return;
      }
      if (refreshed != null) {
        setState(() {
          _detail = refreshed;
          _isUpdating = false;
        });
      } else {
        setState(() {
          _isUpdating = false;
          _errorMessage = '약속 정보를 새로고침하지 못했습니다.';
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isUpdating = false;
        _errorMessage = '참석 상태를 업데이트하지 못했습니다. 잠시 후 다시 시도해주세요.';
      });
    }
  }

  Future<void> _showOptionsBottomSheet() async {
    if (!_isCreator) {
      return;
    }
    _commentFocusNode.unfocus();

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop('edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5E7EB),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '약속 수정하기',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop('delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '약속 파토내기',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == 'edit') {
      if (!mounted) {
        return;
      }
      final updated = await Navigator.of(context).push<AppointmentDetail>(
        MaterialPageRoute(
          builder: (_) => AppointmentEditScreen(
            detail: _detail,
            appointmentRepository: widget.appointmentRepository,
          ),
        ),
      );
      if (updated != null && mounted) {
        setState(() => _detail = updated);
      }
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmittingComment) {
      return;
    }

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      final comment = await widget.appointmentRepository.addComment(
        appointmentId: _detail.id,
        content: text,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = _detail.copyWith(
          comments: [..._detail.comments, comment],
        );
        _isSubmittingComment = false;
      });
      _commentController.clear();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isSubmittingComment = false);
      _showSnack('댓글을 등록하지 못했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _TopBar(
                      dateLabel: _formatHeaderDate(_detail.date),
                      onMorePressed: _showOptionsBottomSheet,
                      showMenu: _isCreator,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _detail.title,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _formatFullDate(_detail.date),
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimeRange(
                                _detail.startTime,
                                _detail.endTime,
                              ),
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.place_rounded,
                                  size: 18,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _detail.location,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            if (_detail.description != null &&
                                _detail.description!.trim().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                _detail.description!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                            if (_detail.latitude != null &&
                                _detail.longitude != null) ...[
                              const SizedBox(height: 16),
                              KakaoMapPreview(
                                latitude: _detail.latitude!,
                                longitude: _detail.longitude!,
                                placeName: _detail.location,
                              ),
                            ],
                            const SizedBox(height: 20),
                            _RsvpSelector(
                              currentStatus: _viewerStatus,
                              isProcessing: _isUpdating,
                              onSelect: _updateAttendance,
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: const Color(0xFFF97316)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: const Color(0xFFB45309)),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            _SectionCard(
                              title: '참여자',
                              child: Column(
                                children: [
                                  for (final participant in _detail.participants)
                                    ...[
                                      _ParticipantTile(participant: participant),
                                      if (participant !=
                                          _detail.participants.last)
                                        const Divider(height: 20, thickness: 0.5),
                                    ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _SectionCard(
                              title: '댓글',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final comment in _detail.comments) ...[
                                    _CommentTile(comment: comment),
                                    if (comment != _detail.comments.last)
                                      const SizedBox(height: 16),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _CommentInputField(
              focusNode: _commentFocusNode,
              controller: _commentController,
              onSend: _submitComment,
              isSubmitting: _isSubmittingComment,
            ),
          ],
        ),
      ),
    );
  }

  String _formatHeaderDate(DateTime date) => '${date.month}월 ${date.day}일';

  String _formatFullDate(DateTime date) {
    const weekdays = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    final weekday = weekdays[date.weekday % 7];
    return '${date.year}년 ${date.month}월 ${date.day}일 $weekday';
  }

  String _formatTimeRange(TimeOfDay start, TimeOfDay end) {
    return '${_formatTimeOfDay(start)} - ${_formatTimeOfDay(end)}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final periodLabel = time.period == DayPeriod.am ? '오전' : '오후';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$periodLabel $hour:$minute';
  }

  String _attendanceLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.going:
        return '참여';
      case AttendanceStatus.pending:
        return '미정';
      case AttendanceStatus.declined:
        return '거절';
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.dateLabel,
    required this.onMorePressed,
    required this.showMenu,
  });

  final String dateLabel;
  final VoidCallback onMorePressed;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ),
            Text(
              dateLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (showMenu)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onMorePressed,
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _RsvpSelector extends StatelessWidget {
  const _RsvpSelector({
    required this.currentStatus,
    required this.onSelect,
    required this.isProcessing,
  });

  final AttendanceStatus? currentStatus;
  final ValueChanged<AttendanceStatus> onSelect;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    const statuses = <AttendanceStatus>[
      AttendanceStatus.going,
      AttendanceStatus.pending,
      AttendanceStatus.declined,
    ];

    return Row(
      children: [
        for (var index = 0; index < statuses.length; index++) ...[
          Expanded(
            child: FilledButton(
              onPressed: isProcessing
                  ? null
                  : () => onSelect(statuses[index]),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor:
                    currentStatus == statuses[index]
                        ? UsColors.primary
                        : const Color(0xFFE5E7EB),
                foregroundColor: currentStatus == statuses[index]
                    ? Colors.white
                    : Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _label(statuses[index]),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          if (index != statuses.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }

  String _label(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.going:
        return '참여';
      case AttendanceStatus.pending:
        return '미정';
      case AttendanceStatus.declined:
        return '거절';
    }
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant});

  final ParticipantStatus participant;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(participant.status);

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Color(participant.avatarColor),
          child: Text(
            participant.avatarInitial,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            participant.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            participant.statusLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: statusColor.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  _StatusPalette _statusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.going:
        return const _StatusPalette(
          background: Color(0xFFE6FAF3),
          foreground: UsColors.primary,
        );
      case AttendanceStatus.pending:
        return const _StatusPalette(
          background: Color(0xFFE5E7EB),
          foreground: Color(0xFF4B5563),
        );
      case AttendanceStatus.declined:
        return const _StatusPalette(
          background: Color(0xFFFEE2E2),
          foreground: Color(0xFFDC2626),
        );
    }
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final AppointmentComment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFE2E8F0),
          child: Text(
            comment.author.isNotEmpty ? comment.author[0] : '·',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF334155),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      comment.author,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Text(
                    comment.timeLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment.message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPalette {
  const _StatusPalette({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

class _CommentInputField extends StatelessWidget {
  const _CommentInputField({
    required this.focusNode,
    required this.controller,
    required this.onSend,
    required this.isSubmitting,
  });

  final FocusNode? focusNode;
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final isSendEnabled =
              value.text.trim().isNotEmpty && !isSubmitting;
          return TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: !isSubmitting,
            decoration: InputDecoration(
              hintText: '댓글 남기기',
              border: InputBorder.none,
              filled: true,
              fillColor: const Color.fromARGB(232, 230, 233, 237),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                onPressed: isSendEnabled ? onSend : null,
                icon: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, color: UsColors.primary),
              ),
            ),
          );
        },
      ),
    );
  }
}

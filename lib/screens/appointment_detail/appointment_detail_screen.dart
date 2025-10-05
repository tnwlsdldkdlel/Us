import 'package:flutter/material.dart';
import 'package:us/screens/appointment_detail/appointment_edit_screen.dart';

import 'package:us/models/appointment.dart';
import 'package:us/theme/us_colors.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({
    super.key,
    required this.detail,
    required this.title,
  });

  final AppointmentDetail detail;
  final String title;

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late final ScrollController _scrollController;
  late final FocusNode _commentFocusNode;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _commentFocusNode = FocusNode();
    _commentFocusNode.addListener(_onCommentFocusChange);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentFocusNode.removeListener(_onCommentFocusChange);
    _commentFocusNode.dispose();
    super.dispose();
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

  Future<void> _showOptionsBottomSheet() async {
    // 바텀시트가 열리기 전에 현재 포커스를 제거합니다.
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
      // 'mounted'를 확인하여 위젯이 여전히 트리에 있는지 확인합니다.
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AppointmentEditScreen(detail: widget.detail),
        ),
      );
    }
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
                      dateLabel: _formatHeaderDate(widget.detail.date),
                      onMorePressed: _showOptionsBottomSheet,
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
                              widget.detail.title,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _formatFullDate(widget.detail.date),
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimeRange(
                                widget.detail.startTime,
                                widget.detail.endTime,
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
                                  widget.detail.location,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            if (widget.detail.description != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                widget.detail.description!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () {},
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      backgroundColor: UsColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text('참여'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton.tonal(
                                    onPressed: () {},
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      backgroundColor: const Color(0xFFE5E7EB),
                                      foregroundColor: Colors.grey[700],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text('거절'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _SectionCard(
                              title: '참여자',
                              child: Column(
                                children: [
                                  for (final participant
                                      in widget.detail.participants) ...[
                                    _ParticipantTile(participant: participant),
                                    if (participant !=
                                        widget.detail.participants.last)
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
                                  for (final comment
                                      in widget.detail.comments) ...[
                                    _CommentTile(comment: comment),
                                    if (comment != widget.detail.comments.last)
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
            _CommentInputField(focusNode: _commentFocusNode),
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
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.dateLabel, required this.onMorePressed});

  final String dateLabel;
  final VoidCallback onMorePressed;

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
  const _CommentInputField({this.focusNode});

  final FocusNode? focusNode;

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
      child: TextField(
        focusNode: focusNode,
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
            onPressed: () {
              // TODO: 댓글 전송 로직 구현
            },
            icon: const Icon(Icons.send_rounded, color: UsColors.primary),
          ),
        ),
      ),
    );
  }
}

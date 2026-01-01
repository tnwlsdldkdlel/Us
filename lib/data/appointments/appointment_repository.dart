import 'dart:collection';

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';

import 'package:us/models/appointment.dart';
import 'package:us/models/appointment_draft.dart';

class AppointmentOverview {
  const AppointmentOverview({
    required this.today,
    required this.upcoming,
  });

  final List<Appointment> today;
  final List<UpcomingAppointment> upcoming;
}

String attendanceStatusLabel(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.going:
      return '참여';
    case AttendanceStatus.pending:
      return '미정';
    case AttendanceStatus.declined:
      return '거절';
  }
}

abstract class AppointmentRepository {
  String? get currentUserId;

  Future<AppointmentOverview> fetchOverview();

  Future<AppointmentDetail?> fetchDetailById(String id);

  AppointmentDetail createDraftDetail({DateTime? reference});

  Future<AppointmentDetail> createAppointment(AppointmentDraft draft);

  Future<AppointmentDetail> updateAppointment({
    required String appointmentId,
    required AppointmentDraft draft,
  });

  Future<void> updateRsvp({
    required String appointmentId,
    required AttendanceStatus status,
  });

  Future<AppointmentComment> addComment({
    required String appointmentId,
    required String content,
  });
}

class MockAppointmentRepository implements AppointmentRepository {
  MockAppointmentRepository({DateTime? reference})
    : _referenceDate = reference ?? DateTime.now() {
    _initializeData();
  }

  final DateTime _referenceDate;
  static const String _currentUserId = 'current-user';

  @override
  String? get currentUserId => _currentUserId;

  late final Map<String, AppointmentDetail> _details;
  late List<Appointment> _todayAppointments;
  late List<UpcomingAppointment> _upcomingAppointments;

  @override
  Future<AppointmentOverview> fetchOverview() async {
    return AppointmentOverview(
      today: UnmodifiableListView(_todayAppointments),
      upcoming: UnmodifiableListView(_upcomingAppointments),
    );
  }

  @override
  Future<AppointmentDetail?> fetchDetailById(String id) async {
    return _details[id];
  }

  @override
  AppointmentDetail createDraftDetail({DateTime? reference}) {
    final base = reference ?? DateTime.now();
    final startTime = TimeOfDay.fromDateTime(base);
    final endTime =
        TimeOfDay.fromDateTime(base.add(const Duration(hours: 1)));

    return AppointmentDetail(
      id: 'draft-${base.microsecondsSinceEpoch}',
      title: '',
      date: DateTime(base.year, base.month, base.day),
      startTime: startTime,
      endTime: endTime,
      location: '',
      creatorId: _currentUserId,
      description: '',
      address: '',
      latitude: null,
      longitude: null,
      participants: const [],
      comments: const [],
    );
  }

  @override
  Future<AppointmentDetail> createAppointment(AppointmentDraft draft) async {
    final start = draft.startAt;
    final end = draft.endAt;
    final appointmentId = 'mock-${DateTime.now().microsecondsSinceEpoch}';

    final participants = <ParticipantStatus>[
      ParticipantStatus(
        userId: _currentUserId,
        name: '나',
        status: AttendanceStatus.going,
        statusLabel: attendanceStatusLabel(AttendanceStatus.going),
        avatarInitial: '나',
        avatarColor: 0xFF10B981,
      ),
      ...draft.invitedFriendIds.map(
        (friendId) => ParticipantStatus(
          userId: friendId,
          name: friendId,
          status: AttendanceStatus.pending,
          statusLabel: attendanceStatusLabel(AttendanceStatus.pending),
          avatarInitial: friendId.isNotEmpty
              ? friendId.characters.first.toUpperCase()
              : 'F',
          avatarColor: 0xFF6366F1,
        ),
      ),
    ];

    final detail = AppointmentDetail(
      id: appointmentId,
      title: draft.title,
      date: DateTime(start.year, start.month, start.day),
      startTime: TimeOfDay.fromDateTime(start),
      endTime: TimeOfDay.fromDateTime(end),
      location: draft.locationName,
      creatorId: _currentUserId,
      description: draft.description,
      address: draft.address,
      latitude: draft.latitude,
      longitude: draft.longitude,
      participants: participants,
      comments: const [],
    );

    _details[appointmentId] = detail;
    _refreshOverviews();
    return detail;
  }

  @override
  Future<AppointmentDetail> updateAppointment({
    required String appointmentId,
    required AppointmentDraft draft,
  }) async {
    final existing = _details[appointmentId];
    if (existing == null) {
      throw StateError('Appointment not found: $appointmentId');
    }

    final start = draft.startAt;
    final end = draft.endAt;
    final creatorStatus = existing.participants.firstWhere(
      (participant) => participant.userId == existing.creatorId,
      orElse: () => ParticipantStatus(
        userId: existing.creatorId,
        name: '나',
        status: AttendanceStatus.going,
        statusLabel: attendanceStatusLabel(AttendanceStatus.going),
        avatarInitial: '나',
        avatarColor: 0xFF10B981,
      ),
    );

    final updatedParticipants = <ParticipantStatus>[
      creatorStatus,
      ...draft.invitedFriendIds.map(
        (friendId) => ParticipantStatus(
          userId: friendId,
          name: friendId,
          status: AttendanceStatus.pending,
          statusLabel: attendanceStatusLabel(AttendanceStatus.pending),
          avatarInitial: friendId.isNotEmpty
              ? friendId.characters.first.toUpperCase()
              : 'F',
          avatarColor: 0xFF6366F1,
        ),
      ),
    ];

    final updated = AppointmentDetail(
      id: existing.id,
      title: draft.title,
      date: DateTime(start.year, start.month, start.day),
      startTime: TimeOfDay.fromDateTime(start),
      endTime: TimeOfDay.fromDateTime(end),
      location: draft.locationName,
      creatorId: existing.creatorId,
      description: draft.description ?? existing.description,
      address: draft.address ?? existing.address,
      latitude: draft.latitude ?? existing.latitude,
      longitude: draft.longitude ?? existing.longitude,
      participants: updatedParticipants,
      comments: existing.comments,
    );

    _details[appointmentId] = updated;
    _refreshOverviews();
    return updated;
  }

  @override
  Future<void> updateRsvp({
    required String appointmentId,
    required AttendanceStatus status,
  }) async {
    final detail = _details[appointmentId];
    if (detail == null) {
      return;
    }

    final updatedParticipants = detail.participants.map((participant) {
      if (participant.userId != _currentUserId) {
        return participant;
      }
      return ParticipantStatus(
        userId: participant.userId,
        name: participant.name,
        email: participant.email,
        avatarUrl: participant.avatarUrl,
        status: status,
        statusLabel: attendanceStatusLabel(status),
        avatarInitial: participant.avatarInitial,
        avatarColor: participant.avatarColor,
      );
    }).toList(growable: false);

    _details[appointmentId] = AppointmentDetail(
      id: detail.id,
      title: detail.title,
      date: detail.date,
      startTime: detail.startTime,
      endTime: detail.endTime,
      location: detail.location,
      creatorId: detail.creatorId,
      description: detail.description,
      address: detail.address,
      latitude: detail.latitude,
      longitude: detail.longitude,
      participants: updatedParticipants,
      comments: detail.comments,
    );
    _refreshOverviews();
  }

  @override
  Future<AppointmentComment> addComment({
    required String appointmentId,
    required String content,
  }) async {
    final detail = _details[appointmentId];
    if (detail == null) {
      throw StateError('Appointment not found: $appointmentId');
    }

    final comment = AppointmentComment(
      author: 'Mock User',
      message: content,
      timeLabel: '방금 전',
    );

    final updated = AppointmentDetail(
      id: detail.id,
      title: detail.title,
      date: detail.date,
      startTime: detail.startTime,
      endTime: detail.endTime,
      location: detail.location,
      creatorId: detail.creatorId,
      description: detail.description,
      address: detail.address,
      latitude: detail.latitude,
      longitude: detail.longitude,
      participants: detail.participants,
      comments: [...detail.comments, comment],
    );

    _details[appointmentId] = updated;
    return comment;
  }

  void _initializeData() {
    final today = DateTime(
      _referenceDate.year,
      _referenceDate.month,
      _referenceDate.day,
    );

    _details = {
      'hanRiverDinner': AppointmentDetail(
        id: 'hanRiverDinner',
        title: '한강에서 저녁',
        date: today,
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 14, minute: 0),
        location: '한강',
        creatorId: _currentUserId,
        description: '따뜻한 커피와 함께하는 피크닉 모임이에요.',
        address: '서울시 영등포구 여의도동',
        latitude: 37.5283,
        longitude: 126.9347,
        participants: const [
          ParticipantStatus(
            userId: _currentUserId,
            name: '나',
            status: AttendanceStatus.going,
            statusLabel: '참여',
            avatarInitial: '나',
            avatarColor: 0xFF10B981,
          ),
          ParticipantStatus(
            userId: 'friend-1',
            name: '최현우',
            status: AttendanceStatus.going,
            statusLabel: '참여',
            avatarInitial: '최',
            avatarColor: 0xFF10B981,
          ),
          ParticipantStatus(
            userId: 'friend-2',
            name: '정유진',
            status: AttendanceStatus.pending,
            statusLabel: '미정',
            avatarInitial: '정',
            avatarColor: 0xFF38BDF8,
          ),
          ParticipantStatus(
            userId: 'friend-3',
            name: '강태민',
            status: AttendanceStatus.declined,
            statusLabel: '거절',
            avatarInitial: '강',
            avatarColor: 0xFFF97316,
          ),
        ],
        comments: const [
          AppointmentComment(
            author: '최현우',
            message: '약속 기다리고 있을게요!',
            timeLabel: '2시간 전',
          ),
          AppointmentComment(
            author: '정유진',
            message: '다들 내일 봐요~',
            timeLabel: '1월 27일',
          ),
        ],
      ),
      'suzyBirthday': AppointmentDetail(
        id: 'suzyBirthday',
        title: '수진이 생일파티',
        date: today,
        startTime: const TimeOfDay(hour: 19, minute: 0),
        endTime: const TimeOfDay(hour: 22, minute: 0),
        location: '우시성',
        creatorId: 'friend-4',
        description: '드레스 코드: 파스텔 색상 🎉',
        address: '서울시 마포구 연남동',
        latitude: 37.5610,
        longitude: 126.9254,
        participants: const [
          ParticipantStatus(
            userId: 'friend-4',
            name: '남영훈',
            status: AttendanceStatus.going,
            statusLabel: '참여',
            avatarInitial: '남',
            avatarColor: 0xFF6366F1,
          ),
          ParticipantStatus(
            userId: _currentUserId,
            name: '나',
            status: AttendanceStatus.pending,
            statusLabel: '미정',
            avatarInitial: '나',
            avatarColor: 0xFF10B981,
          ),
          ParticipantStatus(
            userId: 'friend-5',
            name: '김지수',
            status: AttendanceStatus.pending,
            statusLabel: '미정',
            avatarInitial: '김',
            avatarColor: 0xFFEC4899,
          ),
          ParticipantStatus(
            userId: 'friend-6',
            name: '박민아',
            status: AttendanceStatus.going,
            statusLabel: '참여',
            avatarInitial: '박',
            avatarColor: 0xFF0EA5E9,
          ),
        ],
        comments: const [
          AppointmentComment(
            author: '남영훈',
            message: '선물 준비 완료! 기대돼요.',
            timeLabel: '5시간 전',
          ),
          AppointmentComment(
            author: '김지수',
            message: '조금 늦을 수도 있어요!',
            timeLabel: '어제',
          ),
        ],
      ),
      'mountainHike': AppointmentDetail(
        id: 'mountainHike',
        title: '주말 등산',
        date: today.add(const Duration(days: 1)),
        startTime: const TimeOfDay(hour: 7, minute: 30),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        location: '북한산 등산로',
        creatorId: 'friend-7',
        description: '초보 코스, 간단한 도시락을 준비해주세요.',
        address: '경기도 고양시 덕양구 효자동',
        latitude: 37.6586,
        longitude: 126.9770,
        participants: const [
          ParticipantStatus(
            userId: 'friend-7',
            name: '이도현',
            status: AttendanceStatus.going,
            statusLabel: '참여',
            avatarInitial: '이',
            avatarColor: 0xFF10B981,
          ),
          ParticipantStatus(
            userId: _currentUserId,
            name: '나',
            status: AttendanceStatus.pending,
            statusLabel: '미정',
            avatarInitial: '나',
            avatarColor: 0xFF10B981,
          ),
        ],
        comments: const [],
      ),
      'officeBirthday': AppointmentDetail(
        id: 'officeBirthday',
        title: '생일 파티',
        date: today.add(const Duration(days: 9)),
        startTime: const TimeOfDay(hour: 18, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
        location: '우정빌딩 1층',
        creatorId: _currentUserId,
        description: '아직 장소를 정하지 않았어요 😳',
        address: '서울시 강남구 역삼동',
        latitude: 37.4999,
        longitude: 127.0369,
        participants: const [
          ParticipantStatus(
            userId: _currentUserId,
            name: '나',
            status: AttendanceStatus.going,
            statusLabel: '참여',
            avatarInitial: '나',
            avatarColor: 0xFF10B981,
          ),
        ],
        comments: const [],
      ),
    };

    _refreshOverviews();
  }

  void _refreshOverviews() {
    final todayDate = DateTime(
      _referenceDate.year,
      _referenceDate.month,
      _referenceDate.day,
    );

    final todaySummaries = <_AppointmentSummary>[];
    final upcomingSummaries = <_UpcomingSummary>[];

    for (final detail in _details.values) {
      final appointmentDate = DateTime(
        detail.date.year,
        detail.date.month,
        detail.date.day,
      );

      if (appointmentDate == todayDate) {
        todaySummaries.add(
          _AppointmentSummary(
            detail: detail,
            summary: _buildTodayFromDetail(detail),
          ),
        );
      } else if (appointmentDate.isAfter(todayDate)) {
        upcomingSummaries.add(
          _UpcomingSummary(
            detail: detail,
            summary: _buildUpcomingFromDetail(detail),
          ),
        );
      }
    }

    todaySummaries.sort((a, b) {
      final aStart = _composeDateTime(a.detail.date, a.detail.startTime);
      final bStart = _composeDateTime(b.detail.date, b.detail.startTime);
      return aStart.compareTo(bStart);
    });

    upcomingSummaries.sort((a, b) {
      final aStart = _composeDateTime(a.detail.date, a.detail.startTime);
      final bStart = _composeDateTime(b.detail.date, b.detail.startTime);
      return aStart.compareTo(bStart);
    });

    _todayAppointments = todaySummaries
        .map((summary) => summary.summary)
        .toList(growable: false);
    _upcomingAppointments = upcomingSummaries
        .map((summary) => summary.summary)
        .toList(growable: false);
  }

  Appointment _buildTodayFromDetail(AppointmentDetail detail) {
    final timeLabel = _formatTimeLabel(detail.startTime);
    final participants = detail.participants
        .map((participant) => participant.avatarInitial)
        .toList(growable: false);

    return Appointment(
      title: detail.title,
      location: detail.location,
      timeLabel: timeLabel,
      description: detail.description,
      participants: participants,
      detailId: detail.id,
    );
  }

  UpcomingAppointment _buildUpcomingFromDetail(AppointmentDetail detail) {
    final appointmentDate = DateTime(
      detail.date.year,
      detail.date.month,
      detail.date.day,
    );
    final todayDate = DateTime(
      _referenceDate.year,
      _referenceDate.month,
      _referenceDate.day,
    );
    final daysBetween = appointmentDate.difference(todayDate).inDays;
    final remainingLabel = _remainingLabel(daysBetween);

    return UpcomingAppointment(
      title: detail.title,
      location: detail.location,
      remaining: remainingLabel,
      note: detail.description,
      detailId: detail.id,
    );
  }

  String _remainingLabel(int daysBetween) {
    if (daysBetween <= 0) {
      return '오늘';
    }
    if (daysBetween == 1) {
      return '내일';
    }
    return '$daysBetween일 남음';
  }

  String _formatTimeLabel(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  DateTime _composeDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

class _AppointmentSummary {
  const _AppointmentSummary({required this.detail, required this.summary});

  final AppointmentDetail detail;
  final Appointment summary;
}

class _UpcomingSummary {
  const _UpcomingSummary({required this.detail, required this.summary});

  final AppointmentDetail detail;
  final UpcomingAppointment summary;
}

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:us/data/appointments/appointment_repository.dart';
import 'package:us/models/appointment.dart';
import 'package:us/models/appointment_draft.dart';
import 'package:us/models/friend.dart';

class SupabaseAppointmentRepository implements AppointmentRepository {
  SupabaseAppointmentRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _appointmentsTable = 'appointments';
  static const _participantsTable = 'appointment_participants';
  static const _commentsTable = 'comments';
  static const _usersTable = 'users';

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  AppointmentDetail createDraftDetail({DateTime? reference}) {
    final base = reference ?? DateTime.now();
    final startTime = TimeOfDay.fromDateTime(base);
    final endTime = TimeOfDay.fromDateTime(base.add(const Duration(hours: 1)));

    return AppointmentDetail(
      id: 'draft-${base.microsecondsSinceEpoch}',
      title: '',
      date: DateTime(base.year, base.month, base.day),
      startTime: startTime,
      endTime: endTime,
      location: '',
      creatorId: currentUserId ?? '',
      description: '',
      address: '',
      latitude: null,
      longitude: null,
      participants: const [],
      comments: const [],
    );
  }

  @override
  Future<AppointmentOverview> fetchOverview() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return const AppointmentOverview(today: [], upcoming: []);
    }

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayUtc = today.toUtc();

      final creatorRows = await _client
          .from(_appointmentsTable)
          .select('appointment_id, title, appointment_time, location_name')
          .gte('appointment_time', todayUtc.toIso8601String())
          .eq('creator_id', userId)
          .order('appointment_time');

      final participantRows = await _client
          .from(_participantsTable)
          .select('appointment_id')
          .eq('user_id', userId);

      final appointmentIds = <String>{};
      final appointments = <Map<String, dynamic>>[];

      if (creatorRows is List) {
        for (final row in creatorRows) {
          final data = Map<String, dynamic>.from(row as Map);
          final id = data['appointment_id'] as String?;
          if (id != null) {
            appointmentIds.add(id);
            appointments.add(data);
          }
        }
      }

      final invitedAppointmentIds = participantRows is List
          ? participantRows
              .map((row) => (row as Map)['appointment_id'] as String?)
              .whereType<String>()
              .toSet()
          : <String>{};

      final additionalIds = invitedAppointmentIds.difference(appointmentIds);
      if (additionalIds.isNotEmpty) {
        final inChunks = List<List<String>>.generate(
          (additionalIds.length / 20).ceil(),
          (index) {
            final start = index * 20;
            final end = start + 20;
            return additionalIds.skip(start).take(20).toList();
          },
        );
        for (final chunk in inChunks) {
          final extraRows = await _client
              .from(_appointmentsTable)
              .select('appointment_id, title, appointment_time, location_name')
              .inFilter('appointment_id', chunk);
          if (extraRows is! List) {
            continue;
          }
          for (final row in extraRows) {
            final data = Map<String, dynamic>.from(row as Map);
            final id = data['appointment_id'] as String?;
            if (id != null && !appointmentIds.contains(id)) {
              appointmentIds.add(id);
              appointments.add(data);
            }
          }
        }
      }

      if (appointments.isEmpty) {
        return const AppointmentOverview(today: [], upcoming: []);
      }

      final participantsByAppointment = await _fetchParticipantsByAppointment(
        appointmentIds,
      );

      final todaySummaries = <_AppointmentSummary>[];
      final upcomingSummaries = <_UpcomingSummary>[];

      for (final appointment in appointments) {
        final id = appointment['appointment_id'] as String;
        final timeString = appointment['appointment_time'] as String?;
        if (timeString == null) {
          continue;
        }
        final startAt = DateTime.parse(timeString).toLocal();
        final participants = participantsByAppointment[id] ?? const [];
        final summaryParticipants = participants
            .map((participant) => participant.avatarInitial)
            .toList(growable: false);

        final detailDate = DateTime(startAt.year, startAt.month, startAt.day);
        final appointmentSummary = Appointment(
          title: appointment['title'] as String? ?? '제목 없음',
          location: appointment['location_name'] as String? ?? '-',
          timeLabel: _formatTimeLabel(startAt),
          description: null,
          participants: summaryParticipants,
          detailId: id,
        );

        final upcomingSummary = UpcomingAppointment(
          title: appointment['title'] as String? ?? '제목 없음',
          location: appointment['location_name'] as String? ?? '-',
          remaining: _remainingLabel(today, detailDate),
          note: null,
          detailId: id,
        );

        if (_isSameDay(detailDate, today)) {
          todaySummaries.add(_AppointmentSummary(appointmentSummary, startAt));
        } else if (detailDate.isAfter(today)) {
          upcomingSummaries.add(_UpcomingSummary(upcomingSummary, startAt));
        }
      }

      todaySummaries.sort((a, b) => a.start.compareTo(b.start));
      upcomingSummaries.sort((a, b) => a.start.compareTo(b.start));

      return AppointmentOverview(
        today: todaySummaries
            .map((summary) => summary.summary)
            .toList(growable: false),
        upcoming: upcomingSummaries
            .map((summary) => summary.summary)
            .toList(growable: false),
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to load appointments: $error\n$stackTrace');
      return const AppointmentOverview(today: [], upcoming: []);
    }
  }

  @override
  Future<AppointmentDetail?> fetchDetailById(String id) async {
    try {
      final row = await _client
          .from(_appointmentsTable)
          .select()
          .eq('appointment_id', id)
          .maybeSingle();

      if (row == null) {
        return null;
      }

      final data = Map<String, dynamic>.from(row as Map);
      final participants = await _fetchParticipantsByAppointment({id});
      final comments = await _fetchComments(id);

      final appointmentTime = data['appointment_time'] as String?;
      DateTime startAt = DateTime.now();
      if (appointmentTime != null) {
        startAt = DateTime.parse(appointmentTime).toLocal();
      }

      final locationName = data['location_name'] as String? ?? '-';

      return AppointmentDetail(
        id: id,
        title: data['title'] as String? ?? '제목 없음',
        date: DateTime(startAt.year, startAt.month, startAt.day),
        startTime: TimeOfDay.fromDateTime(startAt),
        endTime: TimeOfDay.fromDateTime(startAt.add(const Duration(hours: 1))),
        location: locationName,
        creatorId: data['creator_id'] as String? ?? '',
        description: data['description'] as String?,
        address: data['address'] as String?,
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
        participants: participants[id] ?? const [],
        comments: comments,
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to load appointment detail($id): $error\n$stackTrace');
      return null;
    }
  }

  @override
  Future<AppointmentDetail> createAppointment(AppointmentDraft draft) async {
    final userId = _requireUserId();
    final startAt = draft.startAt.toUtc();
    final endAt = draft.endAt.toUtc();
    final now = DateTime.now().toUtc().toIso8601String();

    final payload = <String, dynamic>{
      'creator_id': userId,
      'title': draft.title,
      'appointment_time': startAt.toIso8601String(),
      'location_name': draft.locationName,
      'created_at': now,
      'updated_at': now,
    };

    if (draft.address != null && draft.address!.trim().isNotEmpty) {
      payload['address'] = draft.address;
    }
    if (draft.latitude != null) {
      payload['latitude'] = draft.latitude;
    }
    if (draft.longitude != null) {
      payload['longitude'] = draft.longitude;
    }

    final inserted = await _client
        .from(_appointmentsTable)
        .insert(payload)
        .select('appointment_id')
        .single();

    final appointmentId = (inserted as Map)['appointment_id'] as String;

    final participantRows = [
      {
        'appointment_id': appointmentId,
        'user_id': userId,
        'rsvp_status': _statusToText(AttendanceStatus.going),
        'created_at': now,
        'updated_at': now,
      },
      for (final friendId in draft.invitedFriendIds)
        {
          'appointment_id': appointmentId,
          'user_id': friendId,
          'rsvp_status': _statusToText(AttendanceStatus.pending),
          'created_at': now,
          'updated_at': now,
        },
    ];

    if (participantRows.isNotEmpty) {
      await _client.from(_participantsTable).insert(participantRows);
    }

    return (await fetchDetailById(appointmentId))!;
  }

  @override
  Future<AppointmentDetail> updateAppointment({
    required String appointmentId,
    required AppointmentDraft draft,
  }) async {
    final userId = _requireUserId();

    final startAt = draft.startAt.toUtc();
    final nowIso = DateTime.now().toUtc().toIso8601String();

    final payload = <String, dynamic>{
      'title': draft.title,
      'appointment_time': startAt.toIso8601String(),
      'location_name': draft.locationName,
      'updated_at': nowIso,
      'description': draft.description?.trim().isEmpty ?? true
          ? null
          : draft.description,
      'address': draft.address?.trim().isEmpty ?? true ? null : draft.address,
      'latitude': draft.latitude,
      'longitude': draft.longitude,
    };

    await _client
        .from(_appointmentsTable)
        .update(payload)
        .eq('appointment_id', appointmentId)
        .eq('creator_id', userId);

    final response = await _client
        .from(_participantsTable)
        .select('participant_id, user_id')
        .eq('appointment_id', appointmentId);

    final existing = <String, Map<String, dynamic>>{};
    if (response is List) {
      for (final row in response) {
        final data = Map<String, dynamic>.from(row as Map);
        existing[data['user_id'] as String] = data;
      }
    }

    final desired = draft.invitedFriendIds.toSet();
    final existingNonCreator = existing.keys.where((id) => id != userId).toSet();

    final toRemove = existingNonCreator.difference(desired);
    if (toRemove.isNotEmpty) {
      await _client
          .from(_participantsTable)
          .delete()
          .eq('appointment_id', appointmentId)
          .inFilter('user_id', toRemove.toList());
    }

    final toAdd = desired.difference(existingNonCreator);
    if (toAdd.isNotEmpty) {
      final rows = toAdd
          .map(
            (participantId) => {
              'appointment_id': appointmentId,
              'user_id': participantId,
              'rsvp_status': _statusToText(AttendanceStatus.pending),
              'created_at': nowIso,
              'updated_at': nowIso,
            },
          )
          .toList(growable: false);
      await _client.from(_participantsTable).insert(rows);
    }

    return (await fetchDetailById(appointmentId))!;
  }

  @override
  Future<void> updateRsvp({
    required String appointmentId,
    required AttendanceStatus status,
  }) async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      debugPrint('Skip updateRsvp - no authenticated user.');
      return;
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final statusText = _statusToText(status);

    final existing = await _client
        .from(_participantsTable)
        .select('participant_id')
        .eq('appointment_id', appointmentId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing == null) {
      await _client.from(_participantsTable).insert({
        'appointment_id': appointmentId,
        'user_id': userId,
        'rsvp_status': statusText,
        'created_at': now,
        'updated_at': now,
      });
    } else {
      final participantId = (existing as Map)['participant_id'];
      await _client
          .from(_participantsTable)
          .update({
            'rsvp_status': statusText,
            'updated_at': now,
          })
          .eq('participant_id', participantId);
    }
  }

  Future<Map<String, List<ParticipantStatus>>> _fetchParticipantsByAppointment(
    Set<String> appointmentIds,
  ) async {
    if (appointmentIds.isEmpty) {
      return const {};
    }

    final response = await _client
        .from(_participantsTable)
        .select('appointment_id, user_id, rsvp_status')
        .inFilter('appointment_id', appointmentIds.toList());

    if (response is! List) {
      return const {};
    }

    final userIds = response
        .map((row) => (row as Map)['user_id'] as String?)
        .whereType<String>()
        .toSet();
    final userMap = await _fetchUsers(userIds);

    final Map<String, List<ParticipantStatus>> result = {};

    for (final row in response) {
      final data = Map<String, dynamic>.from(row as Map);
      final appointmentId = data['appointment_id'] as String?;
      final userId = data['user_id'] as String?;
      if (appointmentId == null || userId == null) {
        continue;
      }

      final statusText = data['rsvp_status'] as String? ?? 'PENDING';
      final status = _statusFromText(statusText);

      final userData = userMap[userId] ?? const {};
      final nickname = userData['nickname'] as String?;
      final email = userData['email'] as String?;
      final avatarUrl = userData['profile_image_url'] as String?;
      final displayName = _resolveDisplayName(nickname: nickname, email: email);
      final avatarInitial = displayName.characters.isEmpty
          ? '친'
          : displayName.characters.first.toUpperCase();

      final participant = ParticipantStatus(
        userId: userId,
        name: displayName,
        email: email,
        avatarUrl: avatarUrl,
        status: status,
        statusLabel: attendanceStatusLabel(status),
        avatarInitial: avatarInitial,
        avatarColor: generateAvatarColor(userId).value,
      );

      result.putIfAbsent(appointmentId, () => []).add(participant);
    }

    return result.map((key, value) => MapEntry(key, List.unmodifiable(value)));
  }

  Future<List<AppointmentComment>> _fetchComments(String appointmentId) async {
    final response = await _client
        .from(_commentsTable)
        .select('user_id, content, created_at')
        .eq('appointment_id', appointmentId)
        .order('created_at');

    final comments = <AppointmentComment>[];
    if (response is! List) {
      return comments;
    }

    final userIds = response
        .map((row) => (row as Map)['user_id'] as String?)
        .whereType<String>()
        .toSet();
    final userMap = await _fetchUsers(userIds);

    for (final row in response) {
      final data = Map<String, dynamic>.from(row as Map);
      final userId = data['user_id'] as String?;
      final content = data['content'] as String?;
      if (content == null) {
        continue;
      }
      final createdAt = data['created_at'] as String?;
      final createdTime = createdAt != null
          ? DateTime.tryParse(createdAt)?.toLocal()
          : null;
      final displayName = _resolveDisplayName(
        nickname: userMap[userId]?['nickname'] as String?,
        email: userMap[userId]?['email'] as String?,
      );

      comments.add(
        AppointmentComment(
          author: displayName,
          message: content,
          timeLabel: createdTime != null
              ? _relativeTimeLabel(createdTime)
              : '방금 전',
        ),
      );
    }

    return comments;
  }

  @override
  Future<AppointmentComment> addComment({
    required String appointmentId,
    required String content,
  }) async {
    final userId = _requireUserId();
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('댓글 내용을 입력하세요.');
    }

    final now = DateTime.now().toUtc();
    final inserted = await _client
        .from(_commentsTable)
        .insert({
          'appointment_id': appointmentId,
          'user_id': userId,
          'content': trimmed,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .select('created_at')
        .single();

    final createdAtIso = (inserted as Map)['created_at'] as String?;
    final createdAt = createdAtIso != null
        ? DateTime.tryParse(createdAtIso)?.toLocal()
        : DateTime.now();

    final displayName = await _currentUserDisplayName();

    return AppointmentComment(
      author: displayName,
      message: trimmed,
      timeLabel: createdAt != null
          ? _relativeTimeLabel(createdAt)
          : '방금 전',
    );
  }

  Future<Map<String, Map<String, dynamic>>> _fetchUsers(
    Set<String> userIds,
  ) async {
    if (userIds.isEmpty) {
      return const {};
    }

    final response = await _client
        .from(_usersTable)
        .select('user_id, nickname, email, profile_image_url')
        .inFilter('user_id', userIds.toList());

    final Map<String, Map<String, dynamic>> result = {};
    for (final row in response as List) {
      final data = Map<String, dynamic>.from(row as Map);
      final id = data['user_id'] as String?;
      if (id != null) {
        result[id] = data;
      }
    }
    return result;
  }

  String _resolveDisplayName({String? nickname, String? email}) {
    if (nickname != null && nickname.trim().isNotEmpty) {
      return nickname.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      return email.split('@').first;
    }
    return '친구';
  }

  String _remainingLabel(DateTime base, DateTime target) {
    final difference = target.difference(base).inDays;
    if (difference <= 0) {
      return '오늘';
    }
    if (difference == 1) {
      return '내일';
    }
    return '$difference일 남음';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatTimeLabel(DateTime dateTime) =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  String _relativeTimeLabel(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) {
      return '방금 전';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    }
    return '${time.month}월 ${time.day}일';
  }

  AttendanceStatus _statusFromText(String value) {
    switch (value.toUpperCase()) {
      case 'ATTENDING':
        return AttendanceStatus.going;
      case 'DECLINED':
        return AttendanceStatus.declined;
      default:
        return AttendanceStatus.pending;
    }
  }

  String _statusToText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.going:
        return 'ATTENDING';
      case AttendanceStatus.pending:
        return 'PENDING';
      case AttendanceStatus.declined:
        return 'DECLINED';
    }
  }

  String _requireUserId() {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw const AuthException('로그인이 필요합니다.');
    }
    return userId;
  }

  Future<String> _currentUserDisplayName() async {
    final user = _client.auth.currentUser;
    final metadata = user?.userMetadata ?? <String, dynamic>{};
    final possibleKeys = ['nickname', 'full_name', 'name'];
    for (final key in possibleKeys) {
      final value = metadata[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final email = user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return '사용자';
  }
}

class _AppointmentSummary {
  const _AppointmentSummary(this.summary, this.start);

  final Appointment summary;
  final DateTime start;
}

class _UpcomingSummary {
  const _UpcomingSummary(this.summary, this.start);

  final UpcomingAppointment summary;
  final DateTime start;
}

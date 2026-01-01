import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:us/data/friends/friend_failure.dart';
import 'package:us/data/friends/friend_repository.dart';
import 'package:us/models/friend.dart';
import 'package:us/models/friendship_status.dart';
import 'package:us/services/email_invite_service.dart';

class SupabaseFriendRepository implements FriendRepository {
  SupabaseFriendRepository({
    SupabaseClient? client,
    EmailInviteService? emailInviteService,
  }) : _client = client ?? Supabase.instance.client,
       _emailInviteService =
           emailInviteService ?? SupabaseEmailInviteService(client: client);

  final SupabaseClient _client;
  final EmailInviteService _emailInviteService;

  static const _inviteIdPrefix = 'invite:';

  @override
  Future<FriendCollections> fetchFriendCollections() async {
    final userId = _currentUserId();

    final response = await _client
        .from('friendships')
        .select('friendship_id, requester_id, addressee_id, status, created_at')
        .neq('status', 'REJECTED')
        .or('requester_id.eq.$userId,addressee_id.eq.$userId')
        .order('created_at');

    final friendships = List<Map<String, dynamic>>.from(response as List);
    final myFriends = <Friend>[];
    final incoming = <Friend>[];
    final outgoing = <Friend>[];

    if (friendships.isNotEmpty) {
      final otherUserIds = friendships
          .map(
            (row) => row['requester_id'] == userId
                ? row['addressee_id']
                : row['requester_id'],
          )
          .whereType<String>()
          .toSet()
          .toList();

      final userMap = <String, Map<String, dynamic>>{};
      if (otherUserIds.isNotEmpty) {
        final usersResponse = await _client
            .from('users')
            .select('user_id, nickname, email, profile_image_url')
            .inFilter('user_id', otherUserIds);
        for (final row in usersResponse as List) {
          final data = Map<String, dynamic>.from(row as Map);
          userMap[data['user_id'] as String] = data;
        }
      }

      for (final row in friendships) {
        final requesterId = row['requester_id'] as String;
        final addresseeId = row['addressee_id'] as String;
        final status = parseFriendshipStatus(row['status'] as String);
        if (status == FriendshipStatus.rejected) {
          continue;
        }
        final isIncoming =
            status == FriendshipStatus.requested && addresseeId == userId;
        final isOutgoing =
            status == FriendshipStatus.requested && requesterId == userId;
        final otherUserId = requesterId == userId ? addresseeId : requesterId;
        final userData = userMap[otherUserId];
        final displayName = _resolveDisplayName(userData);

        final friend = Friend(
          friendshipId: row['friendship_id'] as String,
          userId: otherUserId,
          name: displayName,
          email: userData?['email'] as String?,
          avatarUrl: userData?['profile_image_url'] as String?,
          status: status,
          isIncomingRequest: isIncoming,
          isOutgoingRequest: isOutgoing,
        );

        if (status == FriendshipStatus.accepted) {
          myFriends.add(friend);
        } else if (isIncoming) {
          incoming.add(friend);
        } else if (isOutgoing) {
          outgoing.add(friend);
        }
      }
    }

    await _appendOutgoingInvites(outgoing: outgoing, inviterId: userId);

    return FriendCollections(
      myFriends: myFriends,
      receivedRequests: incoming,
      sentRequests: outgoing,
    );
  }

  @override
  Future<List<Friend>> fetchAllFriends() async {
    final collections = await fetchFriendCollections();
    return collections.myFriends;
  }

  @override
  Future<FriendRequestResult> sendFriendRequest(String email) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      throw FriendFailure('이메일을 입력해주세요.');
    }

    final currentUserId = _currentUserId();

    final Map<String, dynamic>? targetUser = await _client
        .from('users')
        .select('user_id, email')
        .ilike('email', trimmedEmail)
        .maybeSingle();

    if (targetUser == null) {
      return _sendInviteToEmail(email: trimmedEmail, inviterId: currentUserId);
    }

    final targetData = Map<String, dynamic>.from(targetUser);
    final targetUserId = targetData['user_id'] as String;

    if (targetUserId == currentUserId) {
      throw FriendFailure('본인에게 친구 요청을 보낼 수 없습니다.');
    }

    final Map<String, dynamic>? existing = await _client
        .from('friendships')
        .select('friendship_id, status, requester_id, addressee_id')
        .or(
          'and(requester_id.eq.$currentUserId,addressee_id.eq.$targetUserId),and(requester_id.eq.$targetUserId,addressee_id.eq.$currentUserId)',
        )
        .maybeSingle();

    if (existing != null) {
      final existingData = Map<String, dynamic>.from(existing);
      final status = parseFriendshipStatus(existingData['status'] as String);
      final nowIso = DateTime.now().toUtc().toIso8601String();
      if (status == FriendshipStatus.accepted) {
        throw FriendFailure('이미 친구로 연결되어 있습니다.');
      }
      if (status == FriendshipStatus.requested) {
        if (existingData['requester_id'] == currentUserId) {
          throw FriendFailure('이미 친구 요청을 보냈습니다.');
        } else {
          throw FriendFailure('상대방이 이미 친구 요청을 보냈습니다. 요청함 탭을 확인하세요.');
        }
      }

      await _client
          .from('friendships')
          .update({
            'requester_id': currentUserId,
            'addressee_id': targetUserId,
            'status': friendshipStatusToText(FriendshipStatus.requested),
            'created_at': nowIso,
            'updated_at': nowIso,
          })
          .eq('friendship_id', existingData['friendship_id']);
      return FriendRequestResult.requestSent;
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();
    await _client.from('friendships').insert({
      'requester_id': currentUserId,
      'addressee_id': targetUserId,
      'status': friendshipStatusToText(FriendshipStatus.requested),
      'created_at': nowIso,
      'updated_at': nowIso,
    });
    return FriendRequestResult.requestSent;
  }

  @override
  Future<void> respondToRequest({
    required String friendshipId,
    required FriendRequestAction action,
  }) async {
    if (_isInviteIdentifier(friendshipId)) {
      // 수신자가 가입해 요청으로 전환되기 전에는 사용자가 응답할 수 없습니다.
      throw FriendFailure('아직 가입하지 않은 친구입니다. 초대가 완료될 때까지 기다려주세요.');
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final update = action == FriendRequestAction.accept
        ? {
            'status': friendshipStatusToText(FriendshipStatus.accepted),
            'updated_at': nowIso,
          }
        : {
            'status': friendshipStatusToText(FriendshipStatus.rejected),
            'updated_at': nowIso,
          };

    await _client
        .from('friendships')
        .update(update)
        .eq('friendship_id', friendshipId);
  }

  @override
  Future<void> cancelFriendRequest(String friendshipId) async {
    if (_isInviteIdentifier(friendshipId)) {
      final inviteId = _extractInviteId(friendshipId);
      final nowIso = DateTime.now().toUtc().toIso8601String();
      await _client
          .from('friend_invites')
          .update({'status': 'CANCELLED', 'updated_at': nowIso})
          .eq('invite_id', inviteId);
      return;
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();
    await _client
        .from('friendships')
        .update({
          'status': friendshipStatusToText(FriendshipStatus.rejected),
          'updated_at': nowIso,
        })
        .eq('friendship_id', friendshipId);
  }

  @override
  Future<void> removeFriend(String friendshipId) async {
    if (_isInviteIdentifier(friendshipId)) {
      await cancelFriendRequest(friendshipId);
      return;
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();
    await _client
        .from('friendships')
        .update({
          'status': friendshipStatusToText(FriendshipStatus.rejected),
          'updated_at': nowIso,
        })
        .eq('friendship_id', friendshipId);
  }

  Future<void> _appendOutgoingInvites({
    required List<Friend> outgoing,
    required String inviterId,
  }) async {
    final now = DateTime.now().toUtc();
    final response = await _client
        .from('friend_invites')
        .select(
          'invite_id, invitee_email, status, expires_at, created_at, updated_at',
        )
        .eq('inviter_id', inviterId)
        .order('created_at');

    final invites = List<Map<String, dynamic>>.from(response as List);
    for (final row in invites) {
      final status = (row['status'] as String?)?.toUpperCase();
      if (status != 'INVITED') {
        continue;
      }

      final inviteId = row['invite_id'] as String;
      final expiresAt = DateTime.tryParse(row['expires_at'] as String? ?? '');
      if (expiresAt != null && expiresAt.isBefore(now)) {
        await _expireInvite(inviteId);
        continue;
      }

      final email = row['invitee_email'] as String? ?? '';
      if (email.isEmpty) {
        continue;
      }

      outgoing.add(
        Friend(
          friendshipId: '$_inviteIdPrefix$inviteId',
          userId: email,
          name: email,
          email: email,
          avatarUrl: null,
          status: FriendshipStatus.invited,
          isIncomingRequest: false,
          isOutgoingRequest: true,
        ),
      );
    }
  }

  Future<FriendRequestResult> _sendInviteToEmail({
    required String email,
    required String inviterId,
  }) async {
    final now = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(now.year, now.month, now.day);

    final recentInvitesResponse = await _client
        .from('friend_invites')
        .select('invite_id')
        .eq('inviter_id', inviterId)
        .gte('created_at', startOfDay.toIso8601String());
    final invitesToday = List<Map<String, dynamic>>.from(
      recentInvitesResponse as List,
    );
    if (invitesToday.length >= 20) {
      throw FriendFailure('하루 초대 가능 횟수를 초과했습니다. 내일 다시 시도해주세요.');
    }

    final inviteId = await _createOrRefreshInvite(
      email: email,
      inviterId: inviterId,
      now: now,
    );

    final inviterName = await _currentUserDisplayName();
    try {
      await _emailInviteService.sendFriendInvite(
        email: email,
        inviterName: inviterName,
      );
    } on FriendFailure {
      final failureIso = DateTime.now().toUtc().toIso8601String();
      await _client
          .from('friend_invites')
          .update({'status': 'FAILED', 'updated_at': failureIso})
          .eq('invite_id', inviteId);
      rethrow;
    }

    return FriendRequestResult.inviteEmailSent;
  }

  Future<String> _createOrRefreshInvite({
    required String email,
    required String inviterId,
    required DateTime now,
  }) async {
    final existing = await _client
        .from('friend_invites')
        .select('invite_id, status, expires_at')
        .eq('inviter_id', inviterId)
        .ilike('invitee_email', email)
        .maybeSingle();

    final nowIso = now.toIso8601String();
    final expiresAtIso = now.add(const Duration(days: 14)).toIso8601String();

    if (existing != null) {
      final data = Map<String, dynamic>.from(existing);
      final status = (data['status'] as String?)?.toUpperCase();
      final expiresAt = DateTime.tryParse(data['expires_at'] as String? ?? '');
      final inviteId = data['invite_id'] as String;

      final isActive =
          status == 'INVITED' && expiresAt != null && expiresAt.isAfter(now);
      if (isActive) {
        throw FriendFailure('이미 초대를 보냈습니다.');
      }

      await _client
          .from('friend_invites')
          .update({
            'status': 'INVITED',
            'invitee_email': email,
            'created_at': nowIso,
            'updated_at': nowIso,
            'expires_at': expiresAtIso,
          })
          .eq('invite_id', inviteId);
      return inviteId;
    }

    final inserted = await _client
        .from('friend_invites')
        .insert({
          'inviter_id': inviterId,
          'invitee_email': email,
          'status': 'INVITED',
          'created_at': nowIso,
          'updated_at': nowIso,
          'expires_at': expiresAtIso,
        })
        .select('invite_id')
        .single();

    final insertedMap = Map<String, dynamic>.from(
      inserted as Map<String, dynamic>,
    );
    final inviteId =
        (insertedMap['invite_id'] as String?) ??
        insertedMap['invite_id']?.toString();
    if (inviteId == null) {
      throw FriendFailure('초대 ID를 가져오지 못했습니다.');
    }
    return inviteId;
  }

  Future<void> _expireInvite(String inviteId) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    await _client
        .from('friend_invites')
        .update({'status': 'EXPIRED', 'updated_at': nowIso})
        .eq('invite_id', inviteId);
  }

  bool _isInviteIdentifier(String id) => id.startsWith(_inviteIdPrefix);

  String _extractInviteId(String id) => id.substring(_inviteIdPrefix.length);

  String _resolveDisplayName(Map<String, dynamic>? userData) {
    if (userData == null) {
      return '알 수 없음';
    }
    final nickname = userData['nickname'] as String?;
    if (nickname != null && nickname.trim().isNotEmpty) {
      return nickname.trim();
    }
    final email = userData['email'] as String?;
    if (email != null && email.trim().isNotEmpty) {
      return email.split('@').first;
    }
    return '알 수 없음';
  }

  String _currentUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw FriendFailure('로그인이 필요합니다.');
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
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return '친구';
  }
}

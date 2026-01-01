import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  UserRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> ensureUserProfile(User user) async {
    final userId = user.id;
    final existing = await _client
        .from('users')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();

    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();
    final profile = <String, dynamic>{
      'user_id': userId,
      'email': user.email,
      'nickname': _extractNickname(user),
      'profile_image_url': _extractProfileImage(user),
      'social_provider': _extractProvider(user),
      'updated_at': nowIso,
    };

    if (existing == null) {
      await _client.from('users').insert({...profile, 'created_at': nowIso});
    } else {
      await _client.from('users').update(profile).eq('user_id', userId);
    }

    await _promotePendingInvites(user: user, referenceTime: now);
  }

  Future<void> _promotePendingInvites({
    required User user,
    required DateTime referenceTime,
  }) async {
    final email = user.email;
    if (email == null || email.isEmpty) {
      return;
    }

    final invitesResponse = await _client
        .from('friend_invites')
        .select('invite_id, inviter_id, status, expires_at')
        .eq('status', 'INVITED')
        .ilike('invitee_email', email);

    final invites = List<Map<String, dynamic>>.from(invitesResponse as List);
    if (invites.isEmpty) {
      return;
    }

    final nowIso = referenceTime.toIso8601String();
    for (final row in invites) {
      final inviteId = row['invite_id'] as String;
      final inviterId = row['inviter_id'] as String?;
      if (inviterId == null || inviterId.isEmpty) {
        continue;
      }

      final expiresAt = DateTime.tryParse(row['expires_at'] as String? ?? '');
      if (expiresAt != null && expiresAt.isBefore(referenceTime)) {
        await _client
            .from('friend_invites')
            .update({'status': 'EXPIRED', 'updated_at': nowIso})
            .eq('invite_id', inviteId);
        continue;
      }

      final existingFriendship = await _client
          .from('friendships')
          .select('friendship_id')
          .or(
            'and(requester_id.eq.$inviterId,addressee_id.eq.${user.id}),and(requester_id.eq.${user.id},addressee_id.eq.$inviterId)',
          )
          .maybeSingle();

      if (existingFriendship == null) {
        await _client.from('friendships').insert({
          'requester_id': inviterId,
          'addressee_id': user.id,
          'status': 'REQUESTED',
          'created_at': nowIso,
          'updated_at': nowIso,
        });
      }

      await _client
          .from('friend_invites')
          .update({
            'status': 'COMPLETED',
            'updated_at': nowIso,
            'completed_at': nowIso,
          })
          .eq('invite_id', inviteId);
    }
  }

  String? _extractNickname(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    final possibleKeys = ['nickname', 'full_name', 'name'];
    for (final key in possibleKeys) {
      final value = metadata[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return null;
  }

  String? _extractProfileImage(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    final possibleKeys = ['avatar_url', 'picture'];
    for (final key in possibleKeys) {
      final value = metadata[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  String? _extractProvider(User user) {
    final appMetadata = user.appMetadata;
    final provider = appMetadata['provider'];
    return provider is String ? provider.toUpperCase() : null;
  }
}

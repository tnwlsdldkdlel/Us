import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:us/data/friends/friend_failure.dart';

abstract class EmailInviteService {
  Future<void> sendFriendInvite({
    required String email,
    required String inviterName,
  });
}

class SupabaseEmailInviteService implements EmailInviteService {
  SupabaseEmailInviteService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<void> sendFriendInvite({
    required String email,
    required String inviterName,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'send-friend-invite',
        body: {'email': email, 'inviterName': inviterName},
        headers: {'Content-Type': 'application/json'},
      );

      if (response.status >= 400) {
        throw FriendFailure('초대 메일을 보내지 못했습니다. 잠시 후 다시 시도해주세요.');
      }
    } catch (e) {
      throw FriendFailure('초대 메일을 보내지 못했습니다. 잠시 후 다시 시도해주세요. (${e.toString()})');
    }
  }
}

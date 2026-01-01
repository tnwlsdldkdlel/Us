import 'dart:collection';

import 'package:us/models/friend.dart';
import 'package:us/models/friendship_status.dart';

class FriendCollections {
  const FriendCollections({
    required this.myFriends,
    required this.receivedRequests,
    required this.sentRequests,
  });

  final List<Friend> myFriends;
  final List<Friend> receivedRequests;
  final List<Friend> sentRequests;
}

enum FriendRequestAction { accept, decline }

enum FriendRequestResult { requestSent, inviteEmailSent }

abstract class FriendRepository {
  Future<FriendCollections> fetchFriendCollections();

  Future<List<Friend>> fetchAllFriends();

  Future<FriendRequestResult> sendFriendRequest(String email);

  Future<void> respondToRequest({
    required String friendshipId,
    required FriendRequestAction action,
  });

  Future<void> cancelFriendRequest(String friendshipId);

  Future<void> removeFriend(String friendshipId);
}

class MockFriendRepository implements FriendRepository {
  const MockFriendRepository();

  @override
  Future<FriendCollections> fetchFriendCollections() async {
    final received = _friends
        .where((friend) => friend.isIncomingRequest)
        .toList(growable: false);
    final sent = _friends
        .where((friend) => friend.isOutgoingRequest)
        .toList(growable: false);
    final my = _friends
        .where((friend) => friend.isFriend)
        .toList(growable: false);

    return FriendCollections(
      myFriends: UnmodifiableListView(my),
      receivedRequests: UnmodifiableListView(received),
      sentRequests: UnmodifiableListView(sent),
    );
  }

  @override
  Future<List<Friend>> fetchAllFriends() async => UnmodifiableListView(
    _friends.where((friend) => friend.isFriend).toList(),
  );

  @override
  Future<FriendRequestResult> sendFriendRequest(String email) async {
    return FriendRequestResult.requestSent;
  }

  @override
  Future<void> respondToRequest({
    required String friendshipId,
    required FriendRequestAction action,
  }) async {}

  @override
  Future<void> cancelFriendRequest(String friendshipId) async {}

  @override
  Future<void> removeFriend(String friendshipId) async {}

  static final List<Friend> _friends = [
    Friend(
      friendshipId: 'f1',
      userId: 'u1',
      name: '김수진',
      status: FriendshipStatus.accepted,
      isIncomingRequest: false,
      isOutgoingRequest: false,
    ),
    Friend(
      friendshipId: 'f2',
      userId: 'u2',
      name: '박도현',
      status: FriendshipStatus.requested,
      isIncomingRequest: true,
      isOutgoingRequest: false,
    ),
    Friend(
      friendshipId: 'f3',
      userId: 'u3',
      name: '이유나',
      status: FriendshipStatus.requested,
      isIncomingRequest: false,
      isOutgoingRequest: true,
    ),
    Friend(
      friendshipId: 'f4',
      userId: 'u4',
      name: '최현우',
      status: FriendshipStatus.accepted,
      isIncomingRequest: false,
      isOutgoingRequest: false,
    ),
    Friend(
      friendshipId: 'f5',
      userId: 'u5',
      name: '정유진',
      status: FriendshipStatus.accepted,
      isIncomingRequest: false,
      isOutgoingRequest: false,
    ),
    Friend(
      friendshipId: 'f6',
      userId: 'invitee@example.com',
      name: 'invitee@example.com',
      email: 'invitee@example.com',
      status: FriendshipStatus.invited,
      isIncomingRequest: false,
      isOutgoingRequest: true,
    ),
  ];
}

import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:us/models/friend.dart';

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

abstract class FriendRepository {
  FriendCollections fetchFriendCollections();

  List<Friend> fetchAllFriends();
}

class MockFriendRepository implements FriendRepository {
  const MockFriendRepository();

  @override
  FriendCollections fetchFriendCollections() {
    final received = _friends.take(2).toList(growable: false);
    final sent = _friends.skip(2).take(2).toList(growable: false);
    final my = _friends.skip(4).toList(growable: false);

    return FriendCollections(
      myFriends: UnmodifiableListView(my),
      receivedRequests: UnmodifiableListView(received),
      sentRequests: UnmodifiableListView(sent),
    );
  }

  @override
  List<Friend> fetchAllFriends() => UnmodifiableListView(_friends);

  static const List<Friend> _friends = [
    Friend(id: 'f1', name: '김수진', avatarColor: Color(0xFF10B981)),
    Friend(id: 'f2', name: '박도현', avatarColor: Color(0xFF6366F1)),
    Friend(id: 'f3', name: '이유나', avatarColor: Color(0xFFEC4899)),
    Friend(id: 'f4', name: '최현우', avatarColor: Color(0xFF0EA5E9)),
    Friend(id: 'f5', name: '정유진', avatarColor: Color(0xFFF97316)),
    Friend(id: 'f6', name: '강태민', avatarColor: Color(0xFF22C55E)),
    Friend(id: 'f7', name: '윤세라', avatarColor: Color(0xFF8B5CF6)),
    Friend(id: 'f8', name: '문주원', avatarColor: Color(0xFFF59E0B)),
    Friend(id: 'f9', name: '한지원', avatarColor: Color(0xFF06B6D4)),
    Friend(id: 'f10', name: '장하늘', avatarColor: Color(0xFFEF4444)),
  ];
}

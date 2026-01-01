import 'package:flutter/material.dart';

import 'package:us/models/friendship_status.dart';

class Friend {
  Friend({
    required this.friendshipId,
    required this.userId,
    required this.name,
    this.email,
    this.avatarUrl,
    Color? avatarColor,
    required this.status,
    required this.isIncomingRequest,
    required this.isOutgoingRequest,
  }) : avatarColor = avatarColor ?? generateAvatarColor(userId);

  /// Friendship row identifier.
  final String friendshipId;

  /// The other user's identifier.
  final String userId;

  final String name;
  final String? email;
  final String? avatarUrl;
  final Color avatarColor;
  final FriendshipStatus status;
  final bool isIncomingRequest;
  final bool isOutgoingRequest;

  bool get isFriend => status == FriendshipStatus.accepted;
  bool get isPending =>
      status == FriendshipStatus.requested ||
      status == FriendshipStatus.invited;
  bool get isRejected => status == FriendshipStatus.rejected;
  bool get isInvite => status == FriendshipStatus.invited;

  Friend copyWith({
    FriendshipStatus? status,
    bool? isIncomingRequest,
    bool? isOutgoingRequest,
  }) {
    return Friend(
      friendshipId: friendshipId,
      userId: userId,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      avatarColor: avatarColor,
      status: status ?? this.status,
      isIncomingRequest: isIncomingRequest ?? this.isIncomingRequest,
      isOutgoingRequest: isOutgoingRequest ?? this.isOutgoingRequest,
    );
  }
}

Color generateAvatarColor(String seed) {
  const palette = <Color>[
    Color(0xFF10B981),
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
    Color(0xFFF97316),
    Color(0xFF22C55E),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF06B6D4),
    Color(0xFFEF4444),
  ];

  if (seed.isEmpty) {
    return palette.first;
  }

  final hash = seed.codeUnits.fold<int>(0, (value, element) {
    value = ((value << 5) - value) + element;
    return value & value;
  }).abs();
  return palette[hash % palette.length];
}

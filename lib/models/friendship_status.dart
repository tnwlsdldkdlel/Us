enum FriendshipStatus { requested, accepted, rejected, invited }

FriendshipStatus parseFriendshipStatus(String value) {
  switch (value.toUpperCase()) {
    case 'REQUESTED':
      return FriendshipStatus.requested;
    case 'ACCEPTED':
      return FriendshipStatus.accepted;
    case 'REJECTED':
      return FriendshipStatus.rejected;
    case 'INVITED':
      return FriendshipStatus.invited;
    default:
      return FriendshipStatus.requested;
  }
}

String friendshipStatusToText(FriendshipStatus status) {
  switch (status) {
    case FriendshipStatus.requested:
      return 'REQUESTED';
    case FriendshipStatus.accepted:
      return 'ACCEPTED';
    case FriendshipStatus.rejected:
      return 'REJECTED';
    case FriendshipStatus.invited:
      return 'INVITED';
  }
}

String friendshipStatusLabel(FriendshipStatus status) {
  switch (status) {
    case FriendshipStatus.requested:
      return '요청됨';
    case FriendshipStatus.accepted:
      return '수락됨';
    case FriendshipStatus.rejected:
      return '거절됨';
    case FriendshipStatus.invited:
      return '초대됨';
  }
}

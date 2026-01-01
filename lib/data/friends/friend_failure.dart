class FriendFailure implements Exception {
  FriendFailure(this.message);

  final String message;

  @override
  String toString() => 'FriendFailure: $message';
}

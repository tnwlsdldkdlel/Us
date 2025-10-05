import 'package:flutter/foundation.dart';

import 'package:us/data/friends/friend_repository.dart';
import 'package:us/models/friend.dart';

@immutable
class FriendsState {
  const FriendsState({
    required this.isLoading,
    required this.query,
    required this.myFriends,
    required this.receivedRequests,
    required this.sentRequests,
    required this.filteredMyFriends,
    required this.filteredReceivedRequests,
    required this.filteredSentRequests,
  });

  const FriendsState.initial()
      : isLoading = true,
        query = '',
        myFriends = const [],
        receivedRequests = const [],
        sentRequests = const [],
        filteredMyFriends = const [],
        filteredReceivedRequests = const [],
        filteredSentRequests = const [];

  final bool isLoading;
  final String query;
  final List<Friend> myFriends;
  final List<Friend> receivedRequests;
  final List<Friend> sentRequests;
  final List<Friend> filteredMyFriends;
  final List<Friend> filteredReceivedRequests;
  final List<Friend> filteredSentRequests;

  FriendsState copyWith({
    bool? isLoading,
    String? query,
    List<Friend>? myFriends,
    List<Friend>? receivedRequests,
    List<Friend>? sentRequests,
    List<Friend>? filteredMyFriends,
    List<Friend>? filteredReceivedRequests,
    List<Friend>? filteredSentRequests,
  }) {
    return FriendsState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      myFriends: myFriends ?? this.myFriends,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      filteredMyFriends: filteredMyFriends ?? this.filteredMyFriends,
      filteredReceivedRequests:
          filteredReceivedRequests ?? this.filteredReceivedRequests,
      filteredSentRequests:
          filteredSentRequests ?? this.filteredSentRequests,
    );
  }
}

class FriendsViewModel extends ChangeNotifier {
  FriendsViewModel({required FriendRepository repository})
      : _repository = repository,
        _state = const FriendsState.initial();

  final FriendRepository _repository;
  FriendsState _state;

  FriendsState get state => _state;

  void loadFriends() {
    final collections = _repository.fetchFriendCollections();

    _state = FriendsState(
      isLoading: false,
      query: '',
      myFriends: collections.myFriends,
      receivedRequests: collections.receivedRequests,
      sentRequests: collections.sentRequests,
      filteredMyFriends: collections.myFriends,
      filteredReceivedRequests: collections.receivedRequests,
      filteredSentRequests: collections.sentRequests,
    );
    notifyListeners();
  }

  void updateQuery(String query) {
    final lowerQuery = query.trim().toLowerCase();

    List<Friend> filter(List<Friend> source) {
      if (lowerQuery.isEmpty) {
        return source;
      }
      return source
          .where((friend) => friend.name.toLowerCase().contains(lowerQuery))
          .toList(growable: false);
    }

    _state = _state.copyWith(
      query: query,
      filteredMyFriends: filter(_state.myFriends),
      filteredReceivedRequests: filter(_state.receivedRequests),
      filteredSentRequests: filter(_state.sentRequests),
    );
    notifyListeners();
  }
}

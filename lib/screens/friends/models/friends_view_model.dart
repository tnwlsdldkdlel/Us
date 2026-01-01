import 'package:flutter/foundation.dart';

import 'package:us/data/friends/friend_failure.dart';
import 'package:us/data/friends/friend_repository.dart';
import 'package:us/models/friend.dart';
import 'package:us/models/friendship_status.dart';

@immutable
class FriendsState {
  const FriendsState({
    required this.isLoading,
    required this.isProcessing,
    required this.query,
    required this.myFriends,
    required this.receivedRequests,
    required this.sentRequests,
    required this.filteredMyFriends,
    required this.filteredReceivedRequests,
    required this.filteredSentRequests,
    this.errorMessage,
  });

  const FriendsState.initial()
    : isLoading = true,
      isProcessing = false,
      query = '',
      myFriends = const [],
      receivedRequests = const [],
      sentRequests = const [],
      filteredMyFriends = const [],
      filteredReceivedRequests = const [],
      filteredSentRequests = const [],
      errorMessage = null;

  final bool isLoading;
  final bool isProcessing;
  final String query;
  final List<Friend> myFriends;
  final List<Friend> receivedRequests;
  final List<Friend> sentRequests;
  final List<Friend> filteredMyFriends;
  final List<Friend> filteredReceivedRequests;
  final List<Friend> filteredSentRequests;
  final String? errorMessage;

  FriendsState copyWith({
    bool? isLoading,
    bool? isProcessing,
    String? query,
    List<Friend>? myFriends,
    List<Friend>? receivedRequests,
    List<Friend>? sentRequests,
    List<Friend>? filteredMyFriends,
    List<Friend>? filteredReceivedRequests,
    List<Friend>? filteredSentRequests,
    String? Function()? errorMessage,
  }) {
    return FriendsState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      query: query ?? this.query,
      myFriends: myFriends ?? this.myFriends,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      filteredMyFriends: filteredMyFriends ?? this.filteredMyFriends,
      filteredReceivedRequests:
          filteredReceivedRequests ?? this.filteredReceivedRequests,
      filteredSentRequests: filteredSentRequests ?? this.filteredSentRequests,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
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

  Future<void> loadFriends() async {
    _state = _state.copyWith(isLoading: true, errorMessage: () => null);
    notifyListeners();

    try {
      final collections = await _repository.fetchFriendCollections();

      _state = FriendsState(
        isLoading: false,
        isProcessing: false,
        query: '',
        myFriends: collections.myFriends,
        receivedRequests: collections.receivedRequests,
        sentRequests: collections.sentRequests,
        filteredMyFriends: collections.myFriends,
        filteredReceivedRequests: collections.receivedRequests,
        filteredSentRequests: collections.sentRequests,
        errorMessage: null,
      );
    } on FriendFailure catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: () => error.message,
      );
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: () => '친구 목록을 불러오지 못했습니다.',
      );
    }
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

  Future<String?> sendFriendRequest(String email) async {
    return _performMutation(() async {
      final result = await _repository.sendFriendRequest(email);
      await loadFriends();
      return result == FriendRequestResult.inviteEmailSent
          ? '앱 초대 메일을 발송했습니다.'
          : '친구 요청을 보냈습니다.';
    });
  }

  Future<String?> acceptRequest(Friend friend) async {
    return _performMutation(() async {
      await _repository.respondToRequest(
        friendshipId: friend.friendshipId,
        action: FriendRequestAction.accept,
      );
      await loadFriends();
      return '친구 요청을 수락했습니다.';
    });
  }

  Future<String?> declineRequest(Friend friend) async {
    return _performMutation(() async {
      await _repository.respondToRequest(
        friendshipId: friend.friendshipId,
        action: FriendRequestAction.decline,
      );
      await loadFriends();
      return '친구 요청을 거절했습니다.';
    });
  }

  Future<String?> cancelRequest(Friend friend) async {
    return _performMutation(() async {
      await _repository.cancelFriendRequest(friend.friendshipId);
      await loadFriends();
      return friend.status == FriendshipStatus.invited
          ? '초대를 취소했습니다.'
          : '친구 요청을 취소했습니다.';
    });
  }

  Future<String?> removeFriend(Friend friend) async {
    return _performMutation(() async {
      await _repository.removeFriend(friend.friendshipId);
      await loadFriends();
      return '친구를 삭제했습니다.';
    });
  }

  Future<String?> _performMutation(Future<String?> Function() action) async {
    if (_state.isProcessing) {
      return null;
    }

    _state = _state.copyWith(isProcessing: true);
    notifyListeners();

    try {
      final message = await action();
      return message;
    } on FriendFailure catch (error) {
      return error.message;
    } catch (_) {
      return '요청을 처리하지 못했습니다. 잠시 후 다시 시도해주세요.';
    } finally {
      _state = _state.copyWith(isProcessing: false);
      notifyListeners();
    }
  }
}

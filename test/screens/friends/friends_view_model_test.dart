import 'package:flutter_test/flutter_test.dart';

import 'package:us/data/friends/friend_repository.dart';
import 'package:us/models/friend.dart';
import 'package:us/screens/friends/models/friends_view_model.dart';

void main() {
  group('FriendsViewModel', () {
    late FriendsViewModel viewModel;

    setUp(() {
      viewModel = FriendsViewModel(repository: const MockFriendRepository())
        ..loadFriends();
    });

    test('loads friends collections', () {
      final state = viewModel.state;

      expect(state.isLoading, isFalse);
      expect(state.myFriends, isNotEmpty);
      expect(state.receivedRequests, isNotEmpty);
      expect(state.sentRequests, isNotEmpty);
    });

    test('filters friends by query', () {
      viewModel.updateQuery('김');

      final state = viewModel.state;

      expect(
        state.filteredMyFriends,
        everyElement(predicate<Friend>((friend) => friend.name.contains('김'))),
      );
      expect(
        state.filteredReceivedRequests,
        everyElement(predicate<Friend>((friend) => friend.name.contains('김'))),
      );
      expect(
        state.filteredSentRequests,
        everyElement(predicate<Friend>((friend) => friend.name.contains('김'))),
      );
    });

    test('clearing query restores original lists', () {
      viewModel
        ..updateQuery('김')
        ..updateQuery('');

      final state = viewModel.state;

      expect(state.filteredMyFriends.length, state.myFriends.length);
      expect(state.filteredReceivedRequests.length,
          state.receivedRequests.length);
      expect(state.filteredSentRequests.length, state.sentRequests.length);
    });
  });
}

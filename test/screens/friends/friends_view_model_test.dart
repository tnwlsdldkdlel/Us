import 'package:flutter_test/flutter_test.dart';

import 'package:us/data/friends/friend_repository.dart';
import 'package:us/models/friend.dart';
import 'package:us/models/friendship_status.dart';
import 'package:us/screens/friends/models/friends_view_model.dart';

void main() {
  group('FriendsViewModel', () {
    late FriendsViewModel viewModel;

    setUp(() async {
      viewModel = FriendsViewModel(repository: const MockFriendRepository());
      await viewModel.loadFriends();
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
      expect(
        state.filteredReceivedRequests.length,
        state.receivedRequests.length,
      );
      expect(state.filteredSentRequests.length, state.sentRequests.length);
    });

    test('includes invited entries in sent requests', () {
      final state = viewModel.state;

      expect(
        state.sentRequests
            .where((friend) => friend.status == FriendshipStatus.invited)
            .isNotEmpty,
        isTrue,
      );
    });
    test('separates collections by status', () {
      final state = viewModel.state;

      expect(
        state.myFriends,
        everyElement(
          predicate<Friend>(
            (friend) => friend.status == FriendshipStatus.accepted,
          ),
        ),
      );
      expect(
        state.receivedRequests,
        everyElement(
          predicate<Friend>(
            (friend) => friend.status == FriendshipStatus.requested,
          ),
        ),
      );
      expect(
        state.sentRequests,
        everyElement(
          predicate<Friend>(
            (friend) =>
                friend.status == FriendshipStatus.requested ||
                friend.status == FriendshipStatus.invited,
          ),
        ),
      );
    });
  });
}

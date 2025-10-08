import 'package:flutter/material.dart';
import 'package:us/data/friends/friend_repository.dart';
import 'package:us/models/friend.dart';
import 'package:us/screens/friends/models/friends_view_model.dart';
import 'package:us/theme/us_colors.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key, FriendRepository? friendRepository})
    : friendRepository = friendRepository ?? const MockFriendRepository();

  final FriendRepository friendRepository;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late final TextEditingController _searchController;
  late final FriendsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _viewModel = FriendsViewModel(repository: widget.friendRepository)
      ..loadFriends();
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _viewModel.updateQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;

        return DefaultTabController(
          length: 3,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: '친구 검색하세요',
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF9CA3AF),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const TabBar(
                      dividerColor: Colors.grey,
                      indicatorColor: UsColors.primary,
                      labelColor: UsColors.primary,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(text: '친구'),
                        Tab(text: '받은 요청'),
                        Tab(text: '보낸 요청'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildFriendList(
                            state.filteredMyFriends,
                            isLoading: state.isLoading,
                          ),
                          _buildRequestList(
                            state.filteredReceivedRequests,
                            isLoading: state.isLoading,
                          ),
                          _buildSentRequestList(
                            state.filteredSentRequests,
                            isLoading: state.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (state.isLoading)
                  const Align(
                    alignment: Alignment.topCenter,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFriendList(List<Friend> friends, {bool isLoading = false}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (friends.isEmpty) {
      return const Center(child: Text('친구가 없습니다.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        return _FriendTile(friend: friends[index]);
      },
    );
  }

  Widget _buildRequestList(List<Friend> requests, {bool isLoading = false}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (requests.isEmpty) {
      return const Center(child: Text('받은 친구 요청이 없습니다.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _FriendRequestTile(friend: requests[index]);
      },
    );
  }

  Widget _buildSentRequestList(
    List<Friend> requests, {
    bool isLoading = false,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (requests.isEmpty) {
      return const Center(child: Text('보낸 친구 요청이 없습니다.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _SentRequestTile(friend: requests[index]);
      },
    );
  }
}

class _FriendRequestTile extends StatelessWidget {
  const _FriendRequestTile({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: friend.avatarColor,
            child: Text(
              friend.name.characters.first,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.name,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFE5E7EB),
              foregroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('거절'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: UsColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('수락'),
          ),
        ],
      ),
    );
  }
}

class _SentRequestTile extends StatelessWidget {
  const _SentRequestTile({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: friend.avatarColor,
            child: Text(
              friend.name.characters.first,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.name,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.close_rounded),
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friend});

  final Friend friend;

  void _showDeleteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.radiusLarge),
        ),
      ),
      builder: (context) {
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '친구를 삭제하시겠어요?',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingL),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5E7EB),
                    foregroundColor: theme.colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppRadius.radiusMedium,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spacingS),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppRadius.radiusMedium,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '삭제',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: friend.avatarColor,
            child: Text(
              friend.name.characters.first,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  friend.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showDeleteSheet(context),
            icon: const Icon(Icons.close_rounded),
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:us/data/friends/friend_repository.dart';
import 'package:us/data/friends/supabase_friend_repository.dart';
import 'package:us/models/friend.dart';
import 'package:us/models/friendship_status.dart';
import 'package:us/screens/friends/models/friends_view_model.dart';
import 'package:us/theme/us_colors.dart';

class FriendsScreen extends StatefulWidget {
  FriendsScreen({super.key, FriendRepository? friendRepository})
    : friendRepository = friendRepository ?? SupabaseFriendRepository();

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
    _viewModel = FriendsViewModel(repository: widget.friendRepository);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _viewModel.loadFriends(),
    );
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

  Future<void> _refresh() => _viewModel.loadFriends();

  Future<void> _promptAddFriend() async {
    final viewState = _viewModel.state;
    if (viewState.isProcessing) {
      return;
    }

    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('친구 요청 보내기'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '이메일 주소',
              hintText: 'friend@example.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('요청 보내기'),
            ),
          ],
        );
      },
    );

    if (email == null || email.isEmpty || !mounted) {
      return;
    }

    final message = await _viewModel.sendFriendRequest(email);
    if (!mounted || message == null) {
      return;
    }
    _showSnack(message);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: state.isProcessing
                                  ? null
                                  : _promptAddFriend,
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              label: const Text('친구 요청 보내기'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE4E6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.errorMessage!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: const Color(0xFFB91C1C),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                            state.isLoading,
                            state.isProcessing,
                          ),
                          _buildRequestList(
                            state.filteredReceivedRequests,
                            state.isLoading,
                            state.isProcessing,
                          ),
                          _buildSentRequestList(
                            state.filteredSentRequests,
                            state.isLoading,
                            state.isProcessing,
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

  Widget _buildFriendList(
    List<Friend> friends,
    bool isLoading,
    bool isProcessing,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friends.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Center(child: Text('친구가 없습니다.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return _FriendTile(
            friend: friend,
            isProcessing: isProcessing,
            onRemove: () async {
              final message = await _viewModel.removeFriend(friend);
              if (!mounted || message == null) {
                return;
              }
              _showSnack(message);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestList(
    List<Friend> incoming,
    bool isLoading,
    bool isProcessing,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (incoming.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Center(child: Text('받은 친구 요청이 없습니다.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: incoming.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final friend = incoming[index];
          return _FriendRequestTile(
            friend: friend,
            isProcessing: isProcessing,
            onAccept: () async {
              final message = await _viewModel.acceptRequest(friend);
              if (!mounted || message == null) {
                return;
              }
              _showSnack(message);
            },
            onDecline: () async {
              final message = await _viewModel.declineRequest(friend);
              if (!mounted || message == null) {
                return;
              }
              _showSnack(message);
            },
          );
        },
      ),
    );
  }

  Widget _buildSentRequestList(
    List<Friend> outgoing,
    bool isLoading,
    bool isProcessing,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (outgoing.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Center(child: Text('보낸 친구 요청이 없습니다.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: outgoing.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final friend = outgoing[index];
          return _SentRequestTile(
            friend: friend,
            isProcessing: isProcessing,
            onCancel: () async {
              final message = await _viewModel.cancelRequest(friend);
              if (!mounted || message == null) {
                return;
              }
              _showSnack(message);
            },
          );
        },
      ),
    );
  }
}

class _FriendRequestTile extends StatelessWidget {
  const _FriendRequestTile({
    required this.friend,
    required this.isProcessing,
    required this.onAccept,
    required this.onDecline,
  });

  final Friend friend;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                _FriendStatusBadge(status: friend.status),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: isProcessing ? null : onDecline,
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
            onPressed: isProcessing ? null : onAccept,
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
  const _SentRequestTile({
    required this.friend,
    required this.isProcessing,
    required this.onCancel,
  });

  final Friend friend;
  final bool isProcessing;
  final VoidCallback onCancel;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                _FriendStatusBadge(status: friend.status),
              ],
            ),
          ),
          IconButton(
            onPressed: isProcessing ? null : onCancel,
            icon: const Icon(Icons.close_rounded),
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({
    required this.friend,
    required this.isProcessing,
    required this.onRemove,
  });

  final Friend friend;
  final bool isProcessing;
  final VoidCallback onRemove;

  void _confirmDeletion(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.radiusLarge),
        ),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
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
                ),
              ),
              const SizedBox(height: AppSpacing.spacingL),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
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
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(height: AppSpacing.spacingS),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () {
                          Navigator.of(sheetContext).pop();
                          onRemove();
                        },
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
                  child: const Text('삭제'),
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
    final subtitle = friend.email ?? '연결된 이메일 없음';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: friend.avatarColor,
            backgroundImage: friend.avatarUrl != null
                ? NetworkImage(friend.avatarUrl!)
                : null,
            child: friend.avatarUrl == null
                ? Text(
                    friend.name.characters.first,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        friend.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _FriendStatusBadge(status: friend.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isProcessing ? null : () => _confirmDeletion(context),
            icon: const Icon(Icons.close_rounded),
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }
}

class _FriendStatusBadge extends StatelessWidget {
  const _FriendStatusBadge({super.key, required this.status});

  final FriendshipStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _badgeColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        friendshipStatusLabel(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BadgeColors {
  const _BadgeColors(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

_BadgeColors _badgeColors(FriendshipStatus status) {
  switch (status) {
    case FriendshipStatus.requested:
      return const _BadgeColors(Color(0xFFDBEAFE), Color(0xFF1D4ED8));
    case FriendshipStatus.accepted:
      return const _BadgeColors(Color(0xFFDCFCE7), Color(0xFF15803D));
    case FriendshipStatus.rejected:
      return const _BadgeColors(Color(0xFFFEE2E2), Color(0xFFB91C1C));
    case FriendshipStatus.invited:
      return const _BadgeColors(Color(0xFFFDE68A), Color(0xFFB45309));
  }
}

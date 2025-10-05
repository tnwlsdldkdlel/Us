import 'package:flutter/material.dart';
import 'package:us/data/mock_friends.dart';
import 'package:us/models/friend.dart';
import 'package:us/screens/home/widgets/section.dart';
import 'package:us/theme/us_colors.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late final TextEditingController _searchController;
  List<Friend> _myFriends = [];
  List<Friend> _receivedRequests = [];
  List<Friend> _sentRequests = [];

  List<Friend> _filteredMyFriends = [];
  List<Friend> _filteredReceivedRequests = [];
  List<Friend> _filteredSentRequests = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterLists);

    // Mock data for demonstration
    _receivedRequests = mockFriends.sublist(0, 2);
    _sentRequests = mockFriends.sublist(2, 4);
    _myFriends = mockFriends.sublist(4);

    _filteredReceivedRequests = List.of(_receivedRequests);
    _filteredSentRequests = List.of(_sentRequests);
    _filteredMyFriends = List.of(_myFriends);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLists);
    _searchController.dispose();
    super.dispose();
  }

  void _filterLists() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMyFriends = _myFriends
          .where((f) => f.name.toLowerCase().contains(query))
          .toList();
      _filteredReceivedRequests = _receivedRequests
          .where((f) => f.name.toLowerCase().contains(query))
          .toList();
      _filteredSentRequests = _sentRequests
          .where((f) => f.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
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
                  _buildFriendList(_filteredMyFriends),
                  _buildRequestList(_filteredReceivedRequests),
                  _buildSentRequestList(_filteredSentRequests),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendList(List<Friend> friends) {
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

  Widget _buildRequestList(List<Friend> requests) {
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

  Widget _buildSentRequestList(List<Friend> requests) {
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
            icon: const Icon(Icons.delete),
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
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:us/data/mock_friends.dart';
import 'package:us/models/friend.dart';
import 'package:us/theme/us_colors.dart';

class PeoplePickerBottomSheet extends StatefulWidget {
  const PeoplePickerBottomSheet({super.key, this.initialSelected});

  final List<Friend>? initialSelected;

  @override
  State<PeoplePickerBottomSheet> createState() =>
      _PeoplePickerBottomSheetState();
}

class _PeoplePickerBottomSheetState extends State<PeoplePickerBottomSheet> {
  late final TextEditingController _controller;
  late final List<Friend> _friends;
  final Set<String> _selectedIds = {};
  List<Friend> _filtered = const [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _friends = List.of(mockFriends);
    if (widget.initialSelected != null) {
      _selectedIds.addAll(widget.initialSelected!.map((f) => f.id));
    }
    _applyFilter();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _applyFilter);
  }

  void _applyFilter() {
    final query = _controller.text.trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = _friends;
      } else {
        final lower = query.toLowerCase();
        _filtered = _friends
            .where((friend) => friend.name.toLowerCase().contains(lower))
            .toList();
      }
    });
  }

  void _toggleSelection(Friend friend) {
    setState(() {
      if (_selectedIds.contains(friend.id)) {
        _selectedIds.remove(friend.id);
      } else {
        _selectedIds.add(friend.id);
      }
    });
  }

  void _submitSelection(BuildContext context) {
    final selectedFriends = _friends
        .where((friend) => _selectedIds.contains(friend.id))
        .toList(growable: false);
    Navigator.of(context).pop(selectedFriends);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = _selectedIds.length;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
                Text(
                  '친구 목록',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: selectedCount > 0
                      ? () => _submitSelection(context)
                      : null,
                  child: Text(
                    '추가 (${selectedCount.toString()})',
                    style: TextStyle(
                      color: selectedCount > 0
                          ? UsColors.primary
                          : const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _controller,
              autofocus: false,
              onTap: () => _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              ),
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '친구 검색',
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          _applyFilter();
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF6B7280),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) {
                  FocusScope.of(context).unfocus();
                }
                return false;
              },
              child: _filtered.isEmpty
                  ? const Center(child: Text('친구를 찾을 수 없어요.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final friend = _filtered[index];
                        final isSelected = _selectedIds.contains(friend.id);
                        return _FriendTile(
                          friend: friend,
                          isSelected: isSelected,
                          onTap: () => _toggleSelection(friend),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({
    required this.friend,
    required this.isSelected,
    required this.onTap,
  });

  final Friend friend;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? UsColors.primary : const Color(0xFFE5E7EB),
              width: 2,
            ),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: friend.avatarColor,
                child: Text(
                  friend.name.characters.first,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  friend.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded, color: UsColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

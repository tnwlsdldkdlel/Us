import 'package:flutter/material.dart';

import 'package:us/models/friend.dart';
import 'package:us/theme/us_colors.dart';

class ParticipantSection extends StatelessWidget {
  const ParticipantSection({
    super.key,
    required this.friends,
    required this.onAdd,
    required this.onRemove,
  });

  final List<Friend> friends;
  final VoidCallback onAdd;
  final ValueChanged<Friend> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _FieldLabel(text: '참여자')),
            _AddParticipantButton(onTap: onAdd),
          ],
        ),
        const SizedBox(height: 12),
        if (friends.isEmpty)
          Text(
            '현재 추가된 친구가 없어요.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          )
        else
          Column(
            children: [
              for (final friend in friends)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SelectedFriendTile(
                    friend: friend,
                    onRemove: () => onRemove(friend),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
      ),
    );
  }
}

class _AddParticipantButton extends StatelessWidget {
  const _AddParticipantButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: UsColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '+ 참여자 추가',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SelectedFriendTile extends StatelessWidget {
  const _SelectedFriendTile({required this.friend, required this.onRemove});

  final Friend friend;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UsColors.primary, width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: friend.avatarColor,
            child: Text(
              friend.name.characters.first,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              color: UsColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

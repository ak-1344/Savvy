import 'package:flutter/material.dart';

class EmojiPicker extends StatelessWidget {
  final String selectedEmoji;
  final Function(String) onEmojiSelected;

  const EmojiPicker({
    Key? key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  }) : super(key: key);

  static const List<String> _commonEmojis = [
    '📁', '🏠', '🍔', '🛍️', '💰', '🎮', '🚗', '✈️',
    '💊', '📚', '🎵', '🎬', '👕', '💅', '🏋️', '🎨',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _commonEmojis.map((emoji) {
        return InkWell(
          onTap: () => onEmojiSelected(emoji),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: emoji == selectedEmoji
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      }).toList(),
    );
  }
} 
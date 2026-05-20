import 'package:flutter/material.dart';

class StreakBadge extends StatelessWidget {
  final int streakDays;
  const StreakBadge({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = streakDays > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.secondary.withValues(alpha: 0.15)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.secondary.withValues(alpha: 0.5)
              : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isActive ? '🔥' : '💤',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? '$streakDays day streak' : 'No streak',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? theme.colorScheme.secondary : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
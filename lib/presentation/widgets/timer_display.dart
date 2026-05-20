import 'package:flutter/material.dart';
import '../../data/models/game_settings.dart';

class TimerDisplay extends StatelessWidget {
  final TimerMode timerMode;
  final int? remainingSeconds;
  final int elapsedMs;
  final int totalSeconds;

  const TimerDisplay({
    super.key,
    required this.timerMode,
    required this.remainingSeconds,
    required this.elapsedMs,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (timerMode == TimerMode.countdown) {
      final rem = remainingSeconds ?? totalSeconds;
      final pct = rem / totalSeconds;
      final isUrgent = pct < 0.25;
      final color = isUrgent
          ? theme.colorScheme.error
          : pct < 0.5
              ? theme.colorScheme.secondary
              : theme.colorScheme.primary;

      return Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: theme.textTheme.displayMedium!.copyWith(color: color),
            child: Text('${rem}s'),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      );
    } else {
      // Stopwatch
      final totalSecs = elapsedMs ~/ 1000;
      final mins = totalSecs ~/ 60;
      final secs = totalSecs % 60;
      final cs = (elapsedMs % 1000) ~/ 10;

      return Text(
        '${mins.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}.'
        '${cs.toString().padLeft(2, '0')}',
        style: theme.textTheme.displayMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
    }
  }
}
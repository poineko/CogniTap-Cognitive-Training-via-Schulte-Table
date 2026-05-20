import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/game_settings.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/repositories/score_repository.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  static const _levels = [
    _LevelData(
      level: 1,
      title: 'ROOKIE',
      subtitle: 'Warm up your visual cortex',
      gridSize: 3,
      seconds: 20,
      icon: Icons.looks_one_rounded,
    ),
    _LevelData(
      level: 2,
      title: 'FOCUSED',
      subtitle: 'Expand your visual span',
      gridSize: 4,
      seconds: 40,
      icon: Icons.looks_two_rounded,
    ),
    _LevelData(
      level: 3,
      title: 'SHARP',
      subtitle: 'Selective attention under noise',
      gridSize: 5,
      seconds: 60,
      icon: Icons.looks_3_rounded,
      hasInterference: true,
    ),
    _LevelData(
      level: 4,
      title: 'ELITE',
      subtitle: 'Peak cognitive load challenge',
      gridSize: 6,
      seconds: 90,
      icon: Icons.looks_4_rounded,
      hasInterference: true,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scoresAsync = ref.watch(allHighScoresProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('SELECT LEVEL', style: theme.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _levels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final lvl = _levels[i];
          return scoresAsync.when(
            data: (scores) => _LevelCard(
              data: lvl,
              highScore: scores[lvl.gridSize],
              onTap: () => _startLevel(context, ref, lvl),
            ),
            loading: () => _LevelCard(data: lvl, onTap: () => _startLevel(context, ref, lvl)),
            error: (_, __) => _LevelCard(data: lvl, onTap: () => _startLevel(context, ref, lvl)),
          );
        },
      ),
    );
  }

  void _startLevel(BuildContext context, WidgetRef ref, _LevelData lvl) {
    final settings = GameSettings(
      gridSize: lvl.gridSize,
      timerMode: TimerMode.countdown,
      countdownSeconds: lvl.seconds,
      isInterferenceModeActive: lvl.hasInterference,
    );
    ref.read(settingsProvider.notifier).update(settings);
    ref.read(gameProvider.notifier).initGame(settings);
    context.push('/game');
  }
}

class _LevelCard extends StatelessWidget {
  final _LevelData data;
  final double? highScore;
  final VoidCallback onTap;

  const _LevelCard({required this.data, required this.onTap, this.highScore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
    ];
    final accent = colors[(data.level - 1) % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Level Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: accent, size: 28),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'LV${data.level} — ${data.title}',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: accent),
                      ),
                      if (data.hasInterference) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'DISTRACTION',
                            style: TextStyle(
                              fontSize: 9,
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(data.subtitle, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Pill(
                          label: '${data.gridSize}×${data.gridSize}',
                          icon: Icons.grid_4x4),
                      const SizedBox(width: 8),
                      _Pill(
                          label: '${data.seconds}s',
                          icon: Icons.timer_outlined),
                      if (highScore != null) ...[
                        const SizedBox(width: 8),
                        _Pill(
                          label: '🏆 ${highScore!.toStringAsFixed(1)}s',
                          icon: null,
                          isHighlight: true,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: accent.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isHighlight;
  const _Pill({required this.label, this.icon, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isHighlight
            ? theme.colorScheme.secondary.withValues(alpha: 0.15)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: Colors.white54),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isHighlight
                  ? theme.colorScheme.secondary
                  : Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelData {
  final int level;
  final String title;
  final String subtitle;
  final int gridSize;
  final int seconds;
  final IconData icon;
  final bool hasInterference;
  const _LevelData({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.gridSize,
    required this.seconds,
    required this.icon,
    this.hasInterference = false,
  });
}


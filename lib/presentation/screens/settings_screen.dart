import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/game_settings.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('SETTINGS', style: theme.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Grid Size
          const _SectionHeader(title: 'Grid Size'),
          const SizedBox(height: 12),
          Row(
            children: [3, 4, 5, 6].map((size) {
              final isSelected = settings.gridSize == size;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () =>
                        notifier.update(settings.copyWith(gridSize: size)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.white12,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$size×$size',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : Colors.white60,
                            ),
                          ),
                          Text(
                            '${size * size} nums',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                                  : Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // ── Timer Mode
          const _SectionHeader(title: 'Timer Mode'),
          const SizedBox(height: 12),
          _ToggleRow(
            label: 'Countdown',
            subtitle: 'Race against the clock',
            icon: Icons.timer_outlined,
            isSelected: settings.timerMode == TimerMode.countdown,
            onTap: () => notifier
                .update(settings.copyWith(timerMode: TimerMode.countdown)),
          ),
          const SizedBox(height: 8),
          _ToggleRow(
            label: 'Stopwatch',
            subtitle: 'Complete at your own pace',
            icon: Icons.hourglass_empty_rounded,
            isSelected: settings.timerMode == TimerMode.stopwatch,
            onTap: () => notifier
                .update(settings.copyWith(timerMode: TimerMode.stopwatch)),
          ),

          if (settings.timerMode == TimerMode.countdown) ...[
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Countdown Duration'),
            const SizedBox(height: 12),
            Row(
              children: [20, 30, 45, 60, 90].map((secs) {
                final isSelected = settings.countdownSeconds == secs;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => notifier
                          .update(settings.copyWith(countdownSeconds: secs)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.white12,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${secs}s',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : Colors.white60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 28),

          // ── Interference Mode
          const _SectionHeader(
            title: 'Interference Mode',
            badge: 'ADVANCED',
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              value: settings.isInterferenceModeActive,
              onChanged: (val) => notifier
                  .update(settings.copyWith(isInterferenceModeActive: val)),
              title: Text(
                'Enable Distraction',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
              subtitle: Text(
                'Changing cell colors test your selective attention (Stroop Effect)',
                style: theme.textTheme.bodyMedium,
              ),
              activeThumbColor: theme.colorScheme.primary,
              activeTrackColor:
                  theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? badge;
  const _SectionHeader({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(title,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: Colors.white54, letterSpacing: 1.5)),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                  fontSize: 9,
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ]
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _ToggleRow(
      {required this.label,
      required this.subtitle,
      required this.icon,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? theme.colorScheme.primary : Colors.white38),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.white,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

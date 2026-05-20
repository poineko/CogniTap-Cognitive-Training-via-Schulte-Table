import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/game_settings.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';

class CustomModeScreen extends ConsumerStatefulWidget {
  const CustomModeScreen({super.key});

  @override
  ConsumerState<CustomModeScreen> createState() => _CustomModeScreenState();
}

class _CustomModeScreenState extends ConsumerState<CustomModeScreen> {
  int _gridSize = 4;
  TimerMode _timerMode = TimerMode.stopwatch;
  int _countdownSeconds = 30;
  bool _interferenceMode = false;

  void _startGame() {
    final settings = GameSettings(
      gridSize: _gridSize,
      timerMode: _timerMode,
      countdownSeconds: _countdownSeconds,
      isInterferenceModeActive: _interferenceMode,
    );
    ref.read(settingsProvider.notifier).update(settings);
    ref.read(gameProvider.notifier).initGame(settings);
    context.push('/game');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('CUSTOM MODE', style: theme.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Preview Card
          _PreviewCard(
            gridSize: _gridSize,
            timerMode: _timerMode,
            countdownSeconds: _countdownSeconds,
            interferenceMode: _interferenceMode,
          ),

          const SizedBox(height: 28),

          // ── Grid Size
          _SectionLabel(label: 'GRID SIZE'),
          const SizedBox(height: 12),
          Row(
            children: [3, 4, 5, 6].map((size) {
              final isSelected = _gridSize == size;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _gridSize = size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.white12,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$size×$size',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${size * size} nums',
                            style: TextStyle(
                              fontSize: 11,
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
          _SectionLabel(label: 'TIMER MODE'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ModeToggle(
                  label: 'Stopwatch',
                  subtitle: 'No time limit',
                  icon: Icons.hourglass_empty_rounded,
                  isSelected: _timerMode == TimerMode.stopwatch,
                  onTap: () => setState(() => _timerMode = TimerMode.stopwatch),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModeToggle(
                  label: 'Countdown',
                  subtitle: 'Race the clock',
                  icon: Icons.timer_outlined,
                  isSelected: _timerMode == TimerMode.countdown,
                  onTap: () => setState(() => _timerMode = TimerMode.countdown),
                ),
              ),
            ],
          ),

          // ── Countdown Duration (hanya tampil jika countdown)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _timerMode == TimerMode.countdown
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _SectionLabel(label: 'DURATION'),
                      const SizedBox(height: 8),
                      Text(
                        '${_countdownSeconds}s',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Slider(
                        value: _countdownSeconds.toDouble(),
                        min: 10,
                        max: 120,
                        divisions: 11,
                        // Snap ke nilai: 10,20,30,40,50,60,70,80,90,100,110,120
                        activeColor: theme.colorScheme.primary,
                        inactiveColor: Colors.white12,
                        label: '${_countdownSeconds}s',
                        onChanged: (val) =>
                            setState(() => _countdownSeconds = val.toInt()),
                      ),
                      // Preset cepat
                      Row(
                        children: [15, 30, 45, 60, 90].map((s) {
                          final isActive = _countdownSeconds == s;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _countdownSeconds = s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? theme.colorScheme.primary
                                          .withValues(alpha: 0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isActive
                                        ? theme.colorScheme.primary
                                        : Colors.white12,
                                  ),
                                ),
                                child: Text(
                                  '${s}s',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? theme.colorScheme.primary
                                        : Colors.white38,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),

          const SizedBox(height: 28),

          // ── Interference Mode
          _SectionLabel(label: 'INTERFERENCE MODE'),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: _interferenceMode,
              onChanged: (val) => setState(() => _interferenceMode = val),
              title: Text(
                'Enable Visual Distraction',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.white),
              ),
              subtitle: Text(
                'Cell colors shift randomly — trains selective attention (Stroop Effect)',
                style: theme.textTheme.bodyMedium,
              ),
              thumbColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? theme.colorScheme.primary
                      : Colors.white38),
              trackColor: WidgetStateProperty.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? theme.colorScheme.primary.withValues(alpha: 0.4)
                      : Colors.white12),
            ),
          ),

          const SizedBox(height: 40),

          // ── Start Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startGame,
              child: const Text('START CUSTOM GAME'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

/// Preview card yang update real-time sesuai settings.
class _PreviewCard extends StatelessWidget {
  final int gridSize;
  final TimerMode timerMode;
  final int countdownSeconds;
  final bool interferenceMode;

  const _PreviewCard({
    required this.gridSize,
    required this.timerMode,
    required this.countdownSeconds,
    required this.interferenceMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Mini grid preview
          SizedBox(
            width: 72,
            height: 72,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Config summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$gridSize × $gridSize Grid',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timerMode == TimerMode.stopwatch
                      ? '⏱ Stopwatch mode'
                      : '⏳ Countdown: ${countdownSeconds}s',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  interferenceMode
                      ? '⚡ Distraction ON'
                      : '🧘 Focus mode',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: interferenceMode
                        ? theme.colorScheme.error
                        : Colors.white38,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${gridSize * gridSize} numbers to tap',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeToggle({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color:
                  isSelected ? theme.colorScheme.primary : Colors.white38,
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(subtitle, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white38,
            letterSpacing: 1.8,
            fontSize: 12,
          ),
    );
  }
}
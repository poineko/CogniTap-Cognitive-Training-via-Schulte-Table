import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/game_provider.dart';
import '../widgets/number_cell.dart';
import '../widgets/timer_display.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final theme = Theme.of(context);

    // Navigasi otomatis ke result screen
    ref.listen(gameProvider, (prev, next) {
      if (next.phase == GamePhase.completed || next.phase == GamePhase.failed) {
        if (next.currentSession != null) {
          context.pushReplacement('/result', extra: next.currentSession);
        }
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ref.read(gameProvider.notifier).resetGame();
            context.pop();
          },
        ),
        title: _GridSizeLabel(gridSize: game.settings.gridSize),
        centerTitle: true,
        actions: [
          if (game.settings.isInterferenceModeActive)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: const Text('⚡ DISTRACTION',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                backgroundColor:
                    theme.colorScheme.error.withValues(alpha: 0.2),
                side: BorderSide.none,
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ── Timer
              TimerDisplay(
                timerMode: game.settings.timerMode,
                remainingSeconds: game.remainingSeconds,
                elapsedMs: game.elapsedMs,
                totalSeconds: game.settings.countdownSeconds,
              ),

              const SizedBox(height: 24),

              // ── Next Number Prompt
              _NextNumberPrompt(nextNumber: game.nextExpectedNumber),

              const SizedBox(height: 24),

              // ── Schulte Grid
              Expanded(
                child: Center(
                  child: SchulteGrid(
                    gridNumbers: game.gridNumbers,
                    gridSize: game.settings.gridSize,
                    nextExpectedNumber: game.nextExpectedNumber,
                    lastCorrectIndex: game.lastCorrectIndex,
                    lastWrongIndex: game.lastWrongIndex,
                    distractionColors: game.distractionColors,
                    onCellTapped: (number) =>
                        ref.read(gameProvider.notifier).onCellTapped(number),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Progress Bar
              _ProgressBar(
                current: game.nextExpectedNumber - 1,
                total: game.settings.visualSpanGridCount,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridSizeLabel extends StatelessWidget {
  final int gridSize;
  const _GridSizeLabel({required this.gridSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$gridSize×$gridSize GRID',
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _NextNumberPrompt extends StatelessWidget {
  final int nextNumber;
  const _NextNumberPrompt({required this.nextNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'FIND  ',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Text(
            '$nextNumber',
            key: ValueKey(nextNumber),
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = total == 0 ? 0.0 : current / total;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$current / $total',
                style: theme.textTheme.bodyMedium),
            Text('${(pct * 100).toInt()}%',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

// ─── SchulteGrid Widget ───────────────────────────────────────────────────────

class SchulteGrid extends StatelessWidget {
  final List<int> gridNumbers;
  final int gridSize;
  final int nextExpectedNumber;
  final int? lastCorrectIndex;
  final int? lastWrongIndex;
  final List<Color>? distractionColors;
  final void Function(int) onCellTapped;

  const SchulteGrid({
    super.key,
    required this.gridNumbers,
    required this.gridSize,
    required this.nextExpectedNumber,
    required this.onCellTapped,
    this.lastCorrectIndex,
    this.lastWrongIndex,
    this.distractionColors,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: gridNumbers.length,
        itemBuilder: (context, index) {
          final number = gridNumbers[index];
          final alreadyTapped = number < nextExpectedNumber;

          CellState cellState;
          if (index == lastCorrectIndex) {
            cellState = CellState.correct;
          } else if (index == lastWrongIndex) {
            cellState = CellState.wrong;
          } else if (alreadyTapped) {
            cellState = CellState.alreadyTapped;
          } else {
            cellState = CellState.idle;
          }

          return NumberCell(
            number: number,
            cellState: cellState,
            distractionColor: distractionColors?[index],
            onTap: () => onCellTapped(number),
          );
        },
      ),
    );
  }
}
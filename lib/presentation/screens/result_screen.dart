import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/game_session.dart';
import '../../core/utils/csv_exporter.dart';
import '../../core/constants/cognitive_constants.dart';
import '../../data/repositories/score_repository.dart';
import '../../providers/streak_provider.dart';
import '../widgets/performance_summary.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final GameSession session;
  const ResultScreen({super.key, required this.session});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _isNewRecord = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _checkAndSaveRecord();
    ref.read(streakProvider.notifier).recordTodaySession();
  }

  Future<void> _checkAndSaveRecord() async {
    if (!widget.session.isCompleted) return;
    final scoreRepo = ref.read(scoreRepositoryProvider);
    final isNew = await scoreRepo.updateHighScoreIfBetter(
      widget.session.gridSize,
      widget.session.totalDurationSeconds,
    );
    if (mounted) setState(() => _isNewRecord = isNew);
  }

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      await CsvExporter.exportSession(widget.session);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.session.isCompleted;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              _ResultBadge(
                isCompleted: isCompleted,
                isNewRecord: _isNewRecord,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _InfoChip(
                    label:
                        '${widget.session.gridSize}×${widget.session.gridSize}',
                    icon: Icons.grid_4x4,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    label: '${widget.session.tapLog.length} taps',
                    icon: Icons.touch_app,
                  ),
                  if (widget.session.isInterferenceModeActive) ...[
                    const SizedBox(width: 8),
                    _InfoChip(
                      label: 'Distraction',
                      icon: Icons.bolt,
                      isWarning: true,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              PerformanceSummary(session: widget.session),
              const SizedBox(height: 16),
              if (widget.session.tapLog.isNotEmpty)
                _TapTimelineCard(session: widget.session),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('PLAY AGAIN'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/analytics'),
                      icon: const Icon(Icons.show_chart, size: 18),
                      label: const Text('Analytics'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isExporting ? null : _exportCsv,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_rounded, size: 18),
                      label: Text(_isExporting ? 'Exporting...' : 'Export CSV'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _ResultBadge extends StatelessWidget {
  final bool isCompleted;
  final bool isNewRecord;
  const _ResultBadge({required this.isCompleted, required this.isNewRecord});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCompleted
        ? theme.colorScheme.tertiary
        : theme.colorScheme.error;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : Icons.timer_off_rounded,
            size: 48,
            color: color,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isCompleted ? 'COMPLETE!' : 'TIME UP',
          style: theme.textTheme.displayMedium?.copyWith(color: color),
        ),
        if (isNewRecord) ...[
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              '🏆  NEW RECORD',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isWarning;
  const _InfoChip({
    required this.label,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isWarning ? theme.colorScheme.error : Colors.white.withValues(alpha: 0.38);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini bar chart: visualisasi reaction time tiap ketukan yang benar.
/// Pola bar yang tidak konsisten = tanda cognitive fatigue di tengah sesi.
class _TapTimelineCard extends StatelessWidget {
  final GameSession session;
  const _TapTimelineCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final correctTaps = session.tapLog
        .where((t) => t.isCorrect && t.reactionTimeMs != null)
        .toList();

    if (correctTaps.isEmpty) return const SizedBox();

    final maxRt = correctTaps
        .map((t) => t.reactionTimeMs!)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    final safeMax = maxRt > 0 ? maxRt : 1.0;

    // Build bar list terpisah — hindari inline map di dalam children[]
    final bars = <Widget>[];
    for (final tap in correctTaps) {
      final pct = tap.reactionTimeMs! / safeMax;
      final isExpert =
          tap.reactionTimeMs! < CognitiveConstants.expertCognitiveReactionTimeMs;
      bars.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Tooltip(
              message: '${tap.reactionTimeMs}ms',
              child: Container(
                height: 60.0 * pct,
                decoration: BoxDecoration(
                  color: isExpert
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reaction Time per Tap',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Bar lebih pendek = reaksi lebih cepat',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendDot(color: theme.colorScheme.tertiary),
                const SizedBox(width: 4),
                Text(
                  'Expert (<500ms)',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
                const SizedBox(width: 12),
                _LegendDot(color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Normal',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
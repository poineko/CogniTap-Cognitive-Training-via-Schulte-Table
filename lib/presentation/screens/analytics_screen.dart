import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/analytics_provider.dart';
import '../../core/constants/cognitive_constants.dart';
import '../../data/repositories/score_repository.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analyticsAsync = ref.watch(analyticsProvider);
    final scoresAsync = ref.watch(allHighScoresProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('COGNITIVE ANALYTICS', style: theme.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 7-Day Reaction Time Trend
            Text('7-Day Trend', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Average reaction time per day (ms)',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            analyticsAsync.when(
              data: (points) => _ReactionTimeTrendChart(points: points),
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(
                height: 200,
                child: Center(child: Text('No data yet. Play some games!')),
              ),
            ),

            const SizedBox(height: 32),

            // ── High Score Table
            Text('Personal Records', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            scoresAsync.when(
              data: (scores) => _HighScoreTable(scores: scores),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 32),

            // ── Cognitive Zone Legend
            _CognitiveZoneLegend(),
          ],
        ),
      ),
    );
  }
}

class _ReactionTimeTrendChart extends StatelessWidget {
  final List<DailyPerformancePoint> points;
  const _ReactionTimeTrendChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build FlSpots — hanya hari yang punya data
    final spots = <FlSpot>[];
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      if (p.avgReactionTimeMs > 0) {
        spots.add(FlSpot(i.toDouble(), p.avgReactionTimeMs));
      }
    }

    if (spots.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Play at least one session to see your trend!',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 24, 24, 16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              // Threshold lines untuk zona kognitif
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: CognitiveConstants.expertCognitiveReactionTimeMs
                        .toDouble(),
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (_) => 'Expert',
                      style: TextStyle(
                          color: theme.colorScheme.tertiary, fontSize: 10),
                      alignment: Alignment.topRight,
                    ),
                  ),
                  HorizontalLine(
                    y: CognitiveConstants.averageCognitiveReactionTimeMs
                        .toDouble(),
                    color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (_) => 'Average',
                      style: TextStyle(
                          color: theme.colorScheme.secondary, fontSize: 10),
                      alignment: Alignment.topRight,
                    ),
                  ),
                ],
              ),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.white.withValues(alpha: 0.05),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (_) => FlLine(
                  color: Colors.white.withValues(alpha: 0.05),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (val, meta) => Text(
                      '${val.toInt()}ms',
                      style: const TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx < 0 || idx >= points.length) return const SizedBox();
                      return Text(
                        DateFormat('E').format(points[idx].date),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white38),
                      );
                    },
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: theme.colorScheme.primary,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, pct, bar, idx) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: theme.colorScheme.primary,
                      strokeWidth: 2,
                      strokeColor: theme.scaffoldBackgroundColor,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                        theme.colorScheme.primary.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) => touchedSpots
                      .map((s) => LineTooltipItem(
                            '${s.y.toInt()} ms',
                            TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HighScoreTable extends StatelessWidget {
  final Map<int, double> scores;
  const _HighScoreTable({required this.scores});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [3, 4, 5, 6].map((size) {
            final score = scores[size];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$size×$size',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('${size * size} numbers',
                        style: theme.textTheme.bodyMedium),
                  ),
                  score != null
                      ? Text(
                          '${score.toStringAsFixed(2)}s',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        )
                      : Text('—',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.white24)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CognitiveZoneLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cognitive Speed Zones',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _ZoneRow(
              color: theme.colorScheme.tertiary,
              label: 'Expert',
              range: '< 500ms',
              description: 'Peak visual processing speed',
            ),
            _ZoneRow(
              color: theme.colorScheme.primary,
              label: 'Good',
              range: '500–1000ms',
              description: 'Above average cognitive speed',
            ),
            _ZoneRow(
              color: theme.colorScheme.secondary,
              label: 'Average',
              range: '1000–2000ms',
              description: 'Normal for adults',
            ),
            _ZoneRow(
              color: theme.colorScheme.error,
              label: 'Fatigued',
              range: '> 2000ms',
              description: 'Consider rest or more practice',
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneRow extends StatelessWidget {
  final Color color;
  final String label;
  final String range;
  final String description;
  const _ZoneRow(
      {required this.color,
      required this.label,
      required this.range,
      required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
              width: 12, height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          SizedBox(
              width: 70,
              child: Text(label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.w600))),
          SizedBox(
              width: 90,
              child: Text(range, style: theme.textTheme.bodyMedium)),
          Expanded(
              child: Text(description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white38, fontSize: 12))),
        ],
      ),
    );
  }
}
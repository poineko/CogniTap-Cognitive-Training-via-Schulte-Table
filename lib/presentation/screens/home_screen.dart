import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/streak_provider.dart';
import '../widgets/streak_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── Background: subtle grid pattern (neural network aesthetic)
          Positioned.fill(child: _NeuralBackground()),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // ── Top Row: Streak + Settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      streakAsync.when(
                        data: (streak) => StreakBadge(streakDays: streak),
                        loading: () => const SizedBox(width: 80, height: 32),
                        error: (_, __) => const SizedBox(),
                      ),
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.tune_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.08),

                  // ── Hero Title
                  Text(
                    'COGNI',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'TAP',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Train your focus.\nMeasure your mind.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white54,
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: size.height * 0.06),

                  // ── Cognitive Metric Chips
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetricChip(
                          icon: Icons.visibility, label: 'Peripheral Vision'),
                      _MetricChip(icon: Icons.bolt, label: 'Reaction Speed'),
                      _MetricChip(
                          icon: Icons.center_focus_strong, label: 'Focus'),
                    ],
                  ),

                  const Spacer(),

                  // ── CTA Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/levels'),
                      child: const Text('START TRAINING'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/custom'), // ← route baru
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const Text('Custom Mode'),
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
                          onPressed: () => context.push('/settings'),
                          icon: const Icon(Icons.tune, size: 18),
                          label: const Text('Settings'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Background abstrak yang terinspirasi neural network.
class _NeuralBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NeuralPainter(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
      ),
    );
  }
}

class _NeuralPainter extends CustomPainter {
  final Color color;
  _NeuralPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Dot grid pattern
    for (double x = 0; x < size.width; x += 40) {
      for (double y = 0; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), 1.5, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

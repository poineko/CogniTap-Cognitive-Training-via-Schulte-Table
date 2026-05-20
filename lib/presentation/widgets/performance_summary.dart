import 'package:flutter/material.dart';
import '../../core/constants/cognitive_constants.dart';
import '../../data/models/game_session.dart';

/// Widget ringkasan performa pasca-game dengan framing psikologis.
/// Memberikan feedback yang bermakna, bukan sekadar angka mentah.
class PerformanceSummary extends StatelessWidget {
  final GameSession session;

  const PerformanceSummary({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final rtMs = session.averageCognitiveReactionTimeMs;
    final feedback = _getCognitiveFeedback(rtMs);
    final sPerNum = session.secondsPerNumber.toStringAsFixed(2);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analisis Kognitif', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _StatRow(label: 'Waktu Total', value: '${session.totalDurationSeconds.toStringAsFixed(1)}s'),
            _StatRow(label: 'Kec. Rata-rata', value: '$sPerNum detik/angka'),
            _StatRow(label: 'Reaction Time', value: '${rtMs.toStringAsFixed(0)} ms'),
            _StatRow(label: 'Akurasi', value: '${session.accuracyPercent.toStringAsFixed(1)}%'),
            const Divider(height: 24),
            Text(
              feedback,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCognitiveFeedback(double rtMs) {
    if (rtMs == 0) return 'Data tidak cukup untuk analisis.';
    if (rtMs < CognitiveConstants.expertCognitiveReactionTimeMs) {
      return '🧠 Luar biasa! Kecepatan pemrosesan visual Anda berada di level expert. '
          'Peripheral vision dan fokus selektif sangat terlatih.';
    } else if (rtMs < CognitiveConstants.averageCognitiveReactionTimeMs) {
      return '✅ Performa baik! Kecepatan reaksi kognitif Anda di atas rata-rata. '
          'Teruslah berlatih untuk mencapai level expert.';
    } else if (rtMs < CognitiveConstants.fatiguedCognitiveReactionTimeMs) {
      return '📈 Performa rata-rata. Coba latihan secara rutin untuk meningkatkan '
          'kecepatan pemrosesan informasi visual Anda.';
    } else {
      return '💤 Reaction time tinggi mengindikasikan kemungkinan cognitive fatigue. '
          'Istirahat sebentar, lalu coba lagi!';
    }
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
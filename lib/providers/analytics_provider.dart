import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/game_session.dart';
import '../data/repositories/session_repository.dart'; // ← fix import

class DailyPerformancePoint {
  final DateTime date;
  final double avgReactionTimeMs;
  final int sessionCount;
  final double avgAccuracy;

  const DailyPerformancePoint({
    required this.date,
    required this.avgReactionTimeMs,
    required this.sessionCount,
    required this.avgAccuracy,
  });
}

final analyticsProvider =
    FutureProvider<List<DailyPerformancePoint>>((ref) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final sessions = await repo.getSessionsLast7Days();
  return _aggregateByDay(sessions);
});

List<DailyPerformancePoint> _aggregateByDay(List<GameSession> sessions) {
  final Map<String, List<GameSession>> byDay = {};
  for (final session in sessions) {
    byDay.putIfAbsent(_dateKey(session.startTime), () => []).add(session);
  }

  final result = <DailyPerformancePoint>[];
  for (int i = 6; i >= 0; i--) {
    final date = DateTime.now().subtract(Duration(days: i));
    final daySessions = byDay[_dateKey(date)] ?? [];

    if (daySessions.isEmpty) {
      result.add(DailyPerformancePoint(
        date: date,
        avgReactionTimeMs: 0,
        sessionCount: 0,
        avgAccuracy: 0,
      ));
    } else {
      final avgRT = daySessions
              .map((s) => s.averageCognitiveReactionTimeMs)
              .reduce((a, b) => a + b) /
          daySessions.length;
      final avgAcc = daySessions
              .map((s) => s.accuracyPercent)
              .reduce((a, b) => a + b) /
          daySessions.length;
      result.add(DailyPerformancePoint(
        date: date,
        avgReactionTimeMs: avgRT,
        sessionCount: daySessions.length,
        avgAccuracy: avgAcc,
      ));
    }
  }
  return result;
}

String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
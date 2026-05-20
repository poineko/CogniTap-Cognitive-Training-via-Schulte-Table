import 'tap_record.dart';

/// Representasi satu sesi permainan lengkap.
/// Menyimpan semua data mentah untuk analytics dan export.
class GameSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int gridSize;
  final bool isCountdownMode;
  final bool isInterferenceModeActive;
  
  /// Log detail setiap ketukan — inti dari Cognitive Analytics.
  final List<TapRecord> tapLog;
  
  /// Apakah sesi selesai (semua angka berhasil ditekan)?
  final bool isCompleted;

  const GameSession({
    required this.id,
    required this.startTime,
    required this.gridSize,
    required this.isCountdownMode,
    required this.isInterferenceModeActive,
    required this.tapLog,
    this.endTime,
    this.isCompleted = false,
  });

  /// Total durasi sesi dalam detik.
  double get totalDurationSeconds {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMilliseconds / 1000.0;
  }

  /// Rata-rata reaction time untuk ketukan yang BENAR saja.
  /// Metrik utama untuk mengukur "processing speed" kognitif.
  double get averageCognitiveReactionTimeMs {
    final correctTaps = tapLog
        .where((t) => t.isCorrect && t.reactionTimeMs != null)
        .toList();
    if (correctTaps.isEmpty) return 0;
    final total = correctTaps.fold<int>(0, (sum, t) => sum + t.reactionTimeMs!);
    return total / correctTaps.length;
  }

  /// Akurasi: persentase ketukan benar dari total.
  double get accuracyPercent {
    if (tapLog.isEmpty) return 0;
    final correctCount = tapLog.where((t) => t.isCorrect).length;
    return (correctCount / tapLog.length) * 100;
  }
  
  /// Kecepatan dalam "detik per angka" — metrik yang mudah dipahami user.
  double get secondsPerNumber {
    final correctTaps = tapLog.where((t) => t.isCorrect).length;
    if (correctTaps == 0) return 0;
    return totalDurationSeconds / correctTaps;
  }

  GameSession copyWith({
    DateTime? endTime,
    List<TapRecord>? tapLog,
    bool? isCompleted,
  }) {
    return GameSession(
      id: id,
      startTime: startTime,
      gridSize: gridSize,
      isCountdownMode: isCountdownMode,
      isInterferenceModeActive: isInterferenceModeActive,
      tapLog: tapLog ?? this.tapLog,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
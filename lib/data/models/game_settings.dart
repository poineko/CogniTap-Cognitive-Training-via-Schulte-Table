enum TimerMode { countdown, stopwatch }

/// Pengaturan yang dikonfigurasi user sebelum memulai game.
class GameSettings {
  /// Ukuran satu sisi grid (3 = 3x3, 4 = 4x4, dst).
  final int gridSize;
  final TimerMode timerMode;
  
  /// Durasi countdown dalam detik (hanya relevan jika timerMode == countdown).
  final int countdownSeconds;
  
  /// Mode gangguan visual untuk melatih selective attention.
  final bool isInterferenceModeActive;

  const GameSettings({
    this.gridSize = 3,
    this.timerMode = TimerMode.stopwatch,
    this.countdownSeconds = 30,
    this.isInterferenceModeActive = false,
  });

  /// Total angka yang harus ditekan dalam satu sesi.
  int get visualSpanGridCount => gridSize * gridSize;

  GameSettings copyWith({
    int? gridSize,
    TimerMode? timerMode,
    int? countdownSeconds,
    bool? isInterferenceModeActive,
  }) {
    return GameSettings(
      gridSize: gridSize ?? this.gridSize,
      timerMode: timerMode ?? this.timerMode,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      isInterferenceModeActive:
          isInterferenceModeActive ?? this.isInterferenceModeActive,
    );
  }
}
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/game_session.dart';
import '../data/models/game_settings.dart';
import '../data/models/tap_record.dart';
import '../data/repositories/session_repository.dart';
import '../core/constants/cognitive_constants.dart';

enum GamePhase { idle, playing, paused, completed, failed }

class GameState {
  final GamePhase phase;
  final GameSettings settings;
  final List<int> gridNumbers;
  final int nextExpectedNumber;
  final int? remainingSeconds;
  final int elapsedMs;
  final GameSession? currentSession;
  final int? lastCorrectIndex;
  final int? lastWrongIndex;
  final List<Color>? distractionColors;

  const GameState({
    this.phase = GamePhase.idle,
    this.settings = const GameSettings(),
    this.gridNumbers = const [],
    this.nextExpectedNumber = 1,
    this.remainingSeconds,
    this.elapsedMs = 0,
    this.currentSession,
    this.lastCorrectIndex,
    this.lastWrongIndex,
    this.distractionColors,
  });

  GameState copyWith({
    GamePhase? phase,
    GameSettings? settings,
    List<int>? gridNumbers,
    int? nextExpectedNumber,
    int? remainingSeconds,
    int? elapsedMs,
    GameSession? currentSession,
    int? lastCorrectIndex,
    bool clearLastCorrect = false,
    int? lastWrongIndex,
    bool clearLastWrong = false,
    List<Color>? distractionColors,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      settings: settings ?? this.settings,
      gridNumbers: gridNumbers ?? this.gridNumbers,
      nextExpectedNumber: nextExpectedNumber ?? this.nextExpectedNumber,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      currentSession: currentSession ?? this.currentSession,
      lastCorrectIndex:
          clearLastCorrect ? null : (lastCorrectIndex ?? this.lastCorrectIndex),
      lastWrongIndex:
          clearLastWrong ? null : (lastWrongIndex ?? this.lastWrongIndex),
      distractionColors: distractionColors ?? this.distractionColors,
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final gameProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  // Inject SessionRepository agar bisa auto-save setelah game selesai
  final sessionRepo = ref.read(sessionRepositoryProvider);
  return GameNotifier(sessionRepo);
});

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(this._sessionRepo) : super(const GameState());

  final SessionRepository _sessionRepo;
  Timer? _gameTimer;
  Timer? _distractionTimer;
  DateTime? _lastCorrectTapTime;
  final _random = Random();

  // ── Public API ─────────────────────────────────────────────────────────

  void initGame(GameSettings settings) {
    _cancelTimers();
    final numbers = _generateShuffledGrid(settings.visualSpanGridCount);
    final session = GameSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      gridSize: settings.gridSize,
      isCountdownMode: settings.timerMode == TimerMode.countdown,
      isInterferenceModeActive: settings.isInterferenceModeActive,
      tapLog: [],
    );

    state = GameState(
      phase: GamePhase.playing,
      settings: settings,
      gridNumbers: numbers,
      nextExpectedNumber: 1,
      remainingSeconds: settings.timerMode == TimerMode.countdown
          ? settings.countdownSeconds
          : null,
      elapsedMs: 0,
      currentSession: session,
      distractionColors: settings.isInterferenceModeActive
          ? _generateDistractionColors(settings.visualSpanGridCount)
          : null,
    );

    _lastCorrectTapTime = DateTime.now();
    _startTimer(settings);
    if (settings.isInterferenceModeActive) _startDistractionTimer();
  }

  void onCellTapped(int tappedNumber) {
    if (state.phase != GamePhase.playing) return;

    final now = DateTime.now();
    final isCorrect = tappedNumber == state.nextExpectedNumber;
    final reactionTimeMs = _lastCorrectTapTime != null && isCorrect
        ? now.difference(_lastCorrectTapTime!).inMilliseconds
        : null;

    final tapRecord = TapRecord(
      expectedNumber: state.nextExpectedNumber,
      tappedNumber: tappedNumber,
      timestamp: now,
      reactionTimeMs: reactionTimeMs,
    );

    final updatedTapLog = [...?state.currentSession?.tapLog, tapRecord];
    final updatedSession =
        state.currentSession?.copyWith(tapLog: updatedTapLog);
    final tappedIndex = state.gridNumbers.indexOf(tappedNumber);

    if (isCorrect) {
      _lastCorrectTapTime = now;
      final isGameComplete =
          tappedNumber == state.settings.visualSpanGridCount;

      if (isGameComplete) {
        _handleGameComplete(updatedSession);
      } else {
        state = state.copyWith(
          nextExpectedNumber: state.nextExpectedNumber + 1,
          currentSession: updatedSession,
          lastCorrectIndex: tappedIndex,
          clearLastWrong: true,
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) state = state.copyWith(clearLastCorrect: true);
        });
      }
    } else {
      state = state.copyWith(
        currentSession: updatedSession,
        lastWrongIndex: tappedIndex,
        clearLastCorrect: true,
      );
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) state = state.copyWith(clearLastWrong: true);
      });
    }
  }

  void resetGame() {
    _cancelTimers();
    state = GameState(settings: state.settings);
  }

  void updateSettings(GameSettings settings) {
    state = state.copyWith(settings: settings);
  }

  // ── Private ────────────────────────────────────────────────────────────

  List<int> _generateShuffledGrid(int count) {
    final numbers = List.generate(count, (i) => i + 1);
    for (int i = numbers.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = numbers[i];
      numbers[i] = numbers[j];
      numbers[j] = temp;
    }
    return numbers;
  }

  List<Color> _generateDistractionColors(int count) {
    final palette = [
      Colors.purple.shade200,
      Colors.teal.shade200,
      Colors.orange.shade200,
      Colors.pink.shade200,
      Colors.indigo.shade200,
    ];
    return List.generate(
        count, (_) => palette[_random.nextInt(palette.length)]);
  }

  void _startTimer(GameSettings settings) {
    // Stopwatch: update setiap 100ms agar tampilan lebih smooth
    final interval = settings.timerMode == TimerMode.stopwatch
        ? const Duration(milliseconds: 100)
        : const Duration(seconds: 1);

    _gameTimer = Timer.periodic(interval, (_) {
      if (state.phase != GamePhase.playing) return;

      if (settings.timerMode == TimerMode.countdown) {
        final newRemaining = (state.remainingSeconds ?? 0) - 1;
        if (newRemaining <= 0) {
          _handleTimerExpired();
        } else {
          state = state.copyWith(remainingSeconds: newRemaining);
        }
      } else {
        state = state.copyWith(elapsedMs: state.elapsedMs + 100);
      }
    });
  }

  void _startDistractionTimer() {
    _distractionTimer = Timer.periodic(
      Duration(milliseconds: CognitiveConstants.fontSizeShiftIntervalMs),
      (_) {
        if (state.phase != GamePhase.playing) return;
        state = state.copyWith(
          distractionColors: _generateDistractionColors(
            state.settings.visualSpanGridCount,
          ),
        );
      },
    );
  }

  Future<void> _handleGameComplete(GameSession? session) async {
    _cancelTimers();
    final completedSession = session?.copyWith(
      endTime: DateTime.now(),
      isCompleted: true,
    );
    state = state.copyWith(
      phase: GamePhase.completed,
      currentSession: completedSession,
      clearLastCorrect: true,
    );
    // ← Simpan ke storage SETELAH game selesai
    if (completedSession != null) {
      await _sessionRepo.saveSession(completedSession);
    }
  }

  void _handleTimerExpired() {
    _cancelTimers();
    // Simpan juga sesi yang tidak selesai (untuk analytics akurasi)
    final expiredSession = state.currentSession?.copyWith(
      endTime: DateTime.now(),
      isCompleted: false,
    );
    if (expiredSession != null) {
      _sessionRepo.saveSession(expiredSession);
    }
    state = state.copyWith(phase: GamePhase.failed);
  }

  void _cancelTimers() {
    _gameTimer?.cancel();
    _distractionTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
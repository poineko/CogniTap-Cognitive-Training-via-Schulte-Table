import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final scoreRepositoryProvider = Provider((ref) => ScoreRepository());

/// Provider high scores untuk semua grid size.
/// Diletakkan di sini agar bisa diimport oleh analytics_screen
/// dan level_select_screen tanpa circular dependency.
final allHighScoresProvider = FutureProvider<Map<int, double>>((ref) async {
  return ref.read(scoreRepositoryProvider).getAllHighScores();
});

class ScoreRepository {
  static const String _prefix = 'high_score_';

  Future<double?> getHighScore(int gridSize) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_prefix$gridSize');
  }

  Future<bool> updateHighScoreIfBetter(
      int gridSize, double durationSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$gridSize';
    final existing = prefs.getDouble(key);
    if (existing == null || durationSeconds < existing) {
      await prefs.setDouble(key, durationSeconds);
      return true;
    }
    return false;
  }

  Future<Map<int, double>> getAllHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, double> scores = {};
    for (final size in [3, 4, 5, 6]) {
      final val = prefs.getDouble('$_prefix$size');
      if (val != null) scores[size] = val;
    }
    return scores;
  }
}
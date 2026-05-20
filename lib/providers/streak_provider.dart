// streak_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final streakProvider =
    AsyncNotifierProvider<StreakNotifier, int>(StreakNotifier.new);

class StreakNotifier extends AsyncNotifier<int> {
  static const _key = 'daily_streak';
  static const _lastSessionKey = 'last_session_date';

  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  /// Catat sesi hari ini. Update streak jika belum dicatat hari ini.
  Future<void> recordTodaySession() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final lastSession = prefs.getString(_lastSessionKey);

    if (lastSession == today) return; // Sudah tercatat hari ini

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final currentStreak = prefs.getInt(_key) ?? 0;

    // Streak berlanjut jika sesi terakhir kemarin; reset jika lebih lama
    final newStreak = lastSession == yesterday ? currentStreak + 1 : 1;

    await prefs.setInt(_key, newStreak);
    await prefs.setString(_lastSessionKey, today);
    state = AsyncData(newStreak);
  }

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}
/// Konstanta yang didasarkan pada penelitian Psikologi Kognitif.
/// Referensi: Schulte Table (1920), Cognitive Load Theory (Sweller, 1988),
/// dan Attention Restoration Theory (Kaplan, 1989).
class CognitiveConstants {
  // ── Grid Configurations ──────────────────────────────────────────────────
  
  /// Rentang angka untuk setiap ukuran grid (visual span / field of view).
  /// Penelitian menunjukkan grid 5x5 adalah "sweet spot" untuk
  /// melatih peripheral vision tanpa cognitive overload.
  static const Map<int, GridConfig> gridConfigs = {
    3: GridConfig(size: 3, count: 9,  baseTimeSeconds: 20),
    4: GridConfig(size: 4, count: 16, baseTimeSeconds: 40),
    5: GridConfig(size: 5, count: 25, baseTimeSeconds: 60),
    6: GridConfig(size: 6, count: 36, baseTimeSeconds: 90),
  };

  // ── Reaction Time Thresholds (ms) ─────────────────────────────────────────
  
  /// Waktu reaksi < 500ms dianggap "expert" berdasarkan studi visual search.
  static const int expertCognitiveReactionTimeMs = 500;
  
  /// Waktu reaksi 500–1000ms adalah "average" untuk orang dewasa normal.
  static const int averageCognitiveReactionTimeMs = 1000;
  
  /// Waktu reaksi > 2000ms mengindikasikan cognitive fatigue atau low focus.
  static const int fatiguedCognitiveReactionTimeMs = 2000;

  // ── Interference Mode ─────────────────────────────────────────────────────
  
  /// Jumlah warna distraksi dalam Interference Mode.
  /// Selective Attention Theory: lebih dari 5 warna mulai membebani
  /// working memory secara signifikan.
  static const int maxDistractionColors = 5;
  
  /// Interval perubahan ukuran font dalam mode distraksi (ms).
  static const int fontSizeShiftIntervalMs = 1500;

  // ── Daily Habit ───────────────────────────────────────────────────────────
  
  /// Minimum satu sesi per hari untuk menjaga neuroplastisitas.
  /// Konsisten dengan "spaced practice" dalam teori pembelajaran.
  static const int minDailySessionsForStreak = 1;
}

class GridConfig {
  final int size;
  final int count;
  final int baseTimeSeconds;
  
  const GridConfig({
    required this.size,
    required this.count,
    required this.baseTimeSeconds,
  });
}
/// Model untuk mencatat setiap ketukan dalam satu sesi permainan.
/// Didesain untuk keperluan penelitian — bisa diekspor ke CSV
/// untuk analisis lebih lanjut (misal: SPSS, Python/Pandas, R).
class TapRecord {
  /// Angka yang seharusnya ditekan pada giliran ini.
  final int expectedNumber;
  
  /// Angka yang sebenarnya ditekan oleh user.
  final int tappedNumber;
  
  /// Timestamp absolut saat ketukan terjadi.
  final DateTime timestamp;
  
  /// Jeda waktu sejak ketukan BENAR sebelumnya (ms).
  /// Ini adalah ukuran utama "cognitive reaction time" dalam studi.
  /// null untuk ketukan pertama dalam sesi.
  final int? reactionTimeMs;
  
  /// Apakah ini ketukan yang benar?
  bool get isCorrect => expectedNumber == tappedNumber;

  const TapRecord({
    required this.expectedNumber,
    required this.tappedNumber,
    required this.timestamp,
    this.reactionTimeMs,
  });

  /// Konversi ke CSV row untuk export ke peneliti/terapis.
  String toCsvRow() {
    return '$expectedNumber,$tappedNumber,'
        '${timestamp.toIso8601String()},'
        '${reactionTimeMs ?? "N/A"},'
        '${isCorrect ? "correct" : "incorrect"}';
  }

  static String get csvHeader =>
      'expected_number,tapped_number,timestamp,reaction_time_ms,result';
}
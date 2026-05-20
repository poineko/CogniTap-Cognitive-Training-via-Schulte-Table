import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/game_session.dart';
import '../../data/models/tap_record.dart';

/// Utility untuk mengekspor data mentah sesi permainan ke format CSV.
/// Dirancang untuk keperluan penelitian dan analisis data:
/// - Terapis kognitif bisa tracking progres klien
/// - Peneliti bisa import ke SPSS/R/Python untuk analisis
/// Format: ISO 8601 timestamps, reaction time dalam milliseconds
class CsvExporter {
  
  /// Ekspor satu sesi ke CSV dan buka share sheet.
  static Future<void> exportSession(GameSession session) async {
    final csvContent = _buildCsvContent([session]);
    await _saveAndShare(csvContent, 'cognitap_session_${session.id}.csv');
  }

  /// Ekspor multiple sesi (berguna untuk analisis longitudinal).
  static Future<void> exportAllSessions(List<GameSession> sessions) async {
    final csvContent = _buildCsvContent(sessions);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _saveAndShare(csvContent, 'cognitap_export_$timestamp.csv');
  }

  static String _buildCsvContent(List<GameSession> sessions) {
    final buffer = StringBuffer();
    
    // Metadata header
    buffer.writeln('# CogniTap - Cognitive Performance Export');
    buffer.writeln('# Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('# Format: Schulte Table Tap Log');
    buffer.writeln('#');
    
    // Session-level header
    buffer.writeln(
      'session_id,grid_size,start_time,total_duration_s,'
      'avg_reaction_time_ms,accuracy_pct,interference_mode,'
      '${TapRecord.csvHeader}',
    );

    for (final session in sessions) {
      for (final tap in session.tapLog) {
        buffer.writeln(
          '${session.id},'
          '${session.gridSize}x${session.gridSize},'
          '${session.startTime.toIso8601String()},'
          '${session.totalDurationSeconds.toStringAsFixed(2)},'
          '${session.averageCognitiveReactionTimeMs.toStringAsFixed(0)},'
          '${session.accuracyPercent.toStringAsFixed(1)},'
          '${session.isInterferenceModeActive},'
          '${tap.toCsvRow()}',
        );
      }
    }

    return buffer.toString();
  }

  static Future<void> _saveAndShare(String content, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'CogniTap - Cognitive Performance Data',
    );
  }
}
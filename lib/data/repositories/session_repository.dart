import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_session.dart';
import '../models/tap_record.dart';

final sessionRepositoryProvider = Provider((ref) => SessionRepository());

class SessionRepository {
  static const _key = 'session_history';
  static const _maxSessions = 100; // Batas agar storage tidak membengkak

  Future<void> saveSession(GameSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await _loadRaw(prefs);
    existing.insert(0, _sessionToJson(session));
    // Batasi jumlah sesi tersimpan
    final trimmed =
        existing.length > _maxSessions ? existing.sublist(0, _maxSessions) : existing;
    await prefs.setString(_key, jsonEncode(trimmed));
  }

  Future<List<GameSession>> getSessionsLast7Days() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = await _loadRaw(prefs);
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return raw
        .map(_sessionFromJson)
        .where((s) => s.startTime.isAfter(cutoff))
        .toList();
  }

  Future<List<GameSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = await _loadRaw(prefs);
    return raw.map(_sessionFromJson).toList();
  }

  Future<List<Map<String, dynamic>>> _loadRaw(
      SharedPreferences prefs) async {
    final str = prefs.getString(_key);
    if (str == null) return [];
    final decoded = jsonDecode(str) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  // ── Serialization ──────────────────────────────────────────────────────

  Map<String, dynamic> _sessionToJson(GameSession s) => {
        'id': s.id,
        'startTime': s.startTime.toIso8601String(),
        'endTime': s.endTime?.toIso8601String(),
        'gridSize': s.gridSize,
        'isCountdownMode': s.isCountdownMode,
        'isInterferenceModeActive': s.isInterferenceModeActive,
        'isCompleted': s.isCompleted,
        'tapLog': s.tapLog.map(_tapToJson).toList(),
      };

  Map<String, dynamic> _tapToJson(TapRecord t) => {
        'expectedNumber': t.expectedNumber,
        'tappedNumber': t.tappedNumber,
        'timestamp': t.timestamp.toIso8601String(),
        'reactionTimeMs': t.reactionTimeMs,
      };

  GameSession _sessionFromJson(Map<String, dynamic> j) => GameSession(
        id: j['id'] as String,
        startTime: DateTime.parse(j['startTime'] as String),
        endTime: j['endTime'] != null
            ? DateTime.parse(j['endTime'] as String)
            : null,
        gridSize: j['gridSize'] as int,
        isCountdownMode: j['isCountdownMode'] as bool,
        isInterferenceModeActive: j['isInterferenceModeActive'] as bool,
        isCompleted: j['isCompleted'] as bool? ?? false,
        tapLog: (j['tapLog'] as List)
            .map((t) => _tapFromJson(t as Map<String, dynamic>))
            .toList(),
      );

  TapRecord _tapFromJson(Map<String, dynamic> j) => TapRecord(
        expectedNumber: j['expectedNumber'] as int,
        tappedNumber: j['tappedNumber'] as int,
        timestamp: DateTime.parse(j['timestamp'] as String),
        reactionTimeMs: j['reactionTimeMs'] as int?,
      );
}
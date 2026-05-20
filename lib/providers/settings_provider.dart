// settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/game_settings.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, GameSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<GameSettings> {
  SettingsNotifier() : super(const GameSettings());
  void update(GameSettings settings) => state = settings;
}
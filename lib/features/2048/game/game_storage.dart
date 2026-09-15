import 'dart:convert';
import 'dart:ui';

import 'package:arcade/features/2048/models/game_state.dart';
import 'package:arcade/features/2048/presentation/tile_color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameStorage {
  static const _currentGameKey = '2048_current_game';
  static const _historyKey = '2048_history';
  static const _highScoreKey = '2048_high_score';
  static const _hasShownWinKey = '2048_has_shown_win';
  static const _tileColorKey = '2048_tile_color';
  static const _hasBoardJiggleKey = '2048_has_board_jiggle';

  final SharedPreferences preferences;

  GameStorage(this.preferences);

  Future<void> saveGame({
    required GameState currentGame,
    required List<GameState> history,
    required int highScore,
    required bool hasShownWin,
  }) async {
    await preferences.setString(
      _currentGameKey,
      jsonEncode(currentGame.toJson()),
    );

    await preferences.setString(
      _historyKey,
      jsonEncode(history.map((state) => state.toJson()).toList()),
    );

    await preferences.setInt(_highScoreKey, highScore);

    await preferences.setBool(_hasShownWinKey, hasShownWin);
  }

  GameState? loadGame() {
    final value = preferences.getString(_currentGameKey);

    if (value == null) return null;

    final json = jsonDecode(value) as Map<String, dynamic>;

    return GameState.fromJson(json);
  }

  List<GameState> loadHistory() {
    final value = preferences.getString(_historyKey);

    if (value == null) return [];

    final json = jsonDecode(value) as List<dynamic>;

    return json
        .map(
          (stateJson) => GameState.fromJson(stateJson as Map<String, dynamic>),
        )
        .toList();
  }

  int loadHighScore() {
    return preferences.getInt(_highScoreKey) ?? 0;
  }

  bool loadHasShownWin() {
    return preferences.getBool(_hasShownWinKey) ?? false;
  }

  Future<void> saveTileColor(Color color) async {
    await preferences.setInt(_tileColorKey, color.toARGB32());
  }

  Color loadTileColor() {
    return Color(
      preferences.getInt(_tileColorKey) ??
          TileColorScheme.presets.first.baseColor.toARGB32(),
    );
  }

  Future<void> saveHasBoardJiggle(bool hasBoardJiggle) async {
    await preferences.setBool(_hasBoardJiggleKey, hasBoardJiggle);
  }

  bool loadHasBoardJiggle() {
    return preferences.getBool(_hasBoardJiggleKey) ?? true;
  }
}

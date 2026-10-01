import 'dart:convert';

import 'package:arcade/features/minesweeper/models/difficulty.dart';
import 'package:arcade/features/minesweeper/models/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MinesweeperGameStorage {
  static const _currentGameKey = 'minesweeper_current_game';

  final SharedPreferences preferences;

  MinesweeperGameStorage(this.preferences);

  Future<void> saveGame({required MinesweeperGameState currentGame}) async {
    await preferences.setString(
      _currentGameKey,
      jsonEncode(currentGame.toJson()),
    );
  }

  MinesweeperGameState? loadGame() {
    final value = preferences.getString(_currentGameKey);

    if (value == null) return null;

    final json = jsonDecode(value) as Map<String, dynamic>;

    return MinesweeperGameState.fromJson(json);
  }

  Future<void> saveBestTime({
    required Difficulty difficulty,
    required Duration time,
  }) async {
    await preferences.setInt(_bestTimeKey(difficulty), time.inMilliseconds);
  }

  Duration? loadBestTime(Difficulty difficulty) {
    final value = preferences.getInt(_bestTimeKey(difficulty));

    if (value == null) return null;

    return Duration(milliseconds: value);
  }

  String _bestTimeKey(Difficulty difficulty) {
    return 'minesweeper_best_time_${difficulty.name}';
  }
}

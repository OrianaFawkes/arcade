import 'dart:convert';

import 'package:arcade/features/proximity/models/difficulty.dart';
import 'package:arcade/features/proximity/models/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameStorage {
  static const _currentGameKey = 'proximity_current_game';

  final SharedPreferences preferences;

  GameStorage(this.preferences);

  Future<void> saveGame({required GameState currentGame}) async {
    await preferences.setString(
      _currentGameKey,
      jsonEncode(currentGame.toJson()),
    );
  }

  GameState? loadGame() {
    final value = preferences.getString(_currentGameKey);

    if (value == null) return null;

    final json = jsonDecode(value) as Map<String, dynamic>;

    return GameState.fromJson(json);
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
    return 'proximity_best_time_${difficulty.name}';
  }
}

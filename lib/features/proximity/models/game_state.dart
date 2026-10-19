import 'package:arcade/features/proximity/models/cell.dart';
import 'package:arcade/features/proximity/models/difficulty.dart';

enum GameStatus { ready, playing, won, lost }

class GameState {
  final List<List<Cell>> board;

  final Difficulty difficulty;

  final GameStatus status;

  final Duration elapsed;

  const GameState({
    required this.board,
    required this.difficulty,
    required this.status,
    required this.elapsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'board': board
          .map((row) => row.map((cell) => cell.toJson()).toList())
          .toList(),
      'difficulty': difficulty.name,
      'status': status.name,
      'elapsedMilliseconds': elapsed.inMilliseconds,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      board: (json['board'] as List<dynamic>)
          .map(
            (row) => (row as List<dynamic>)
                .map((cell) => Cell.fromJson(cell as Map<String, dynamic>))
                .toList(),
          )
          .toList(),
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
      status: GameStatus.values.byName(json['status'] as String),
      elapsed: Duration(milliseconds: json['elapsedMilliseconds'] as int),
    );
  }
}

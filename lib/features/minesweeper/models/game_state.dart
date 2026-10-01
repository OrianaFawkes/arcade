import 'package:arcade/features/minesweeper/models/cell.dart';
import 'package:arcade/features/minesweeper/models/difficulty.dart';

enum MinesweeperGameStatus { ready, playing, won, lost }

class MinesweeperGameState {
  final List<List<Cell>> board;
  final Difficulty difficulty;
  final MinesweeperGameStatus status;
  final Duration elapsed;

  const MinesweeperGameState({
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

  factory MinesweeperGameState.fromJson(Map<String, dynamic> json) {
    return MinesweeperGameState(
      board: (json['board'] as List<dynamic>)
          .map(
            (row) => (row as List<dynamic>)
                .map((cell) => Cell.fromJson(cell as Map<String, dynamic>))
                .toList(),
          )
          .toList(),
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
      status: MinesweeperGameStatus.values.byName(json['status'] as String),
      elapsed: Duration(milliseconds: json['elapsedMilliseconds'] as int),
    );
  }
}

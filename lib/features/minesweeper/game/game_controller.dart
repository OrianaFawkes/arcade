import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:arcade/features/minesweeper/game/game_storage.dart';
import 'package:arcade/features/minesweeper/models/cell.dart';
import 'package:arcade/features/minesweeper/models/difficulty.dart';
import 'package:arcade/features/minesweeper/models/game_state.dart';
import 'package:arcade/features/minesweeper/models/position.dart';

class MinesweeperGameController {
  final MinesweeperGameStorage storage;

  MinesweeperGameController(this.storage);

  final Random random = Random();

  List<List<Cell>> _board = [];

  Difficulty _difficulty = Difficulty.beginner;
  MinesweeperGameStatus _status = MinesweeperGameStatus.ready;

  Duration _elapsed = Duration.zero;
  final Stopwatch _stopwatch = Stopwatch();

  Duration? _bestTime;

  MinesweeperGameStatus get status => _status;
  Difficulty get difficulty => _difficulty;

  List<List<Cell>> get board =>
      _board.map((row) => List<Cell>.unmodifiable(row)).toList();

  Duration get elapsed => _elapsed + _stopwatch.elapsed;

  Duration? get bestTime => _bestTime;

  int get flagsUsed {
    return _board.expand((row) => row).where((cell) => cell.isFlagged).length;
  }

  bool get isGameOver {
    return _status == MinesweeperGameStatus.won ||
        _status == MinesweeperGameStatus.lost;
  }

  bool get isPlaying => _status == MinesweeperGameStatus.playing;

  bool get isReady => _status == MinesweeperGameStatus.ready;

  Future<void> initialize() async {
    try {
      final currentGame = storage.loadGame();

      if (currentGame == null) {
        await startGame(_difficulty);
        return;
      }

      _restoreGame(currentGame);

      _bestTime = storage.loadBestTime(_difficulty);

      if (_status == MinesweeperGameStatus.playing) {
        _startStopwatch();
      }
    } catch (_) {
      await startGame(_difficulty);
    }
  }

  Future<void> startGame(Difficulty difficulty) async {
    _stopStopwatch();

    _difficulty = difficulty;
    _status = MinesweeperGameStatus.ready;
    _elapsed = Duration.zero;
    _board = _createEmptyBoard();

    _bestTime = storage.loadBestTime(difficulty);

    await _save();
  }

  Future<void> reveal(int row, int column) async {
    if (!_isValidPosition(row, column)) return;
    if (isGameOver) return;

    var cell = _board[row][column];

    if (cell.isRevealed || cell.isFlagged) return;

    // Generate the board on the first reveal.
    if (_status == .ready) {
      _generateMines(row, column);
      _calculateAdjacentMines();

      _status = .playing;
      _startStopwatch();

      cell = _board[row][column];
    }

    if (cell.hasMine) {
      _revealAllMines();
      _status = .lost;

      _stopStopwatch();
      await _save();
      return;
    }

    if (cell.adjacentMines == 0) {
      _revealEmptyRegion(row, column);
    } else {
      _revealCell(row, column);
    }

    _checkWin();

    if (isGameOver) {
      _stopStopwatch();

      if (_status == .won) {
        final finalTime = elapsed;

        if (_bestTime == null || finalTime < _bestTime!) {
          _bestTime = finalTime;

          await storage.saveBestTime(difficulty: _difficulty, time: finalTime);
        }
      }
    }

    await _save();
  }

  Future<void> toggleFlag(int row, int column) async {
    if (!_isValidPosition(row, column)) return;
    if (isGameOver || isReady) return;

    final cell = _board[row][column];

    if (cell.isRevealed) return;

    _board[row][column] = cell.copyWith(isFlagged: !cell.isFlagged);

    await _save();
  }

  Cell? cellAt(int row, int column) {
    if (!_isValidPosition(row, column)) return null;

    return _board[row][column];
  }

  void _generateMines(int firstRow, int firstColumn) {
    final protectedPositions = <Position>{};

    for (final position in _neighbors(firstRow, firstColumn)) {
      protectedPositions.add(position);
    }

    protectedPositions.add(Position(row: firstRow, column: firstColumn));

    final availablePositions = <Position>[];

    for (var row = 0; row < _difficulty.rows; row++) {
      for (var column = 0; column < _difficulty.columns; column++) {
        final position = Position(row: row, column: column);

        if (!protectedPositions.contains(position)) {
          availablePositions.add(position);
        }
      }
    }

    availablePositions.shuffle(random);

    for (final position in availablePositions.take(_difficulty.mineCount)) {
      _board[position.row][position.column] =
          _board[position.row][position.column].copyWith(hasMine: true);
    }
  }

  void _calculateAdjacentMines() {
    for (var row = 0; row < _difficulty.rows; row++) {
      for (var column = 0; column < _difficulty.columns; column++) {
        final cell = _board[row][column];

        if (cell.hasMine) continue;

        var adjacentMines = 0;

        for (final position in _neighbors(row, column)) {
          if (_board[position.row][position.column].hasMine) {
            adjacentMines++;
          }
        }

        _board[row][column] = cell.copyWith(adjacentMines: adjacentMines);
      }
    }
  }

  void _revealCell(int row, int column) {
    final cell = _board[row][column];

    if (cell.isRevealed || cell.isFlagged) return;

    _board[row][column] = cell.copyWith(isRevealed: true);
  }

  void _revealEmptyRegion(int row, int column) {
    final queue = Queue<Position>();
    final visited = <Position>{};

    queue.add(Position(row: row, column: column));

    while (queue.isNotEmpty) {
      final position = queue.removeFirst();

      if (!visited.add(position)) continue;

      final cell = _board[position.row][position.column];

      if (cell.isRevealed || cell.isFlagged || cell.hasMine) {
        continue;
      }

      _board[position.row][position.column] = cell.copyWith(isRevealed: true);

      if (cell.adjacentMines != 0) continue;

      for (final neighbor in _neighbors(position.row, position.column)) {
        final neighborCell = _board[neighbor.row][neighbor.column];

        if (!neighborCell.isRevealed &&
            !neighborCell.isFlagged &&
            !neighborCell.hasMine) {
          queue.add(neighbor);
        }
      }
    }
  }

  void _revealAllMines() {
    for (var row = 0; row < _difficulty.rows; row++) {
      for (var column = 0; column < _difficulty.columns; column++) {
        final cell = _board[row][column];

        if (cell.hasMine) {
          _board[row][column] = cell.copyWith(
            isRevealed: true,
            isFlagged: false,
          );
        }
      }
    }
  }

  void _checkWin() {
    for (final row in _board) {
      for (final cell in row) {
        if (!cell.hasMine && !cell.isRevealed) {
          return;
        }
      }
    }

    _status = MinesweeperGameStatus.won;
  }

  Iterable<Position> _neighbors(int row, int column) sync* {
    for (var rowOffset = -1; rowOffset <= 1; rowOffset++) {
      for (var columnOffset = -1; columnOffset <= 1; columnOffset++) {
        if (rowOffset == 0 && columnOffset == 0) continue;

        final neighborRow = row + rowOffset;
        final neighborColumn = column + columnOffset;

        if (_isValidPosition(neighborRow, neighborColumn)) {
          yield Position(row: neighborRow, column: neighborColumn);
        }
      }
    }
  }

  List<List<Cell>> _createEmptyBoard() {
    return List.generate(
      _difficulty.rows,
      (_) => List.generate(_difficulty.columns, (_) => const Cell()),
    );
  }

  bool _isValidPosition(int row, int column) {
    return row >= 0 &&
        row < _difficulty.rows &&
        column >= 0 &&
        column < _difficulty.columns;
  }

  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }
  }

  void _stopStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _elapsed += _stopwatch.elapsed;
      _stopwatch.reset();
    }
  }

  Future<void> _save() {
    return storage.saveGame(currentGame: _createSnapshot());
  }

  MinesweeperGameState _createSnapshot() {
    return MinesweeperGameState(
      board: _board.map((row) => row.toList()).toList(),
      difficulty: _difficulty,
      status: _status,
      elapsed: elapsed,
    );
  }

  void _restoreGame(MinesweeperGameState state) {
    _stopStopwatch();

    _difficulty = state.difficulty;
    _status = state.status;
    _elapsed = state.elapsed;

    _board = state.board.map((row) => row.toList()).toList();
  }
}

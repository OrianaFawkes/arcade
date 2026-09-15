import 'dart:math';

import 'package:arcade/features/2048/game/game_storage.dart';
import 'package:arcade/features/2048/models/game_state.dart';
import 'package:arcade/features/2048/models/move_direction.dart';
import 'package:arcade/features/2048/models/tile.dart';
import 'package:flutter/material.dart';

class GameController {
  static const int size = 4;
  static const int targetValue = 2048;
  static const int maxUndoSteps = 2;

  final GameStorage storage;

  GameController(this.storage);

  final List<GameState> _history = [];

  final Random random = Random();

  List<Tile> _tiles = [];

  Color? _tileBaseColor;

  int _score = 0;
  int _highScore = 0;
  int _nextId = 0;

  bool _hasShownWin = false;
  bool _justWon = false;

  bool? _hasBoardJiggle;

  int get score => _score;
  int get highScore => _highScore;

  List<Tile> get tiles => List.unmodifiable(_tiles);

  Color? get tileBaseColor => _tileBaseColor;

  bool get canUndo => _history.isNotEmpty;
  bool get hasShownWin => _hasShownWin;
  bool get justWon => _justWon;
  bool get isGameOver => !canMove();
  bool get hasWon => _tiles.any((tile) => tile.value >= targetValue);
  bool get hasBoardJiggle => _hasBoardJiggle ?? true;

  Future<void> initialize() async {
    try {
      _tileBaseColor = storage.loadTileColor();

      final currentGame = storage.loadGame();

      if (currentGame == null) {
        _startNewGameState();

        await _save();

        return;
      }

      _restoreGame(currentGame);

      try {
        _history
          ..clear()
          ..addAll(storage.loadHistory());
      } catch (_) {
        _history.clear();
      }

      _highScore = storage.loadHighScore();

      _hasShownWin = storage.loadHasShownWin();
    } catch (_) {
      _startNewGameState();

      await _save();
    }
  }

  Future<void> startGame() async {
    _startNewGameState();

    await _save();
  }

  Future<bool> move(MoveDirection direction) async {
    if (isGameOver) return false;

    final hadWonBefore = hasWon;

    final previousState = _createSnapshot();

    final didMove = switch (direction) {
      .left => moveLeft(),
      .right => moveRight(),
      .up => moveUp(),
      .down => moveDown(),
    };

    if (!didMove) return false;

    _history.add(previousState);

    if (_history.length > maxUndoSteps) _history.removeAt(0);

    spawnTile();

    if (score > _highScore) _highScore = score;

    await _save();

    final hasWonAfter = hasWon;

    _justWon = !hadWonBefore && hasWonAfter;

    return true;
  }

  Future<bool> undo() async {
    if (_history.isEmpty) return false;

    final previousState = _history.removeLast();

    _tiles = previousState.tiles.map((tile) => tile.copy()).toList();

    _score = previousState.score;

    _nextId = previousState.nextId;

    await _save();

    return true;
  }

  Future<void> acknowledgeWin() async {
    if (_hasShownWin) return;

    _hasShownWin = true;

    await _save();
  }

  Future<void> setTileBaseColor(Color color) async {
    _tileBaseColor = color;

    await storage.saveTileColor(color);
  }

  Future<void> setHasBoardJiggle(bool hasBoardJiggle) async {
    _hasBoardJiggle = hasBoardJiggle;

    await storage.saveHasBoardJiggle(hasBoardJiggle);
  }

  bool moveLeft() {
    var didMove = false;

    for (var row = 0; row < size; row++) {
      final rowTiles = <Tile>[];

      for (var col = 0; col < size; col++) {
        final tile = tileAt(row, col);

        if (tile != null) rowTiles.add(tile);
      }

      final merged = _mergeLine(rowTiles);

      for (final tile in rowTiles) {
        if (!merged.contains(tile)) {
          _tiles.remove(tile);

          didMove = true;
        }
      }

      for (var col = 0; col < merged.length; col++) {
        if (merged[col].col != col) didMove = true;

        merged[col].col = col;
      }
    }

    return didMove;
  }

  bool moveRight() {
    var didMove = false;

    for (var row = 0; row < size; row++) {
      final rowTiles = <Tile>[];

      for (var col = size - 1; col >= 0; col--) {
        final tile = tileAt(row, col);

        if (tile != null) rowTiles.add(tile);
      }

      final merged = _mergeLine(rowTiles);

      for (final tile in rowTiles) {
        if (!merged.contains(tile)) {
          _tiles.remove(tile);

          didMove = true;
        }
      }

      for (var i = 0; i < merged.length; i++) {
        if (merged[i].col != size - 1 - i) didMove = true;

        merged[i].col = size - 1 - i;
      }
    }

    return didMove;
  }

  bool moveUp() {
    var didMove = false;

    for (var col = 0; col < size; col++) {
      final columnTiles = <Tile>[];

      for (var row = 0; row < size; row++) {
        final tile = tileAt(row, col);

        if (tile != null) columnTiles.add(tile);
      }

      final merged = _mergeLine(columnTiles);

      for (final tile in columnTiles) {
        if (!merged.contains(tile)) {
          _tiles.remove(tile);

          didMove = true;
        }
      }

      for (var i = 0; i < merged.length; i++) {
        if (merged[i].row != i) didMove = true;

        merged[i].row = i;
      }
    }

    return didMove;
  }

  bool moveDown() {
    var didMove = false;

    for (var col = 0; col < size; col++) {
      final columnTiles = <Tile>[];

      for (var row = size - 1; row >= 0; row--) {
        final tile = tileAt(row, col);

        if (tile != null) columnTiles.add(tile);
      }

      final merged = _mergeLine(columnTiles);

      for (final tile in columnTiles) {
        if (!merged.contains(tile)) {
          _tiles.remove(tile);

          didMove = true;
        }
      }

      for (var i = 0; i < merged.length; i++) {
        if (merged[i].row != size - 1 - i) didMove = true;

        merged[i].row = size - 1 - i;
      }
    }

    return didMove;
  }

  void spawnTile() {
    // Find empty cells.
    // Pick one randomly.
    // Give it a 90% chance of being 2, 10% chance of being 4.
    // Give it a unique ID.

    final emptyCells = <(int, int)>[];

    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final occupied = _tiles.any(
          (tile) => tile.row == row && tile.col == col,
        );

        if (!occupied) emptyCells.add((row, col));
      }
    }

    if (emptyCells.isEmpty) return;

    final (row, col) = emptyCells[random.nextInt(emptyCells.length)];

    final value = random.nextInt(10) == 0 ? 4 : 2;

    _tiles.add(Tile(id: _nextId++, value: value, row: row, col: col));
  }

  bool canMove() {
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        final tile = tileAt(row, col);

        if (tile == null) return true;

        if (col + 1 < size) {
          final rightTile = tileAt(row, col + 1);

          if (rightTile != null && rightTile.value == tile.value) return true;
        }

        if (row + 1 < size) {
          final downTile = tileAt(row + 1, col);

          if (downTile != null && downTile.value == tile.value) return true;
        }
      }
    }

    return false;
  }

  void printBoard() {
    final grid = List.generate(size, (_) => List.filled(size, '.'));

    for (final tile in _tiles) {
      grid[tile.row][tile.col] = tile.value.toString().padLeft(4);
    }

    for (final row in grid) {
      debugPrint(row.join('\t'));
    }

    debugPrint('---');
  }

  Tile? tileAt(int row, int col) {
    for (final tile in _tiles) {
      if (tile.row == row && tile.col == col) return tile;
    }

    return null;
  }

  void setTilesForTesting(List<Tile> tiles) {
    _tiles
      ..clear()
      ..addAll(tiles);
  }

  void _startNewGameState() {
    _tiles.clear();
    _history.clear();

    _score = 0;
    _nextId = 0;
    _hasShownWin = false;

    spawnTile();
    spawnTile();
  }

  Future<void> _save() {
    return storage.saveGame(
      currentGame: _createSnapshot(),
      history: _history,
      highScore: _highScore,
      hasShownWin: _hasShownWin,
    );
  }

  void _restoreGame(GameState state) {
    _tiles = state.tiles.map((tile) => tile.copy()).toList();

    _score = state.score;

    _nextId = state.nextId;
  }

  GameState _createSnapshot() {
    return GameState(
      tiles: _tiles.map((tile) => tile.copy()).toList(),
      score: _score,
      nextId: _nextId,
    );
  }

  List<Tile> _mergeLine(List<Tile> line) {
    final result = <Tile>[];

    for (var i = 0; i < line.length; i++) {
      final current = line[i];

      if (i + 1 < line.length && current.value == line[i + 1].value) {
        current.value *= 2;

        _score += current.value;

        result.add(current);

        i++;
      } else {
        result.add(current);
      }
    }

    return result;
  }
}

import 'package:arcade/features/2048/models/tile.dart';

class GameState {
  final List<Tile> tiles;

  final int score;
  final int nextId;

  GameState({required this.tiles, required this.score, required this.nextId});

  factory GameState.fromJson(Map<String, dynamic> json) {
    final tileList = json['tiles'] as List<dynamic>;

    List<Tile> tileObjects = tileList
        .map((tileJson) => Tile.fromJson(tileJson as Map<String, dynamic>))
        .toList();

    return GameState(
      tiles: tileObjects,
      score: json['score'] as int,
      nextId: json['nextId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tiles': tiles.map((tile) => tile.toJson()).toList(),
      'score': score,
      'nextId': nextId,
    };
  }

  GameState copy() {
    return GameState(
      tiles: tiles.map((tile) => tile.copy()).toList(),
      score: score,
      nextId: nextId,
    );
  }
}

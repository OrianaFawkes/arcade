import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:arcade/features/arcade/world/terrain_type.dart';

class ArcadeWorldLayout {
  final int width;
  final int height;
  final GridPosition spawnPosition;
  final List<List<TerrainType>> terrain;

  const ArcadeWorldLayout({
    required this.width,
    required this.height,
    required this.spawnPosition,
    required this.terrain,
  });

  factory ArcadeWorldLayout.fromJson(Map<String, dynamic> json) {
    final terrainRows = json['terrain'] as List<dynamic>;

    final terrain = terrainRows.map<List<TerrainType>>((row) {
      final rowString = row as String;

      return rowString.split('').map((character) {
        return switch (character) {
          '.' => TerrainType.void_,
          'F' => TerrainType.floor,
          '#' => TerrainType.wall,
          _ => throw FormatException('Unknown terrain character: $character'),
        };
      }).toList();
    }).toList();

    if (terrain.isEmpty) {
      throw const FormatException('World terrain cannot be empty.');
    }

    final width = terrain.first.length;
    final height = terrain.length;

    if (terrain.any((row) => row.length != width)) {
      throw const FormatException('All terrain rows must have the same width.');
    }

    final spawn = json['spawn'] as Map<String, dynamic>;

    final spawnPosition = GridPosition(spawn['x'] as int, spawn['y'] as int);

    if (spawnPosition.x < 0 ||
        spawnPosition.x >= width ||
        spawnPosition.y < 0 ||
        spawnPosition.y >= height) {
      throw const FormatException('Spawn position is outside the world.');
    }

    if (terrain[spawnPosition.y][spawnPosition.x] != TerrainType.floor) {
      throw const FormatException('Spawn position must be on a floor tile.');
    }

    return ArcadeWorldLayout(
      width: width,
      height: height,
      spawnPosition: spawnPosition,
      terrain: terrain,
    );
  }
}

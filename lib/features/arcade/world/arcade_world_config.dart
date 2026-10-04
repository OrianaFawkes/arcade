import 'grid_position.dart';

class ArcadeWorldConfig {
  const ArcadeWorldConfig({
    this.width = 15,
    this.height = 15,
    this.tileWidth = 64,
    this.tileHeight = 32,
    this.spawnPosition,
  });

  final int width;
  final int height;

  final double tileWidth;
  final double tileHeight;

  final GridPosition? spawnPosition;

  GridPosition get resolvedSpawnPosition {
    return spawnPosition ??
        GridPosition(
          width ~/ 2,
          height ~/ 2,
        );
  }
}
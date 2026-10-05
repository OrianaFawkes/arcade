import 'package:arcade/features/arcade/world/grid_position.dart';

class ArcadeWorldConfig {
  final int width;
  final int height;

  final double tileWidth;
  final double tileHeight;

  final GridPosition? spawnPosition;

  const ArcadeWorldConfig({
    this.width = 15,
    this.height = 15,
    this.tileWidth = 64,
    this.tileHeight = 32,
    this.spawnPosition,
  });

  GridPosition get resolvedSpawnPosition {
    return spawnPosition ?? GridPosition(width ~/ 2, height ~/ 2);
  }
}

import 'arcade_world_config.dart';
import 'grid_position.dart';

class ArcadeWorld {
  ArcadeWorld({
    this.config = const ArcadeWorldConfig(),
  }) : playerPosition = config.resolvedSpawnPosition;

  final ArcadeWorldConfig config;

  GridPosition playerPosition;

  int get width => config.width;
  int get height => config.height;

  bool isInside(GridPosition position) {
    return position.x >= 0 &&
        position.x < width &&
        position.y >= 0 &&
        position.y < height;
  }

  bool movePlayer(int dx, int dy) {
    final nextPosition = playerPosition.copyWith(
      x: playerPosition.x + dx,
      y: playerPosition.y + dy,
    );

    if (!isInside(nextPosition)) {
      return false;
    }

    playerPosition = nextPosition;
    return true;
  }
}
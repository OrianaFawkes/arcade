import 'package:arcade/features/arcade/world/arcade_grid.dart';
import 'package:arcade/features/arcade/world/arcade_world_config.dart';
import 'package:arcade/features/arcade/world/grid_position.dart';

class ArcadeWorld {
  final ArcadeWorldConfig config;

  final ArcadeGrid grid;

  GridPosition playerPosition;

  ArcadeWorld({this.config = const ArcadeWorldConfig()})
    : grid = ArcadeGrid(width: config.width, height: config.height),
      playerPosition = config.resolvedSpawnPosition {
    buildPrototypeWalls();
  }

  void buildPrototypeWalls() {
    for (var x = 3; x < 12; x++) {
      grid.setCell(GridPosition(x, 7), .wall);
    }
  }

  bool movePlayer(int dx, int dy) {
    final nextPosition = playerPosition.copyWith(
      x: playerPosition.x + dx,
      y: playerPosition.y + dy,
    );

    if (!grid.isWalkable(nextPosition)) return false;

    playerPosition = nextPosition;

    return true;
  }
}

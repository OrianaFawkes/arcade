import 'package:arcade/features/arcade/world/arcade_grid.dart';
import 'package:arcade/features/arcade/world/arcade_world_layout.dart';
import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:arcade/features/arcade/world/player_direction.dart';

class ArcadeWorld {
  final ArcadeWorldLayout layout;

  final ArcadeGrid grid;

  GridPosition playerPosition;

  PlayerDirection playerDirection = .south;

  ArcadeWorld({required this.layout})
    : grid = ArcadeGrid(width: layout.width, height: layout.height),
      playerPosition = layout.spawnPosition {
    _applyTerrain();
  }

  void _applyTerrain() {
    for (var y = 0; y < layout.height; y++) {
      for (var x = 0; x < layout.width; x++) {
        grid.setTerrain(GridPosition(x, y), layout.terrain[y][x]);
      }
    }
  }

  bool movePlayer(int dx, int dy) {
    if (dx > 0) {
      playerDirection = .east;
    } else if (dx < 0) {
      playerDirection = .west;
    } else if (dy > 0) {
      playerDirection = .south;
    } else if (dy < 0) {
      playerDirection = .north;
    }

    final nextPosition = playerPosition.copyWith(
      x: playerPosition.x + dx,
      y: playerPosition.y + dy,
    );

    if (!grid.isWalkable(nextPosition)) return false;

    playerPosition = nextPosition;

    return true;
  }
}

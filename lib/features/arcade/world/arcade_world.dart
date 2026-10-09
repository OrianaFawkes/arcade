import 'package:arcade/features/arcade/world/arcade_grid.dart';
import 'package:arcade/features/arcade/world/arcade_station.dart';
import 'package:arcade/features/arcade/world/arcade_world_layout.dart';
import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:arcade/features/arcade/world/player_direction.dart';

class ArcadeWorld {
  final ArcadeWorldLayout layout;

  final ArcadeGrid grid;

  late final List<ArcadeStation> stations;

  GridPosition playerPosition;

  PlayerDirection playerDirection = PlayerDirection.south;

  ArcadeWorld({required this.layout})
    : grid = ArcadeGrid(width: layout.width, height: layout.height),
      playerPosition = layout.spawnPosition {
    stations = List.unmodifiable(layout.stations);

    _applyTerrain();

    _applyStations();
  }

  void _applyTerrain() {
    for (var y = 0; y < layout.height; y++) {
      for (var x = 0; x < layout.width; x++) {
        grid.setTerrain(GridPosition(x, y), layout.terrain[y][x]);
      }
    }
  }

  void _applyStations() {
    for (final station in stations) {
      if (!grid.isInside(station.position)) {
        throw FormatException('Station "${station.id}" is outside the world.');
      }

      if (grid.cellAt(station.position).terrain != .floor) {
        throw FormatException(
          'Station "${station.id}" must be placed on a floor tile.',
        );
      }

      grid.setBlocked(station.position, true);
    }
  }

  bool movePlayer(int dx, int dy) {
    if (dx > 0) {
      playerDirection = PlayerDirection.east;
    } else if (dx < 0) {
      playerDirection = PlayerDirection.west;
    } else if (dy > 0) {
      playerDirection = PlayerDirection.south;
    } else if (dy < 0) {
      playerDirection = PlayerDirection.north;
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

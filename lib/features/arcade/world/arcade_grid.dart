import 'package:arcade/features/arcade/world/arcade_cell.dart';
import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:arcade/features/arcade/world/terrain_type.dart';

class ArcadeGrid {
  final int width;
  final int height;

  final List<List<ArcadeCell>> _cells;

  ArcadeGrid({required this.width, required this.height})
    : _cells = List.generate(
        height,
        (_) => List.generate(width, (_) => ArcadeCell()),
      );

  bool isInside(GridPosition position) {
    return position.x >= 0 &&
        position.x < width &&
        position.y >= 0 &&
        position.y < height;
  }

  ArcadeCell cellAt(GridPosition position) {
    if (!isInside(position)) {
      throw RangeError('Position is outside the grid: $position');
    }

    return _cells[position.y][position.x];
  }

  void setTerrain(GridPosition position, TerrainType terrain) {
    if (!isInside(position)) {
      throw RangeError('Position is outside the grid: $position');
    }

    _cells[position.y][position.x].terrain = terrain;
  }

  bool isWalkable(GridPosition position) {
    return isInside(position) && cellAt(position).terrain == .floor;
  }
}

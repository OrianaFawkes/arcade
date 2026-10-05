import 'package:arcade/features/arcade/world/grid_position.dart';

enum GridCellType { floor, wall }

class ArcadeGrid {
  final int width;
  final int height;

  final List<List<GridCellType>> _cells;

  ArcadeGrid({required this.width, required this.height})
    : _cells = List.generate(height, (_) => List.filled(width, .floor));

  bool isInside(GridPosition position) {
    return position.x >= 0 &&
        position.x < width &&
        position.y >= 0 &&
        position.y < height;
  }

  GridCellType cellAt(GridPosition position) {
    if (!isInside(position)) {
      throw RangeError('Position is outside the grid: $position');
    }

    return _cells[position.y][position.x];
  }

  void setCell(GridPosition position, GridCellType type) {
    if (!isInside(position)) {
      throw RangeError('Position is outside the grid: $position');
    }

    _cells[position.y][position.x] = type;
  }

  bool isWalkable(GridPosition position) {
    return isInside(position) && cellAt(position) == .floor;
  }
}

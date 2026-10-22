import 'package:arcade/features/arcade/domain/arcade_world.dart';
import 'package:arcade/features/arcade/domain/grid_position.dart';

class ArcadeTileResolver {
  const ArcadeTileResolver();

  String resolve(ArcadeWorld world, GridPosition position) {
    final terrain = world.grid.cellAt(position).terrain;

    if (terrain != .floor && terrain != .wall) {
      throw ArgumentError('Only floor and wall tiles have sprites.');
    }

    final directions = <(int dx, int dy, String name)>[
      (0, -1, 'north'),
      (1, 0, 'east'),
      (0, 1, 'south'),
      (-1, 0, 'west'),
    ];

    final ends = <String>[];

    for (final (dx, dy, name) in directions) {
      final x = position.x + dx;
      final y = position.y + dy;

      final outOfBounds =
          x < 0 || y < 0 || x >= world.grid.width || y >= world.grid.height;

      if (outOfBounds) {
        ends.add(name);
        continue;
      }

      final neighbor = world.grid.cellAt(GridPosition(x, y));

      if (neighbor.terrain != terrain) {
        ends.add(name);
      }
    }

    final prefix = terrain == .floor ? 'floor' : 'wall';

    if (ends.isEmpty) return prefix;

    return '${prefix}_end_${ends.join('_')}';
  }
}

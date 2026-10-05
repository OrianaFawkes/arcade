import 'package:arcade/features/arcade/world/arcade_grid.dart';
import 'package:arcade/features/arcade/world/grid_position.dart';

class PathFinder {
  const PathFinder();

  List<GridPosition>? findPath({
    required ArcadeGrid grid,
    required GridPosition start,
    required GridPosition goal,
  }) {
    if (!grid.isWalkable(start) || !grid.isWalkable(goal)) {
      return null;
    }

    if (start == goal) {
      return [start];
    }

    final openSet = <GridPosition>{start};
    final cameFrom = <GridPosition, GridPosition>{};

    final gScore = <GridPosition, int>{start: 0};

    final fScore = <GridPosition, int>{start: _heuristic(start, goal)};

    while (openSet.isNotEmpty) {
      final current = _lowestScore(openSet, fScore);

      if (current == goal) {
        return _reconstructPath(cameFrom, current);
      }

      openSet.remove(current);

      for (final neighbor in _neighbors(current)) {
        if (!grid.isWalkable(neighbor)) {
          continue;
        }

        final tentativeGScore = (gScore[current] ?? 1 << 30) + 1;

        if (tentativeGScore < (gScore[neighbor] ?? 1 << 30)) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] = tentativeGScore + _heuristic(neighbor, goal);

          openSet.add(neighbor);
        }
      }
    }

    return null;
  }

  int _heuristic(GridPosition a, GridPosition b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  Iterable<GridPosition> _neighbors(GridPosition position) sync* {
    yield position.copyWith(y: position.y - 1);
    yield position.copyWith(y: position.y + 1);
    yield position.copyWith(x: position.x - 1);
    yield position.copyWith(x: position.x + 1);
  }

  GridPosition _lowestScore(
    Set<GridPosition> positions,
    Map<GridPosition, int> scores,
  ) {
    return positions.reduce(
      (a, b) => (scores[a] ?? 1 << 30) <= (scores[b] ?? 1 << 30) ? a : b,
    );
  }

  List<GridPosition> _reconstructPath(
    Map<GridPosition, GridPosition> cameFrom,
    GridPosition current,
  ) {
    final path = <GridPosition>[current];

    while (cameFrom.containsKey(current)) {
      current = cameFrom[current]!;
      path.add(current);
    }

    return path.reversed.toList();
  }
}

import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:flutter/material.dart';

class IsometricProjection {
  final double tileWidth;
  final double tileHeight;

  const IsometricProjection({
    required this.tileWidth,
    required this.tileHeight,
  });

  Offset worldToScreen(GridPosition position) {
    return Offset(
      (position.x - position.y) * tileWidth / 2,
      (position.x + position.y) * tileHeight / 2,
    );
  }

  GridPosition screenToGrid(Offset screenPosition) {
    final x = screenPosition.dx / tileWidth + screenPosition.dy / tileHeight;

    final y = screenPosition.dy / tileHeight - screenPosition.dx / tileWidth;

    return GridPosition(x.round(), y.round());
  }
}

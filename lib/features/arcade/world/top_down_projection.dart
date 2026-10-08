import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:flutter/material.dart';

class TopDownProjection {
  final double tileWidth;
  final double tileHeight;

  const TopDownProjection({required this.tileWidth, required this.tileHeight});

  Offset worldToScreen(GridPosition position) {
    return Offset(
      (position.x + 0.5) * tileWidth,
      (position.y + 0.5) * tileHeight,
    );
  }

  GridPosition screenToGrid(Offset screenPosition) {
    final x = screenPosition.dx / tileWidth;
    final y = screenPosition.dy / tileHeight;

    return GridPosition(x.floor(), y.floor());
  }
}

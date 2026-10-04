import 'package:flutter/material.dart';

import 'grid_position.dart';

class ArcadeCamera {
  ArcadeCamera({
    this.smoothing = 0.12,
  });

  final double smoothing;

  Offset position = Offset.zero;
  Offset target = Offset.zero;

  void follow(
    GridPosition targetPosition, {
    required double tileWidth,
    required double tileHeight,
  }) {
    target = Offset(
      (targetPosition.x - targetPosition.y) * tileWidth / 2,
      (targetPosition.x + targetPosition.y) * tileHeight / 2,
    );
  }

  void update() {
    position += (target - position) * smoothing;
  }
}
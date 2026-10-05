import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:arcade/features/arcade/world/isometric_projection.dart';
import 'package:flutter/material.dart';

class ArcadeCamera {
  final double smoothing;

  Offset position = .zero;
  Offset target = .zero;

  ArcadeCamera({this.smoothing = 0.12});

  void follow(
    GridPosition targetPosition, {
    required IsometricProjection projection,
  }) {
    target = projection.worldToScreen(targetPosition);
  }

  void update() {
    position += (target - position) * smoothing;
  }
}

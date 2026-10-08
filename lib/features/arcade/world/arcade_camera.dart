import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:arcade/features/arcade/world/top_down_projection.dart';
import 'package:flutter/material.dart';

class ArcadeCamera {
  final double smoothing;

  Offset position = .zero;
  Offset target = .zero;

  ArcadeCamera({this.smoothing = 0.12});

  void follow(
    GridPosition targetPosition, {
    required TopDownProjection projection,
  }) {
    target = projection.worldToScreen(targetPosition);
  }

  void snapTo(
    GridPosition targetPosition, {
    required TopDownProjection projection,
  }) {
    target = projection.worldToScreen(targetPosition);

    position = target;
  }

  void update() {
    position += (target - position) * smoothing;
  }
}

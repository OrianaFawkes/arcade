import 'package:arcade/features/arcade/world/arcade_camera.dart';
import 'package:arcade/features/arcade/world/arcade_world.dart';
import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:arcade/features/arcade/world/top_down_projection.dart';
import 'package:flutter/material.dart';

class ArcadeWorldPainter extends CustomPainter {
  final ArcadeWorld world;
  final ArcadeCamera camera;
  final TopDownProjection projection;

  const ArcadeWorldPainter({
    required this.world,
    required this.camera,
    required this.projection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cameraOffset = center - camera.position;

    final floorPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF3A3A3A);

    final wallPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF111111);

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF666666);

    for (var y = 0; y < world.grid.height; y++) {
      for (var x = 0; x < world.grid.width; x++) {
        final position = GridPosition(x, y);
        final cell = world.grid.cellAt(position);

        if (cell.terrain == .void_) {
          continue;
        }

        final tileCenter = cameraOffset + projection.worldToScreen(position);

        final rect = Rect.fromCenter(
          center: tileCenter,
          width: projection.tileWidth,
          height: projection.tileHeight,
        );

        switch (cell.terrain) {
          case .floor:
            canvas.drawRect(rect, floorPaint);
            canvas.drawRect(rect, gridPaint);

          case .wall:
            canvas.drawRect(rect, wallPaint);
            canvas.drawRect(rect, gridPaint);

          case .void_:
            break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ArcadeWorldPainter oldDelegate) {
    return true;
  }
}

import 'package:arcade/features/arcade/world/arcade_camera.dart';
import 'package:arcade/features/arcade/world/arcade_world.dart';
import 'package:arcade/features/arcade/world/grid_position.dart';
import 'package:arcade/features/arcade/world/isometric_projection.dart';
import 'package:flutter/material.dart';

class ArcadeWorldPainter extends CustomPainter {
  final ArcadeWorld world;

  final ArcadeCamera camera;

  final IsometricProjection projection;

  ArcadeWorldPainter({
    required this.world,
    required this.camera,
    required this.projection,
  });

  double get tileWidth => world.config.tileWidth;
  double get tileHeight => world.config.tileHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = .stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);

    final cameraOffset = center - camera.position;

    for (var y = 0; y < world.grid.height; y++) {
      for (var x = 0; x < world.grid.width; x++) {
        final position = GridPosition(x, y);
        final screenPosition =
            cameraOffset + projection.worldToScreen(position);

        final path = Path()
          ..moveTo(screenPosition.dx, screenPosition.dy - tileHeight / 2)
          ..lineTo(screenPosition.dx + tileWidth / 2, screenPosition.dy)
          ..lineTo(screenPosition.dx, screenPosition.dy + tileHeight / 2)
          ..lineTo(screenPosition.dx - tileWidth / 2, screenPosition.dy)
          ..close();

        final cellType = world.grid.cellAt(position);

        if (cellType == .wall) {
          final wallPaint = Paint()..style = .fill;

          canvas.drawPath(path, wallPaint);
        } else {
          canvas.drawPath(path, paint);
        }
      }
    }

    final playerPosition =
        cameraOffset + projection.worldToScreen(world.playerPosition);

    final playerPaint = Paint()..style = .fill;

    canvas.drawCircle(playerPosition.translate(0, -12), 10, playerPaint);
  }

  @override
  bool shouldRepaint(covariant ArcadeWorldPainter oldDelegate) {
    return true;
  }
}

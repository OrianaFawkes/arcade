import 'package:arcade/features/arcade/world/arcade_camera.dart';
import 'package:flutter/material.dart';

import 'arcade_world.dart';
import 'grid_position.dart';

class ArcadeWorldPainter extends CustomPainter {
  ArcadeWorldPainter({
    required this.world,
    required this.camera,
  });

  final ArcadeWorld world;
  final ArcadeCamera camera;

  double get tileWidth => world.config.tileWidth;
  double get tileHeight => world.config.tileHeight;

  Offset worldToScreen(GridPosition position) {
    return Offset(
      (position.x - position.y) * tileWidth / 2,
      (position.x + position.y) * tileHeight / 2,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final cameraOffset = center - camera.position;

    for (var y = 0; y < world.height; y++) {
      for (var x = 0; x < world.width; x++) {
        final position = GridPosition(x, y);
        final screenPosition = cameraOffset + worldToScreen(position);

        final path = Path()
          ..moveTo(
            screenPosition.dx,
            screenPosition.dy - tileHeight / 2,
          )
          ..lineTo(
            screenPosition.dx + tileWidth / 2,
            screenPosition.dy,
          )
          ..lineTo(
            screenPosition.dx,
            screenPosition.dy + tileHeight / 2,
          )
          ..lineTo(
            screenPosition.dx - tileWidth / 2,
            screenPosition.dy,
          )
          ..close();

        canvas.drawPath(path, paint);
      }
    }

    // Player.
    final playerPosition = cameraOffset + worldToScreen(world.playerPosition);

    final playerPaint = Paint()
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      playerPosition.translate(0, -12),
      10,
      playerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ArcadeWorldPainter oldDelegate) {
    return true;
  }
}
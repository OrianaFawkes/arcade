import 'package:arcade/features/arcade/config/arcade_visual_config.dart';
import 'package:arcade/features/arcade/presentation/camera/arcade_camera.dart';
import 'package:arcade/features/arcade/domain/arcade_world.dart';
import 'package:arcade/features/arcade/domain/grid_position.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_pixel_sprite_painter.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_sprite_registry.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_tile_resolver.dart';
import 'package:arcade/features/arcade/presentation/rendering/top_down_projection.dart';
import 'package:flutter/material.dart';

class ArcadeWorldPainter extends CustomPainter {
  final ArcadeWorld world;

  final ArcadeCamera camera;

  final TopDownProjection projection;

  final ArcadeVisualConfig visualConfig;

  final ArcadeTileResolver tileResolver;

  const ArcadeWorldPainter({
    required this.world,
    required this.camera,
    required this.projection,
    required this.visualConfig,
    this.tileResolver = const ArcadeTileResolver(),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cameraOffset = center - camera.position;

    for (var y = 0; y < world.grid.height; y++) {
      for (var x = 0; x < world.grid.width; x++) {
        final position = GridPosition(x, y);

        final cell = world.grid.cellAt(position);

        // Floors belong to the background layer.
        // Walls are rendered separately in depth order.
        if (cell.terrain != .floor) continue;

        final tileCenter = cameraOffset + projection.worldToScreen(position);

        final spriteId = tileResolver.resolve(world, position);
        final pixels = ArcadeSpriteRegistry.pixelsFor(spriteId);

        final destination = Rect.fromCenter(
          center: tileCenter,
          width: visualConfig.tileWidth,
          height: visualConfig.tileHeight,
        );

        drawPixelSprite(canvas, pixels, destination);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ArcadeWorldPainter oldDelegate) {
    return false;
  }
}

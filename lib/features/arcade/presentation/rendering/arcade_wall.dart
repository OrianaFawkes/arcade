import 'package:arcade/features/arcade/config/arcade_visual_config.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_pixel_sprite_painter.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_sprite_registry.dart';
import 'package:flutter/material.dart';

class ArcadeWall extends StatelessWidget {
  final String spriteId;

  final Offset groundPosition;

  final ArcadeVisualConfig visualConfig;

  const ArcadeWall({
    super.key,
    required this.spriteId,
    required this.groundPosition,
    required this.visualConfig,
  });

  @override
  Widget build(_) {
    final spriteWidth = visualConfig.tileWidth;
    final spriteHeight = visualConfig.wallHeight;

    final pixels = ArcadeSpriteRegistry.pixelsFor(spriteId);

    return Positioned(
      left: groundPosition.dx - spriteWidth / 2,
      top: groundPosition.dy - spriteHeight,
      width: spriteWidth,
      height: spriteHeight,
      child: CustomPaint(
        painter: _ArcadeWallSpritePainter(pixels),
        isComplex: true,
        willChange: false,
        child: SizedBox.expand(),
      ),
    );
  }
}

class _ArcadeWallSpritePainter extends CustomPainter {
  final PixelMatrix pixels;

  const _ArcadeWallSpritePainter(this.pixels);

  @override
  void paint(Canvas canvas, Size size) {
    drawPixelSprite(canvas, pixels, Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant _ArcadeWallSpritePainter oldDelegate) {
    return false;
  }
}

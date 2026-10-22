import 'dart:ui' as ui;

import 'package:arcade/features/arcade/config/arcade_visual_config.dart';
import 'package:arcade/features/arcade/presentation/rendering/arcade_sprite_cache.dart';
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

    final image = ArcadeSpriteCache.instance.imageFor(spriteId);

    if (image == null) {
      return SizedBox.shrink();
    }

    return Positioned(
      left: groundPosition.dx - spriteWidth / 2,
      top: groundPosition.dy - spriteHeight,
      width: spriteWidth,
      height: spriteHeight,
      child: CustomPaint(
        painter: _ArcadeWallSpritePainter(image),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _ArcadeWallSpritePainter extends CustomPainter {
  final ui.Image image;

  const _ArcadeWallSpritePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size,
      Paint()
        ..filterQuality = .none
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcadeWallSpritePainter oldDelegate) {
    return !identical(oldDelegate.image, image);
  }
}

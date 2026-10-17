import 'package:arcade/features/arcade/config/arcade_visual_config.dart';
import 'package:flutter/material.dart';

class ArcadeWall extends StatelessWidget {
  final String spriteAsset;

  final Offset groundPosition;

  final ArcadeVisualConfig visualConfig;

  const ArcadeWall({
    super.key,
    required this.spriteAsset,
    required this.groundPosition,
    required this.visualConfig,
  });

  @override
  Widget build(BuildContext context) {
    final spriteWidth = visualConfig.tileWidth;
    final spriteHeight = visualConfig.wallHeight;

    return Positioned(
      left: groundPosition.dx - spriteWidth / 2,
      top: groundPosition.dy - spriteHeight,
      width: spriteWidth,
      height: spriteHeight,
      child: Image.asset(
        spriteAsset,
        width: spriteWidth,
        height: spriteHeight,
        fit: .fill,
        filterQuality: .none,
      ),
    );
  }
}

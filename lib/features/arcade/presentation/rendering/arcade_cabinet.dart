import 'package:arcade/features/arcade/config/arcade_visual_config.dart';
import 'package:flutter/material.dart';

class ArcadeCabinet extends StatelessWidget {
  final String label;
  final String spriteAsset;

  final Offset groundPosition;

  final bool canInteract;

  final ArcadeVisualConfig visualConfig;

  const ArcadeCabinet({
    super.key,
    this.label = 'PLAY',
    required this.spriteAsset,
    required this.groundPosition,
    required this.canInteract,
    required this.visualConfig,
  });

  @override
  Widget build(_) {
    final spriteWidth = visualConfig.tileWidth;
    final spriteHeight = visualConfig.stationHeight;

    final heightOffset = visualConfig.tileHeight / 2;

    // TODO: if canInteract, play animation of the cabinet (like a blinking light or something)
    return Positioned(
      left: groundPosition.dx - spriteWidth / 2,
      top: groundPosition.dy - spriteHeight + heightOffset,
      width: spriteWidth,
      height: spriteHeight,
      child: Tooltip(
        message: label,
        child: Image.asset(
          spriteAsset,
          width: spriteWidth,
          height: spriteHeight,
          fit: .fill,
          filterQuality: .none,
        ),
      ),
    );
  }
}

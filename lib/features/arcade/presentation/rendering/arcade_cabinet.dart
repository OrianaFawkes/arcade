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

    return Positioned(
      left: groundPosition.dx - spriteWidth / 2,
      top: groundPosition.dy - spriteHeight + heightOffset,
      width: spriteWidth,
      height: spriteHeight,
      child: Stack(
        children: [
          Image.asset(
            spriteAsset,
            width: spriteWidth,
            height: spriteHeight,
            fit: .fill,
            filterQuality: .none,
          ),
          if (canInteract) ...[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white70),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'E  PLAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:arcade/features/arcade/config/arcade_visual_config.dart';
import 'package:arcade/features/arcade/domain/player_direction.dart';
import 'package:flutter/material.dart';

class ArcadePlayer extends StatefulWidget {
  final PlayerDirection direction;

  final Offset groundPosition;

  final bool isMoving;

  final ArcadeVisualConfig visualConfig;

  const ArcadePlayer({
    super.key,
    required this.direction,
    required this.groundPosition,
    required this.isMoving,
    required this.visualConfig,
  });

  @override
  State<ArcadePlayer> createState() => _ArcadePlayerState();
}

class _ArcadePlayerState extends State<ArcadePlayer>
    with SingleTickerProviderStateMixin {
  static const _idleRight = 'assets/sprites/player/ori_2026-right-standing.png';
  static const _idleLeft = 'assets/sprites/player/ori_2026-left-standing.png';
  static const _walkRightA = 'assets/sprites/player/ori_2026-right-both-up.png';
  static const _walkRightB =
      'assets/sprites/player/ori_2026-right-both-legs-up.png';
  static const _walkLeftA = 'assets/sprites/player/ori_2026-left-both-up.png';
  static const _walkLeftB =
      'assets/sprites/player/ori_2026-left-both-legs-up.png';

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 320),
    );

    if (widget.isMoving) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ArcadePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isMoving && !oldWidget.isMoving) {
      _animationController.repeat();
    } else if (!widget.isMoving && oldWidget.isMoving) {
      _animationController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  bool get _facesRight =>
      widget.direction == .east || widget.direction == .north;

  String get _spriteAsset {
    if (!widget.isMoving) return _facesRight ? _idleRight : _idleLeft;

    final secondFrame = _animationController.value >= 0.5;

    if (_facesRight) return secondFrame ? _walkRightB : _walkRightA;

    return secondFrame ? _walkLeftB : _walkLeftA;
  }

  double get _bounce {
    if (!widget.isMoving) return 0;

    return -math.sin(_animationController.value * 2 * math.pi) *
        widget.visualConfig.playerBounceHeight;
  }

  @override
  Widget build(_) {
    final spriteWidth = widget.visualConfig.playerWidth;
    final spriteHeight = widget.visualConfig.playerHeight;

    final shadowWidth = widget.visualConfig.playerShadowWidth;
    final shadowHeight = widget.visualConfig.playerShadowHeight;

    final heightOffset = widget.visualConfig.tileHeight / 3;

    return Positioned(
      left: widget.groundPosition.dx - spriteWidth / 2,
      top: widget.groundPosition.dy - spriteHeight + heightOffset,
      width: spriteWidth,
      height: spriteHeight,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            clipBehavior: .none,
            children: [
              Positioned(
                left: (spriteWidth - shadowWidth) / 2,
                bottom: 0,
                width: shadowWidth,
                height: shadowHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: .circular(0.0),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: shadowHeight,
                width: spriteWidth,
                height: spriteHeight - shadowHeight,
                child: Transform.translate(
                  offset: Offset(0, _bounce),
                  child: Image.asset(
                    _spriteAsset,
                    width: spriteWidth,
                    height: spriteHeight - shadowHeight,
                    fit: .contain,
                    filterQuality: .none,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

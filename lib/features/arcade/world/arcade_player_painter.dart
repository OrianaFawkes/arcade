import 'dart:math' as math;

import 'package:arcade/features/arcade/world/player_direction.dart';
import 'package:flutter/material.dart';

class ArcadePlayerPainter extends StatefulWidget {
  final Offset groundPosition;

  final PlayerDirection direction;

  final bool isMoving;

  const ArcadePlayerPainter({
    super.key,
    required this.groundPosition,
    required this.direction,
    required this.isMoving,
  });

  @override
  State<ArcadePlayerPainter> createState() => _ArcadePlayerPainterState();
}

class _ArcadePlayerPainterState extends State<ArcadePlayerPainter>
    with SingleTickerProviderStateMixin {
  static const _idleRight =
      'assets/sprites/player/ori_2026-right-standing-24x33.png';
  static const _idleLeft =
      'assets/sprites/player/ori_2026-left-standing-24x33.png';

  static const _walkRightA =
      'assets/sprites/player/ori_2026-right-both-up-30x33.png';
  static const _walkRightB =
      'assets/sprites/player/ori_2026-right-both-legs-up-30x31.png';
  static const _walkLeftA =
      'assets/sprites/player/ori_2026-left-both-up-30x33.png';
  static const _walkLeftB =
      'assets/sprites/player/ori_2026-left-both-legs-up-30x31.png';

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    if (widget.isMoving) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ArcadePlayerPainter oldWidget) {
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
      widget.direction == PlayerDirection.east ||
      widget.direction == PlayerDirection.north;

  String get _spriteAsset {
    if (!widget.isMoving) {
      return _facesRight ? _idleRight : _idleLeft;
    }

    final secondFrame = _animationController.value >= 0.5;

    if (_facesRight) {
      return secondFrame ? _walkRightB : _walkRightA;
    }

    return secondFrame ? _walkLeftB : _walkLeftA;
  }

  double get _bounce {
    if (!widget.isMoving) return 0;

    return -math.sin(_animationController.value * 2 * math.pi) * 1.5;
  }

  @override
  Widget build(BuildContext context) {
    const spriteWidth = 40.0;
    const spriteHeight = 44.0;
    const shadowWidth = 20.0;
    const shadowHeight = 6.0;

    return Positioned(
      left: widget.groundPosition.dx - spriteWidth / 2,
      top: widget.groundPosition.dy - spriteHeight,
      width: spriteWidth,
      height: spriteHeight,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // The shadow stays on the ground while the sprite bounces.
              Positioned(
                left: (spriteWidth - shadowWidth) / 2,
                bottom: 0,
                width: shadowWidth,
                height: shadowHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(100),
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
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
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

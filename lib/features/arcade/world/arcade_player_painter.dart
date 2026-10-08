import 'dart:math';

import 'package:arcade/features/arcade/world/player_direction.dart';
import 'package:flutter/material.dart';

class ArcadePlayerPainter extends StatefulWidget {
  final Offset screenPosition;

  final PlayerDirection direction;

  final bool isMoving;

  const ArcadePlayerPainter({
    super.key,
    required this.screenPosition,
    required this.direction,
    required this.isMoving,
  });

  @override
  State<ArcadePlayerPainter> createState() => _ArcadePlayerPainterState();
}

class _ArcadePlayerPainterState extends State<ArcadePlayerPainter>
    with SingleTickerProviderStateMixin {
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
      _animationController.stop();
      _animationController.value = 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _spriteAsset {
    final facingRight = widget.direction == .east || widget.direction == .north;

    final walkingFrame = _animationController.value >= 0.5;

    if (facingRight) {
      return walkingFrame
          ? 'assets/sprites/player/ori_2026-right-both-legs-up-30x31.png'
          : 'assets/sprites/player/ori_2026-right-both-up-30x33.png';
    }

    return walkingFrame
        ? 'assets/sprites/player/ori_2026-left-both-legs-up-30x31.png'
        : 'assets/sprites/player/ori_2026-left-both-up-30x33.png';
  }

  double get _bounce {
    if (!widget.isMoving) {
      return 0;
    }

    return -sin(_animationController.value * 2 * pi) * 2;
  }

  @override
  Widget build(BuildContext context) {
    const width = 64.0;
    const height = 64.0;

    return Positioned(
      left: widget.screenPosition.dx - width / 2,
      top: widget.screenPosition.dy - height / 2,
      width: width,
      height: height,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 5,
                child: Container(
                  width: 24,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, _bounce),
                child: Image.asset(
                  _spriteAsset,
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PixelShadow extends StatelessWidget {
  final CustomPainter shadowPainter;
  final Widget child;
  final Offset offset;
  final double opacity;

  const PixelShadow({
    super.key,
    required this.shadowPainter,
    required this.child,
    this.offset = const Offset(0, 4),
    this.opacity = 0.5,
  });

  @override
  Widget build(_) {
    return Stack(
      alignment: .center,
      children: [
        Positioned.fill(
          child: Transform.translate(
            offset: offset,
            child: Opacity(
              opacity: opacity,
              child: RepaintBoundary(
                child: CustomPaint(painter: shadowPainter),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

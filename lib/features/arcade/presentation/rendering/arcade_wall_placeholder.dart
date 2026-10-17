import 'package:flutter/material.dart';

class ArcadeWallPlaceholder extends StatelessWidget {
  final Offset groundPosition;
  final double tileWidth;
  final double visualHeight;

  const ArcadeWallPlaceholder({
    super.key,
    required this.groundPosition,
    required this.tileWidth,
    this.visualHeight = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: groundPosition.dx - tileWidth / 2,
      top: groundPosition.dy - visualHeight,
      width: tileWidth,
      height: visualHeight,
      child: CustomPaint(painter: _ArcadeWallPlaceholderPainter()),
    );
  }
}

class _ArcadeWallPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const topThickness = 4.0;

    final frontPaint = Paint()..color = const Color(0xFF484848);

    final topPaint = Paint()..color = const Color(0xFF777777);

    final outlinePaint = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final front = Rect.fromLTWH(
      0,
      topThickness,
      size.width,
      size.height - topThickness,
    );

    final top = Rect.fromLTWH(0, 0, size.width, topThickness);

    canvas
      ..drawRect(front, frontPaint)
      ..drawRect(top, topPaint)
      ..drawRect(front, outlinePaint)
      ..drawRect(top, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _ArcadeWallPlaceholderPainter oldDelegate) =>
      false;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

// TODO: fix existing bug for left and right panel sides
enum PanelSide { none, top, right, bottom, left }

class PixelPanelPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;

  final double pixelSize;

  final int radius;
  final int borderThickness;

  final PanelSide flatSide;

  const PixelPanelPainter({
    required this.borderColor,
    required this.fillColor,
    this.pixelSize = 2.0,
    this.radius = 16,
    this.borderThickness = 1,
    this.flatSide = PanelSide.none,
  });

  PixelPanelPainter copyWith({
    Color? borderColor,
    Color? fillColor,
    Color? baseColor,
    PanelSide? flatSide,
  }) {
    return PixelPanelPainter(
      borderColor: baseColor ?? borderColor ?? this.borderColor,
      fillColor: baseColor ?? fillColor ?? this.fillColor,
      pixelSize: pixelSize,
      radius: radius,
      borderThickness: borderThickness,
      flatSide: flatSide ?? this.flatSide,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final isFlatTop = flatSide == PanelSide.top;
    final isFlatBottom = flatSide == PanelSide.bottom;
    final isFlatLeft = flatSide == PanelSide.left;
    final isFlatRight = flatSide == PanelSide.right;

    final roundTopLeft = !isFlatTop && !isFlatLeft;
    final roundTopRight = !isFlatTop && !isFlatRight;
    final roundBottomLeft = !isFlatBottom && !isFlatLeft;
    final roundBottomRight = !isFlatBottom && !isFlatRight;

    final drawTopBorder = !isFlatTop;
    final drawBottomBorder = !isFlatBottom;
    final drawLeftBorder = !isFlatLeft;
    final drawRightBorder = !isFlatRight;

    final paint = Paint()..isAntiAlias = false;

    final p = pixelSize;

    final rows = (size.height / p).floor();
    final cols = (size.width / p).floor();

    final r = math.min(radius, (math.min(rows, cols) ~/ 2));
    final t = borderThickness;

    paint.color = fillColor;

    canvas.drawRect(
      Rect.fromLTWH(r * p, r * p, (cols - 2 * r) * p, (rows - 2 * r) * p),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(r * p, t * p, (cols - 2 * r) * p, (r - t) * p),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(r * p, (rows - r) * p, (cols - 2 * r) * p, (r - t) * p),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(t * p, r * p, (r - t) * p, (rows - 2 * r) * p),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH((cols - r) * p, r * p, (r - t) * p, (rows - 2 * r) * p),
      paint,
    );

    if (!roundBottomLeft) {
      canvas.drawRect(Rect.fromLTWH(0, (rows - r) * p, r * p, r * p), paint);
    }
    if (!roundBottomRight) {
      canvas.drawRect(
        Rect.fromLTWH((cols - r) * p, (rows - r) * p, r * p, r * p),
        paint,
      );
    }
    if (!roundTopLeft) {
      canvas.drawRect(Rect.fromLTWH(0, 0, r * p, r * p), paint);
    }
    if (!roundTopRight) {
      canvas.drawRect(Rect.fromLTWH((cols - r) * p, 0, r * p, r * p), paint);
    }

    paint.color = borderColor;

    final leftTop = roundTopLeft ? r * p : 0.0;
    final rightTop = roundTopRight ? r * p : 0.0;

    paint.color = drawTopBorder ? borderColor : fillColor;

    canvas.drawRect(
      Rect.fromLTWH(leftTop, 0, cols * p - leftTop - rightTop, t * p),
      paint,
    );

    final leftBottom = roundBottomLeft ? r * p : 0.0;
    final rightBottom = roundBottomRight ? r * p : 0.0;

    paint.color = drawBottomBorder ? borderColor : fillColor;

    canvas.drawRect(
      Rect.fromLTWH(
        leftBottom,
        (rows - t) * p,
        cols * p - leftBottom - rightBottom,
        t * p,
      ),
      paint,
    );

    paint.color = drawLeftBorder ? borderColor : fillColor;

    final leftStart = roundTopLeft ? r * p : 0.0;
    final leftEnd = roundBottomLeft ? r * p : 0.0;

    canvas.drawRect(
      Rect.fromLTWH(0, leftStart, t * p, rows * p - leftStart - leftEnd),
      paint,
    );

    paint.color = drawRightBorder ? borderColor : fillColor;

    final rightStart = roundTopRight ? r * p : 0.0;
    final rightEnd = roundBottomRight ? r * p : 0.0;

    canvas.drawRect(
      Rect.fromLTWH(
        (cols - t) * p,
        rightStart,
        t * p,
        rows * p - rightStart - rightEnd,
      ),
      paint,
    );

    final useTopLeft = roundTopLeft && !isFlatTop && !isFlatLeft;
    final useTopRight = roundTopRight && !isFlatTop && !isFlatRight;
    final useBottomLeft = roundBottomLeft && !isFlatBottom && !isFlatLeft;
    final useBottomRight = roundBottomRight && !isFlatBottom && !isFlatRight;

    for (int py = 0; py < r; py++) {
      for (int px = 0; px < r; px++) {
        final x = px - r + 0.5;
        final y = py - r + 0.5;

        final dist2 = x * x + y * y;
        final outerR2 = r * r;
        final innerR2 = (r - t) * (r - t);

        if (x * x + y * y <= r * r) {
          final isBorder = dist2 <= outerR2 && dist2 >= innerR2;

          paint.color = isBorder ? borderColor : fillColor;

          if (useTopLeft) {
            canvas.drawRect(Rect.fromLTWH(px * p, py * p, p, p), paint);
          }

          if (useTopRight) {
            canvas.drawRect(
              Rect.fromLTWH((cols - px - 1) * p, py * p, p, p),
              paint,
            );
          }

          if (useBottomLeft) {
            canvas.drawRect(
              Rect.fromLTWH(px * p, (rows - py - 1) * p, p, p),
              paint,
            );
          }

          if (useBottomRight) {
            canvas.drawRect(
              Rect.fromLTWH((cols - px - 1) * p, (rows - py - 1) * p, p, p),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PixelPanelPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.radius != radius ||
        oldDelegate.pixelSize != pixelSize;
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

class PixelPillPainter extends CustomPainter {
  final Color? fillColor;
  final Color? borderColor;
  final double pixelSize;
  final int borderThickness;

  PixelPillPainter({
    this.fillColor,
    this.borderColor,
    this.pixelSize = 2.0,
    this.borderThickness = 1,
  });

  @override
  bool shouldRepaint(_) => false;

  bool _isInside(int px, int py, int rows, int cols, int r) {
    final isHorizontal = cols >= rows;

    if (isHorizontal) {
      final centerY = r;
      final leftCenterX = r;
      final rightCenterX = cols - r;

      final y = py - centerY + 0.5;

      if (px < r) {
        final x = px - leftCenterX + 0.5;
        return (x * x + y * y) <= r * r;
      } else if (px >= cols - r) {
        final x = px - rightCenterX + 0.5;
        return (x * x + y * y) <= r * r;
      } else {
        return true;
      }
    } else {
      final centerX = r;
      final topCenterY = r;
      final bottomCenterY = rows - r;

      final x = px - centerX + 0.5;

      if (py < r) {
        final y = py - topCenterY + 0.5;
        return (x * x + y * y) <= r * r;
      } else if (py >= rows - r) {
        final y = py - bottomCenterY + 0.5;
        return (x * x + y * y) <= r * r;
      } else {
        return true;
      }
    }
  }

  bool _isEdge(int px, int py, List<List<bool>> grid, int rows, int cols) {
    final t = borderThickness.toDouble();

    for (int dy = -borderThickness; dy <= borderThickness; dy++) {
      for (int dx = -borderThickness; dx <= borderThickness; dx++) {
        if ((dx * dx + dy * dy) > (t * t)) continue;

        final nx = px + dx;
        final ny = py + dy;

        if (nx < 0 || nx >= cols || ny < 0 || ny >= rows) {
          return true;
        }

        if (!grid[ny][nx]) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = pixelSize;

    final rows = (size.height / p).floor();
    final cols = (size.width / p).floor();
    final r = (math.min(rows, cols) / 2).floor();

    final fillPaint = fillColor != null
        ? (Paint()
            ..color = fillColor!
            ..isAntiAlias = false)
        : null;

    final borderPaint = borderColor != null
        ? (Paint()
            ..color = borderColor!
            ..isAntiAlias = false)
        : null;

    final grid = List.generate(
      rows,
      (py) => List.generate(cols, (px) => _isInside(px, py, rows, cols, r)),
    );

    for (int py = 0; py < rows; py++) {
      for (int px = 0; px < cols; px++) {
        if (!grid[py][px]) continue;

        final isEdge = _isEdge(px, py, grid, rows, cols);

        final rect = Rect.fromLTWH(px * p, py * p, p, p);

        if (fillPaint != null && (!isEdge || borderPaint == null)) {
          canvas.drawRect(rect, fillPaint);
        }

        if (borderPaint != null && isEdge) {
          canvas.drawRect(rect, borderPaint);
        }
      }
    }
  }
}
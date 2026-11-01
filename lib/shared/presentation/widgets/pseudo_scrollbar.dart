import 'package:flutter/material.dart';

class PseudoScrollbar extends StatelessWidget {
  final ScrollController controller;

  final Axis direction;

  final double trackExtent;
  final double thickness;

  final Color trackColor;
  final Color thumbColor;

  const PseudoScrollbar({
    super.key,
    required this.controller,
    required this.direction,
    required this.trackExtent,
    this.thickness = 4.0,
    this.trackColor = const Color(0xFF36343D),
    this.thumbColor = const Color(0xFFC0ABC5),
  });

  @override
  Widget build(_) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (!controller.hasClients ||
            !controller.position.hasContentDimensions) {
          return SizedBox();
        }

        final position = controller.position;

        final viewportExtent = position.viewportDimension;
        final contentExtent = position.maxScrollExtent + viewportExtent;

        if (viewportExtent <= 0 || contentExtent <= 0) {
          return SizedBox();
        }

        final thumbExtent = (trackExtent * viewportExtent / contentExtent)
            .clamp(thickness * 2, trackExtent);

        final maxThumbOffset = trackExtent - thumbExtent;

        final thumbOffset = position.maxScrollExtent == 0
            ? 0.0
            : maxThumbOffset * (position.pixels / position.maxScrollExtent);

        return CustomPaint(
          painter: _ScrollbarPainter(
            direction: direction,
            thumbExtent: thumbExtent,
            thumbOffset: thumbOffset,
            trackColor: trackColor,
            thumbColor: thumbColor,
          ),
        );
      },
    );
  }
}

class _ScrollbarPainter extends CustomPainter {
  final Axis direction;

  final double thumbExtent;
  final double thumbOffset;

  final Color trackColor;
  final Color thumbColor;

  _ScrollbarPainter({
    required this.direction,
    required this.thumbExtent,
    required this.thumbOffset,
    required this.trackColor,
    required this.thumbColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = trackColor
      ..style = .fill;

    final thumbPaint = Paint()
      ..color = thumbColor
      ..style = .fill;

    canvas.drawRect(Offset.zero & size, trackPaint);

    final thumbRect = direction == .horizontal
        ? Rect.fromLTWH(thumbOffset, 0, thumbExtent, size.height)
        : Rect.fromLTWH(0, thumbOffset, size.width, thumbExtent);

    canvas.drawRect(thumbRect, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _ScrollbarPainter oldDelegate) {
    return direction != oldDelegate.direction ||
        thumbExtent != oldDelegate.thumbExtent ||
        thumbOffset != oldDelegate.thumbOffset ||
        trackColor != oldDelegate.trackColor ||
        thumbColor != oldDelegate.thumbColor;
  }
}

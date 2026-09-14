import 'package:flutter/material.dart';
import 'package:arcade/shared/presentation/widgets/custom_painters/pixel_panel_painter.dart';

class PixelCard extends StatelessWidget {
  final Widget child;

  final Color borderColor;
  final Color fillColor;

  final EdgeInsets padding;

  final Offset offset;

  final int radius;

  const PixelCard({
    super.key,
    required this.child,
    required this.borderColor,
    required this.fillColor,
    this.padding = const .all(8.0),
    this.offset = const Offset(0.0, 4.0),
    this.radius = 4,
  });

  @override
  Widget build(_) {
    final cardPanel = PixelPanelPainter(
      borderColor: borderColor,
      fillColor: fillColor,
      radius: radius,
    );

    final shadowPanel = cardPanel.copyWith(baseColor: borderColor);

    return Stack(
      children: [
        Positioned.fill(
          child: Transform.translate(
            offset: offset,
            child: Opacity(
              opacity: 0.5,
              child: RepaintBoundary(child: CustomPaint(painter: shadowPanel)),
            ),
          ),
        ),
        Positioned.fill(
          child: RepaintBoundary(child: CustomPaint(painter: cardPanel)),
        ),
        Padding(padding: padding, child: child),
      ],
    );
  }
}

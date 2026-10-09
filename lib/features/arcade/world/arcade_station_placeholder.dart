import 'package:flutter/material.dart';

class ArcadeStationPlaceholder extends StatelessWidget {
  final Offset groundPosition;
  final double tileWidth;
  final double visualHeight;
  final String label;
  final bool canInteract;

  const ArcadeStationPlaceholder({
    super.key,
    required this.groundPosition,
    required this.tileWidth,
    this.visualHeight = 50,
    this.label = 'PLAY',
    required this.canInteract,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: groundPosition.dx - tileWidth / 2,
      top: groundPosition.dy - visualHeight,
      width: tileWidth,
      height: visualHeight,
      child: Stack(
        children: [
          CustomPaint(
            painter: _ArcadeStationPlaceholderPainter(),
            child: Align(
              alignment: const Alignment(0, -0.15),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
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
                  child: const Padding(
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

class _ArcadeStationPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cabinetPaint = Paint()..color = const Color(0xFF34304F);

    final screenPaint = Paint()..color = const Color(0xFF7CE7D3);

    final panelPaint = Paint()..color = const Color(0xFFE4B95C);

    final outlinePaint = Paint()
      ..color = const Color(0xFF171522)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cabinet = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 0, size.width - 4, size.height),
      const Radius.circular(3),
    );

    canvas
      ..drawRRect(cabinet, cabinetPaint)
      ..drawRRect(cabinet, outlinePaint)
      ..drawRect(
        Rect.fromLTWH(6, 5, size.width - 12, size.height * 0.38),
        screenPaint,
      )
      ..drawRect(
        Rect.fromLTWH(6, size.height * 0.51, size.width - 12, 5),
        panelPaint,
      );
  }

  @override
  bool shouldRepaint(covariant _ArcadeStationPlaceholderPainter oldDelegate) =>
      false;
}

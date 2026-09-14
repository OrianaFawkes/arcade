import 'package:arcade/shared/presentation/widgets/custom_painters/pixel_panel_painter.dart';
import 'package:arcade/shared/presentation/widgets/pixel_shadow.dart';
import 'package:flutter/material.dart';

class DialogContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget child;

  const DialogContainer({
    super.key,
    this.width,
    this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = viewInsets > 0.0 ? viewInsets : 0.0;

    final dialogPanel = PixelPanelPainter(
      borderColor: Color(0xFF614E4E),
      fillColor: Color(0xFFECCEC3),
      radius: 4,
    );

    final shadowPanel = dialogPanel.copyWith(baseColor: Color(0xFF614E4E));

    return Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedPadding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          curve: Curves.easeOut,
          duration: Duration(milliseconds: 240),
          child: PixelShadow(
            shadowPainter: shadowPanel,
            offset: Offset(0.0, 8.0),
            child: SizedBox(
              width: width,
              height: height,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: dialogPanel,
                  child: SizedBox(
                    child: Padding(padding: .all(24.0), child: child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

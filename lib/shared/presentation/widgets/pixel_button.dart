import 'package:arcade/shared/presentation/widgets/custom_painters/pixel_pill_painter.dart';
import 'package:arcade/shared/presentation/widgets/pixel_shadow.dart';
import 'package:flutter/material.dart';

class PixelButton extends StatefulWidget {
  final Widget child;

  final Color fillColor;
  final Color? borderColor;
  final Color hoveredColor;
  final Color pressedColor;
  final Color shadowColor;

  final double? width;
  final double height;

  final VoidCallback? onPressed;

  const PixelButton({
    super.key,
    required this.child,
    this.fillColor = const Color(0xFFF2D3F2),
    this.borderColor,
    this.hoveredColor = const Color(0xFFF2D9F5),
    this.pressedColor = const Color(0xFFC0ABC5),
    this.shadowColor = const Color(0xFFF2D3F2),
    this.width,
    this.height = 32.0,
    required this.onPressed,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool hovered = false;
  bool pressed = false;

  Color _resolveBaseColor() {
    if (widget.borderColor != null) {
      return widget.borderColor!;
    }
    return widget.fillColor;
  }

  Color _resolveEffectiveColor(Color base) {
    if (pressed) return widget.pressedColor;
    if (hovered) return widget.hoveredColor;
    return base;
  }

  @override
  Widget build(_) {
    final horizontalPadding = 16.0;
    final verticalPadding = 0.0;

    final baseColor = _resolveBaseColor();
    final effectiveColor = _resolveEffectiveColor(baseColor);

    final fillColor = widget.borderColor != null
        ? widget.fillColor
        : effectiveColor;

    final borderColor = widget.borderColor != null ? effectiveColor : null;

    final pressOffset = pressed ? 4.0 : 0.0;

    return PixelShadow(
      shadowPainter: PixelPillPainter(fillColor: widget.shadowColor),
      child: Transform.translate(
        offset: Offset(0, pressOffset),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: PixelPillPainter(
                fillColor: fillColor,
                borderColor: borderColor,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  onHover: (value) => setState(() => hovered = value),
                  onHighlightChanged: (value) =>
                      setState(() => pressed = value),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: Padding(
                    padding: .symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Center(child: widget.child),
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

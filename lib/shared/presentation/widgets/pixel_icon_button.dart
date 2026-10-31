import 'package:flutter/material.dart';

class PixelIconButton extends StatefulWidget {
  final Widget icon;

  final String message;

  final double? width;
  final double? height;

  final VoidCallback? onPressed;

  const PixelIconButton({
    super.key,
    required this.icon,
    required this.message,
    this.width = 32.0,
    this.height = 32.0,
    required this.onPressed,
  });

  @override
  State<PixelIconButton> createState() => _PixelIconButtonState();
}

class _PixelIconButtonState extends State<PixelIconButton> {
  bool pressed = false;

  @override
  Widget build(_) {
    final pressOffset = pressed ? 4.0 : 0.0;

    return Tooltip(
      message: widget.message,
      child: Transform.translate(
        offset: Offset(0, pressOffset),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: (value) => setState(() => pressed = value),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}

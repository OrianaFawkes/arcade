import 'package:arcade/shared/presentation/widgets/pixel_icon_button.dart';
import 'package:flutter/material.dart';

class PotActions extends StatelessWidget {
  final void Function()? onShowSettings;
  final void Function()? onUndo;
  final void Function()? onRestart;

  const PotActions({
    super.key,
    required this.onShowSettings,
    required this.onUndo,
    required this.onRestart,
  });

  @override
  Widget build(_) {
    return SizedBox(
      width: 320.0,
      child: Row(
        mainAxisSize: .min,
        spacing: 8.0,
        children: [
          PixelIconButton(
            message: 'Settings (Q)',
            onPressed: onShowSettings,
            icon: Icon(Icons.settings_rounded, color: Color(0xFFF2D3F2)),
          ),
          Spacer(),
          PixelIconButton(
            message: 'Undo (Z)',
            onPressed: onUndo,
            icon: Icon(
              Icons.undo_rounded,
              color: onUndo == null ? Color(0xFFC0ABC5) : Color(0xFFF2D3F2),
            ),
          ),
          PixelIconButton(
            message: 'Restart (R)',
            onPressed: onRestart,
            icon: Icon(Icons.refresh_rounded, color: Color(0xFFF2D3F2)),
          ),
        ],
      ),
    );
  }
}

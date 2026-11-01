import 'package:arcade/shared/presentation/widgets/pixel_icon_button.dart';
import 'package:flutter/material.dart';

class PrxActions extends StatelessWidget {
  final int flagsRemaining;

  final void Function()? onChangeDifficulty;
  final void Function()? onRestart;

  const PrxActions({
    super.key,
    required this.flagsRemaining,
    required this.onChangeDifficulty,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 320.0,
      child: Row(
        mainAxisSize: .min,
        spacing: 8.0,
        children: [
          Tooltip(
            message: 'Flags remaining',
            child: Row(
              mainAxisSize: .min,
              spacing: 4.0,
              children: [
                Icon(Icons.flag_rounded, size: 16, color: Color(0xFFF2D3F2)),
                Text(
                  '$flagsRemaining',
                  style: textTheme.bodyLarge,
                  overflow: .ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Spacer(),
          PixelIconButton(
            message: 'Change difficulty (D)',
            onPressed: onChangeDifficulty,
            icon: Icon(Icons.tune_rounded, color: Color(0xFFF2D3F2)),
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

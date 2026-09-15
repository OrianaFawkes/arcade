import 'package:arcade/features/2048/game/game_controller.dart';
import 'package:arcade/features/2048/presentation/tile_color_scheme.dart';
import 'package:arcade/shared/presentation/widgets/dialog_container.dart';
import 'package:arcade/shared/presentation/widgets/pixel_card.dart';
import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final GameController game;

  const SettingsDialog({super.key, required this.game});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    return DialogContainer(
      width: 280.0,
      child: Column(
        mainAxisSize: .min,
        spacing: 16.0,
        children: [
          Text('Tile Color', style: Theme.of(context).textTheme.titleLarge),
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              for (final preset in TileColorScheme.presets)
                GestureDetector(
                  onTap: () async {
                    await widget.game.setTileBaseColor(preset.baseColor);

                    if (!context.mounted) return;

                    Navigator.pop(context);
                  },
                  child: Tooltip(
                    message: preset.name,
                    child: SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: PixelCard(
                        borderColor:
                            widget.game.tileBaseColor == preset.baseColor
                            ? Color(0xFF2D1B1B)
                            : preset.baseColor,
                        fillColor: preset.baseColor,
                        radius: 6,
                        child: SizedBox(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Text('Board Jiggle', style: Theme.of(context).textTheme.titleLarge),
          // TODO: Pixel-ify
          Switch(
            value: widget.game.hasBoardJiggle,
            activeThumbColor: widget.game.tileBaseColor,
            onChanged: (bool value) async {
              await widget.game.setHasBoardJiggle(value);

              if (!context.mounted) return;

              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

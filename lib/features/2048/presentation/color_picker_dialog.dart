import 'package:arcade/features/2048/game/game_controller.dart';
import 'package:arcade/features/2048/presentation/tile_color_scheme.dart';
import 'package:arcade/shared/presentation/widgets/dialog_container.dart';
import 'package:arcade/shared/presentation/widgets/pixel_card.dart';
import 'package:flutter/material.dart';

class ColorPickerDialog extends StatelessWidget {
  final GameController game;

  const ColorPickerDialog({super.key, required this.game});

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
                    await game.setTileBaseColor(preset.baseColor);

                    if (!context.mounted) return;

                    Navigator.pop(context);
                  },
                  child: Tooltip(
                    message: preset.name,
                    child: SizedBox(
                      width: 32.0,
                      height: 32.0,
                      child: PixelCard(
                        borderColor: game.tileBaseColor == preset.baseColor
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
        ],
      ),
    );
  }
}

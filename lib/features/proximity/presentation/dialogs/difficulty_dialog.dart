import 'package:arcade/features/proximity/game/game_controller.dart';
import 'package:arcade/features/proximity/models/difficulty.dart';
import 'package:arcade/shared/presentation/widgets/dialog_container.dart';
import 'package:flutter/material.dart';
import 'package:smart_padding/smart_padding.dart';

class DifficultyDialog extends StatefulWidget {
  final GameController game;

  const DifficultyDialog({super.key, required this.game});

  @override
  State<DifficultyDialog> createState() => _DifficultyDialogState();
}

class _DifficultyDialogState extends State<DifficultyDialog> {
  String _difficultyLabel(Difficulty difficulty) {
    return switch (difficulty) {
      .beginner => 'Beginner',
      .intermediate => 'Intermediate',
      .expert => 'Expert',
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DialogContainer(
      width: 280.0,
      child: Column(
        mainAxisSize: .min,
        spacing: 16.0,
        children: [
          Text('Difficulty', style: textTheme.titleLarge),
          Column(
            mainAxisSize: .min,
            children: [
              for (final difficulty in Difficulty.values)
                _DifficultyOption(
                  label: _difficultyLabel(difficulty),
                  isSelected: difficulty == widget.game.difficulty,
                  onTap: () async {
                    if (difficulty != widget.game.difficulty) {
                      await widget.game.startGame(difficulty);
                    }

                    if (!context.mounted) return;

                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  final String label;

  final bool isSelected;

  final VoidCallback onTap;

  const _DifficultyOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected ? Color(0xFFF2D3F2) : Colors.transparent,
      clipBehavior: .antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SmartPadding(
          all: 8.0,
          child: Row(
            spacing: 8.0,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isSelected ? Color(0xFF36343D) : null,
                  ),
                  textAlign: .start,
                  overflow: .ellipsis,
                  maxLines: 1,
                ),
              ),
              if (isSelected) ...[
                Icon(Icons.check_rounded, size: 24.0, color: Color(0xFF36343D)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

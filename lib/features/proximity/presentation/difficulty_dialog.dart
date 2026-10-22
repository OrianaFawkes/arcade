import 'package:arcade/features/proximity/game/game_controller.dart';
import 'package:arcade/features/proximity/models/difficulty.dart';
import 'package:arcade/shared/presentation/widgets/dialog_container.dart';
import 'package:flutter/material.dart';

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
    return DialogContainer(
      width: 280.0,
      child: Column(
        mainAxisSize: .min,
        spacing: 16.0,
        children: [
          Text('Difficulty', style: Theme.of(context).textTheme.titleLarge),
          for (final difficulty in Difficulty.values)
            SimpleDialogOption(
              onPressed: () async {
                if (difficulty != widget.game.difficulty) {
                  await widget.game.startGame(difficulty);
                }

                if (!context.mounted) return;

                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Expanded(child: Text(_difficultyLabel(difficulty))),
                  if (difficulty == widget.game.difficulty) ...[
                    Icon(Icons.check_rounded),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

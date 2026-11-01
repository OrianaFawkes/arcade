import 'dart:async';

import 'package:arcade/features/proximity/presentation/widgets/prx_actions.dart';
import 'package:arcade/features/proximity/presentation/widgets/prx_board.dart';
import 'package:arcade/features/proximity/game/game_storage.dart';
import 'package:arcade/features/proximity/game/game_controller.dart';
import 'package:arcade/features/proximity/models/difficulty.dart';
import 'package:arcade/features/proximity/presentation/dialogs/difficulty_dialog.dart';
import 'package:arcade/features/proximity/presentation/widgets/prx_shortcuts.dart';
import 'package:arcade/features/proximity/presentation/widgets/prx_timeboard.dart';
import 'package:arcade/shared/presentation/dialogs/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_padding/smart_padding.dart';

class ProximityScreen extends StatefulWidget {
  const ProximityScreen({super.key});

  @override
  State<ProximityScreen> createState() => _ProximityScreenState();
}

class _ProximityScreenState extends State<ProximityScreen> {
  GameController? game;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final preferences = await SharedPreferences.getInstance();

      final storage = GameStorage(preferences);

      final localGame = GameController(storage);

      await localGame.initialize();

      if (!mounted) return;

      setState(() {
        game = localGame;
      });

      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (!mounted || game == null) return;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  Future<void> _reveal(int row, int column) async {
    final localGame = game;
    if (localGame == null) return;

    await localGame.reveal(row, column);

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _toggleFlag(int row, int column) async {
    final localGame = game;
    if (localGame == null) return;

    await localGame.toggleFlag(row, column);

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _restart() async {
    final localGame = game;
    if (localGame == null) return;

    await localGame.startGame(localGame.difficulty);

    if (!mounted) return;

    setState(() {});
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  String _statusText() {
    final localGame = game;

    if (localGame == null) return '';

    return switch (localGame.status) {
      .ready => 'Ready',
      .playing => 'Playing',
      .won => 'You Win!',
      .lost => 'Game Over',
    };
  }

  String _difficultyLabel(Difficulty difficulty) {
    return switch (difficulty) {
      .beginner => 'Beginner',
      .intermediate => 'Intermediate',
      .expert => 'Expert',
    };
  }

  Future<void> _selectDifficulty() async {
    if (game == null) return;

    await showAppDialog(
      context: context,
      barrierLabel: 'Difficulty',
      widget: DifficultyDialog(game: game!),
    );

    if (!mounted) return;

    setState(() {});
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return .ignored;

    if (HardwareKeyboard.instance.isControlPressed) return .ignored;
    if (HardwareKeyboard.instance.isMetaPressed) return .ignored;

    if (event.logicalKey == .keyD) {
      _selectDifficulty();

      return .handled;
    }

    if (event.logicalKey == .keyR) {
      _restart();

      return .handled;
    }

    return .ignored;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) => _handleKey(event),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: Text(
            'Proximity',
            style: textTheme.bodyLarge,
            overflow: .ellipsis,
            maxLines: 1,
          ),
          titleSpacing: 0.0,
        ),
        body: SafeArea(
          child: Center(
            child: SmartPadding(
              horizontal: 24.0,
              bottom: 16.0,
              child: Column(
                mainAxisAlignment: .center,
                spacing: 16.0,
                children: [
                  if (game == null) ...[
                    CircularProgressIndicator(),
                  ] else ...[
                    PrxActions(
                      flagsRemaining:
                          game!.difficulty.mineCount - game!.flagsUsed,
                      onChangeDifficulty: _selectDifficulty,
                      onRestart: _restart,
                    ),
                    PrxTimeboard(
                      gameStatus: _statusText(),
                      difficulty: _difficultyLabel(game!.difficulty),
                      elapsedTime: _formatDuration(game!.elapsed),
                      bestTime: game!.bestTime == null
                          ? '--:--'
                          : _formatDuration(game!.bestTime!),
                    ),
                    Flexible(
                      child: PrxBoard(
                        board: game!.board,
                        difficulty: game!.difficulty,
                        onReveal: _reveal,
                        onToggleFlag: _toggleFlag,
                      ),
                    ),
                    PrxShortcuts(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

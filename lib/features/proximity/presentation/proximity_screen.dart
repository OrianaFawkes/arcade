import 'dart:async';

import 'package:arcade/features/proximity/presentation/board.dart';
import 'package:arcade/features/proximity/game/game_storage.dart';
import 'package:arcade/features/proximity/game/game_controller.dart';
import 'package:arcade/features/proximity/models/difficulty.dart';
import 'package:arcade/features/proximity/presentation/difficulty_dialog.dart';
import 'package:arcade/shared/presentation/dialogs/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final localGame = game;

    if (localGame == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text('Proximity'),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4.0,
                children: [
                  Icon(Icons.flag_rounded, size: 16, color: Color(0xFFF2D3F2)),
                  Text(
                    '${localGame.difficulty.mineCount - localGame.flagsUsed}',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: Text(_formatDuration(localGame.elapsed))),
          ),
          IconButton(
            onPressed: _selectDifficulty,
            icon: Icon(Icons.tune_rounded, color: Color(0xFFF2D3F2)),
            tooltip: 'Change difficulty',
          ),
          IconButton(
            onPressed: _restart,
            icon: Icon(Icons.refresh_rounded, color: Color(0xFFF2D3F2)),
            tooltip: 'Restart',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16.0,
          children: [
            Text(_statusText(), style: textTheme.titleMedium),
            Text(
              _difficultyLabel(localGame.difficulty),
              style: textTheme.bodySmall,
            ),
            Board(
              board: localGame.board,
              difficulty: localGame.difficulty,
              onReveal: _reveal,
              onToggleFlag: _toggleFlag,
            ),
            Text(
              'Best: ${localGame.bestTime == null ? '--:--' : _formatDuration(localGame.bestTime!)}',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

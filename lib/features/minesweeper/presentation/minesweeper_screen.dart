import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/game_controller.dart';
import '../game/game_storage.dart';
import '../models/difficulty.dart';
import '../models/game_state.dart';
import 'board.dart';

class MinesweeperScreen extends StatefulWidget {
  const MinesweeperScreen({super.key});

  @override
  State<MinesweeperScreen> createState() => _MinesweeperScreenState();
}

class _MinesweeperScreenState extends State<MinesweeperScreen> {
  static const Difficulty difficulty = Difficulty.beginner;

  MinesweeperGameController? game;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final preferences = await SharedPreferences.getInstance();

      final storage = MinesweeperGameStorage(preferences);

      final localGame = MinesweeperGameController(storage);

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

    final before = localGame.cellAt(row, column);

    debugPrint(
      'BEFORE [$row,$column] '
      'status=${localGame.status} '
      'revealed=${before?.isRevealed} '
      'flagged=${before?.isFlagged} '
      'mine=${before?.hasMine}',
    );

    await localGame.reveal(row, column);

    final after = localGame.cellAt(row, column);

    debugPrint(
      'AFTER [$row,$column] '
      'status=${localGame.status} '
      'revealed=${after?.isRevealed} '
      'flagged=${after?.isFlagged} '
      'mine=${after?.hasMine}',
    );

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

    await localGame.startGame(difficulty);

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
      MinesweeperGameStatus.ready => 'Ready',
      MinesweeperGameStatus.playing => 'Playing',
      MinesweeperGameStatus.won => 'You Win!',
      MinesweeperGameStatus.lost => 'Game Over',
    };
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Minesweeper'),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4.0,
                children: [
                  Icon(Icons.flag_rounded, size: 16),
                  Text('${difficulty.mineCount - localGame.flagsUsed}'),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: Text(_formatDuration(localGame.elapsed))),
          ),
          IconButton(
            onPressed: _restart,
            icon: Icon(Icons.refresh_rounded),
            tooltip: 'Restart',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16.0,
          children: [
            Text(_statusText(), style: Theme.of(context).textTheme.titleMedium),
            Board(
              board: localGame.board,
              difficulty: difficulty,
              onReveal: _reveal,
              onToggleFlag: _toggleFlag,
            ),
            Text(
              'Best: ${localGame.bestTime == null ? '--:--' : _formatDuration(localGame.bestTime!)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

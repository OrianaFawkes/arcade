import 'package:arcade/features/2048/game/game_storage.dart';
import 'package:arcade/features/2048/presentation/color_picker_dialog.dart';
import 'package:arcade/features/2048/presentation/tile_color_scheme.dart';
import 'package:arcade/shared/presentation/dialogs/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcade/features/2048/game/game_controller.dart';
import 'package:arcade/features/2048/models/move_direction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'board.dart';

class A2048Screen extends StatefulWidget {
  const A2048Screen({super.key});

  @override
  State<A2048Screen> createState() => _A2048ScreenState();
}

class _A2048ScreenState extends State<A2048Screen> {
  final FocusNode _focusNode = FocusNode();

  GameController? game;

  MoveDirection? _lastMove;

  bool _showWinOverlay = false;
  bool _isProcessingMove = false;

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

        _showWinOverlay = localGame.hasWon && !localGame.hasShownWin;
      });

      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  Future<void> _move(MoveDirection direction) async {
    if (game == null) return;

    if (_isProcessingMove || _showWinOverlay) return;

    _isProcessingMove = true;

    try {
      final didMove = await game!.move(direction);

      if (!mounted) return;

      setState(() {
        _lastMove = direction;

        if (didMove && game!.justWon) _showWinOverlay = true;
      });
    } finally {
      _isProcessingMove = false;
    }
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return .ignored;

    if (HardwareKeyboard.instance.isControlPressed) return .ignored;
    if (HardwareKeyboard.instance.isMetaPressed) return .ignored;

    if (event.logicalKey == .keyR) {
      _restart();

      return .handled;
    }

    if (event.logicalKey == .keyZ) {
      _undo();

      return .handled;
    }

    final direction = switch (event.logicalKey) {
      .keyA || .arrowLeft => MoveDirection.left,
      .keyD || .arrowRight => MoveDirection.right,
      .keyW || .arrowUp => MoveDirection.up,
      .keyS || .arrowDown => MoveDirection.down,
      _ => null,
    };

    if (direction != null) _move(direction);

    return .handled;
  }

  Future<void> _restart() async {
    if (game == null) return;

    await game!.startGame();

    if (!mounted) return;

    setState(() {
      _showWinOverlay = false;

      _lastMove = null;
    });

    _focusNode.requestFocus();
  }

  Future<void> _undo() async {
    if (game == null) return;

    if (!game!.canUndo || _showWinOverlay) return;

    final didUndo = await game!.undo();

    if (!mounted || !didUndo) return;

    setState(() => _lastMove = null);

    _focusNode.requestFocus();
  }

  Future<void> _continueGame() async {
    if (game == null) return;

    await game!.acknowledgeWin();

    if (!mounted) return;

    setState(() => _showWinOverlay = false);

    _focusNode.requestFocus();
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;

    const minimumVelocity = 320.0;

    if (velocity.distance.abs() < minimumVelocity) return;

    if (velocity.dx.abs() > velocity.dy.abs()) {
      if (velocity.dx > 0) {
        _move(MoveDirection.right);
      } else {
        _move(MoveDirection.left);
      }
    } else {
      if (velocity.dy > 0) {
        _move(MoveDirection.down);
      } else {
        _move(MoveDirection.up);
      }
    }
  }

  Future<void> _showColorPicker() async {
    if (game == null) return;

    await showAppDialog(
      context: context,
      barrierLabel: 'DiscardPile',
      widget: ColorPickerDialog(game: game!),
    );

    if (!mounted) return;

    setState(() {});

    return;
  }

  @override
  Widget build(_) {
    if (game == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (_, event) => _handleKey(event),
      child: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        onVerticalDragEnd: _handleSwipe,
        child: Scaffold(
          appBar: AppBar(
            title: Text('2048'),
            actions: [
              Padding(
                padding: .symmetric(horizontal: 8.0),
                child: Center(child: Text('Score: ${game!.score}')),
              ),
              Padding(
                padding: .symmetric(horizontal: 8.0),
                child: Center(child: Text('Best: ${game!.highScore}')),
              ),
              IconButton(
                onPressed: _showColorPicker,
                icon: Icon(Icons.palette),
                tooltip: 'Tile color',
              ),
              IconButton(
                onPressed: game!.canUndo ? _undo : null,
                icon: Icon(Icons.undo),
                tooltip: 'Undo (Z)',
              ),
              IconButton(
                onPressed: _restart,
                icon: Icon(Icons.refresh),
                tooltip: 'Restart (R)',
              ),
            ],
          ),
          body: Center(
            child: Board(
              tiles: game!.tiles,
              lastMove: _lastMove,
              colorScheme: TileColorScheme.presets.firstWhere(
                (e) => e.baseColor == game!.tileBaseColor,
              ),
              showWinOverlay: _showWinOverlay,
              isGameOver: game!.isGameOver,
              score: game!.score,
              onRestart: _restart,
              onContinue: _continueGame,
            ),
          ),
        ),
      ),
    );
  }
}

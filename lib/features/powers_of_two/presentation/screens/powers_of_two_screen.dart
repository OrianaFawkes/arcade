import 'package:arcade/features/powers_of_two/presentation/widgets/pot_board.dart';
import 'package:arcade/features/powers_of_two/game/game_storage.dart';
import 'package:arcade/features/powers_of_two/presentation/dialogs/settings_dialog.dart';
import 'package:arcade/features/powers_of_two/presentation/tile_color_scheme.dart';
import 'package:arcade/features/powers_of_two/presentation/widgets/pot_actions.dart';
import 'package:arcade/features/powers_of_two/presentation/widgets/pot_shortcuts.dart';
import 'package:arcade/features/powers_of_two/presentation/widgets/pot_scoreboard.dart';
import 'package:arcade/shared/presentation/dialogs/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcade/features/powers_of_two/game/game_controller.dart';
import 'package:arcade/features/powers_of_two/models/move_direction.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_padding/smart_padding.dart';

class PowersOfTwoScreen extends StatefulWidget {
  const PowersOfTwoScreen({super.key});

  @override
  State<PowersOfTwoScreen> createState() => _PowersOfTwoScreenState();
}

class _PowersOfTwoScreenState extends State<PowersOfTwoScreen> {
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
    });
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

    if (event.logicalKey == .keyQ) {
      _showSettings();

      return .handled;
    }

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
  }

  Future<void> _undo() async {
    if (game == null) return;

    if (!game!.canUndo || _showWinOverlay) return;

    final didUndo = await game!.undo();

    if (!mounted || !didUndo) return;

    setState(() => _lastMove = null);
  }

  Future<void> _continueGame() async {
    if (game == null) return;

    await game!.acknowledgeWin();

    if (!mounted) return;

    setState(() => _showWinOverlay = false);
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;

    const minimumVelocity = 320.0;

    if (velocity.distance.abs() < minimumVelocity) return;

    if (velocity.dx.abs() > velocity.dy.abs()) {
      if (velocity.dx > 0) {
        _move(.right);

        return;
      }

      _move(.left);
    } else {
      if (velocity.dy > 0) {
        _move(.down);

        return;
      }

      _move(.up);
    }
  }

  Future<void> _showSettings() async {
    if (game == null) return;

    await showAppDialog(
      context: context,
      barrierLabel: 'Settings',
      widget: SettingsDialog(game: game!),
    );

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) => _handleKey(event),
      child: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        onVerticalDragEnd: _handleSwipe,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
            title: Text(
              'Powers of Two',
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
                child: Column(
                  mainAxisAlignment: .center,
                  spacing: 16.0,
                  children: [
                    if (game == null) ...[
                      CircularProgressIndicator(),
                    ] else ...[
                      PotActions(
                        onShowSettings: _showSettings,
                        onUndo: game!.canUndo ? _undo : null,
                        onRestart: _restart,
                      ),
                      PotScoreboard(score: game!.score, best: game!.highScore),
                      PotBoard(
                        tiles: game!.tiles,
                        lastMove: _lastMove,
                        colorScheme: TileColorScheme.presets.firstWhere(
                          (e) => e.baseColor == game!.tileBaseColor,
                        ),
                        showWinOverlay: _showWinOverlay,
                        isGameOver: game!.isGameOver,
                        hasBoardJiggle: game!.hasBoardJiggle,
                        score: game!.score,
                        onRestart: _restart,
                        onContinue: _continueGame,
                      ),
                      PotShortcuts(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

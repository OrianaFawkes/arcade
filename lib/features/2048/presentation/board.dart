import 'package:arcade/features/2048/presentation/tile_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:arcade/features/2048/game/game_controller.dart';
import 'package:arcade/features/2048/models/move_direction.dart';
import 'package:arcade/features/2048/models/tile.dart';
import 'package:arcade/shared/presentation/widgets/pixel_card.dart';

import 'tile_widget.dart';

class Board extends StatefulWidget {
  final List<Tile> tiles;

  final MoveDirection? lastMove;

  final TileColorScheme colorScheme;

  final bool showWinOverlay;
  final bool isGameOver;

  final int score;

  final VoidCallback onRestart;
  final VoidCallback onContinue;

  const Board({
    super.key,
    required this.tiles,
    this.lastMove,
    required this.colorScheme,
    required this.showWinOverlay,
    required this.isGameOver,
    required this.score,
    required this.onRestart,
    required this.onContinue,
  });

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with SingleTickerProviderStateMixin {
  static double boardSize = 320;
  static double gap = 8;

  late final AnimationController _jiggleController;

  late Animation<Offset> _jiggleAnimation;

  @override
  void initState() {
    super.initState();

    _jiggleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 140),
    );

    _jiggleAnimation = AlwaysStoppedAnimation(.zero);
  }

  @override
  void didUpdateWidget(covariant Board oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.lastMove != null) _playJiggle(widget.lastMove!);
  }

  void _playJiggle(MoveDirection direction) {
    final offset = switch (direction) {
      .left => Offset(-1, 0),
      .right => Offset(1, 0),
      .up => Offset(0, -1),
      .down => Offset(0, 1),
    };

    _jiggleAnimation =
        TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween(begin: .zero, end: offset * 0.025),
            weight: 25,
          ),
          TweenSequenceItem(
            tween: Tween(begin: offset * 0.025, end: offset * -0.015),
            weight: 35,
          ),
          TweenSequenceItem(
            tween: Tween(begin: offset * -0.015, end: .zero),
            weight: 40,
          ),
        ]).animate(
          CurvedAnimation(parent: _jiggleController, curve: Curves.easeOut),
        );

    _jiggleController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _jiggleController.dispose();

    super.dispose();
  }

  Widget _buildGameOverlay() {
    if (widget.showWinOverlay) return _buildWinOverlay();

    if (widget.isGameOver) return _buildGameOverOverlay();

    return SizedBox.shrink();
  }

  Widget _buildWinOverlay() {
    final textTheme = Theme.of(context).textTheme;

    return PixelCard(
      borderColor: Color(0xFF2D1B1B),
      fillColor: Color(0xFF614E4E).withValues(alpha: 0.1),
      padding: .zero,
      radius: 6,
      child: Center(
        child: Column(
          mainAxisSize: .min,
          spacing: 8.0,
          children: [
            Text(
              'You Win!',
              style: textTheme.titleLarge?.copyWith(color: Color(0xFFECCEC3)),
            ),
            Text(
              'Score: ${widget.score}',
              style: textTheme.bodyLarge?.copyWith(color: Color(0xFFECCEC3)),
            ),
            Row(
              mainAxisSize: .min,
              spacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: widget.onContinue,
                  child: Text('Continue'),
                ),
                ElevatedButton(
                  onPressed: widget.onRestart,
                  child: Text('Restart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final textTheme = Theme.of(context).textTheme;

    return PixelCard(
      borderColor: Color(0xFF2D1B1B),
      fillColor: Color(0xFF614E4E).withValues(alpha: 0.1),
      padding: .zero,
      radius: 6,
      child: Center(
        child: Column(
          mainAxisSize: .min,
          spacing: 8.0,
          children: [
            Text(
              'Game Over',
              style: textTheme.titleLarge?.copyWith(color: Color(0xFFECCEC3)),
            ),
            Text(
              'Score: ${widget.score}',
              style: textTheme.bodyLarge?.copyWith(color: Color(0xFFECCEC3)),
            ),
            ElevatedButton(onPressed: widget.onRestart, child: Text('Restart')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(_) {
    final cellSize = (boardSize - (gap * 5)) / GameController.size;

    return AnimatedBuilder(
      animation: _jiggleController,
      builder: (_, child) {
        final offset = _jiggleAnimation.value;

        return Transform.translate(
          offset: Offset(offset.dx * boardSize, offset.dy * boardSize),
          child: child,
        );
      },
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: Stack(
          alignment: .center,
          children: [
            PixelCard(
              borderColor: Color(0xFF2D1B1B),
              fillColor: Color(0xFF614E4E),
              padding: .zero,
              radius: 6,
              child: Stack(
                children: [
                  // Empty cells.
                  for (var row = 0; row < GameController.size; row++)
                    for (var col = 0; col < GameController.size; col++)
                      Positioned(
                        left: gap + col * (cellSize + gap),
                        top: gap + row * (cellSize + gap),
                        width: cellSize,
                        height: cellSize,
                        child: PixelCard(
                          borderColor: Color(0xFF614E4E),
                          fillColor: Color(0xFF947676),
                          offset: .zero,
                          child: SizedBox(),
                        ),
                      ),

                  // Tiles.
                  for (final tile in widget.tiles)
                    AnimatedPositioned(
                      key: ValueKey(tile.id),
                      duration: Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      left: gap + tile.col * (cellSize + gap),
                      top: gap + tile.row * (cellSize + gap),
                      width: cellSize,
                      height: cellSize,
                      child: TileWidget(
                        tile: tile,
                        colorScheme: widget.colorScheme,
                      ),
                    ),
                ],
              ),
            ),
            Positioned.fill(child: _buildGameOverlay()),
          ],
        ),
      ),
    );
  }
}

import 'package:arcade/features/powers_of_two/presentation/tile_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:arcade/features/powers_of_two/models/tile.dart';
import 'package:arcade/shared/presentation/widgets/pixel_card.dart';

class BoardTile extends StatefulWidget {
  final Tile tile;

  final TileColorScheme colorScheme;

  const BoardTile({super.key, required this.tile, required this.colorScheme});

  @override
  State<BoardTile> createState() => _BoardTileState();
}

class _BoardTileState extends State<BoardTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scaleAnimation;

  int _previousValue = 0;

  @override
  void initState() {
    super.initState();

    _previousValue = widget.tile.value;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 120),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Spawn animation.
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant BoardTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.tile.value != _previousValue) {
      _previousValue = widget.tile.value;

      // Merge/pop animation.
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final tileValue = widget.tile.value;
    final colorScheme = widget.colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: PixelCard(
        borderColor: colorScheme.borderColor(tileValue),
        fillColor: colorScheme.fillColor(tileValue),
        offset: .zero,
        child: Center(
          child: Text(
            '$tileValue',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.textColor(tileValue),
            ),
            textAlign: .center,
            overflow: .ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

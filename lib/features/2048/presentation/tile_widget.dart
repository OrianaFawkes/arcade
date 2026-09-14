import 'package:arcade/features/2048/presentation/tile_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:arcade/features/2048/models/tile.dart';
import 'package:arcade/shared/presentation/widgets/pixel_card.dart';

class TileWidget extends StatefulWidget {
  final Tile tile;

  final TileColorScheme colorScheme;

  const TileWidget({super.key, required this.tile, required this.colorScheme});

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
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
  void didUpdateWidget(covariant TileWidget oldWidget) {
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

    final fillColor = widget.colorScheme.fillColor(widget.tile.value);
    final borderColor = widget.colorScheme.borderColor(widget.tile.value);
    final textColor = widget.colorScheme.textColor(widget.tile.value);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: PixelCard(
        borderColor: borderColor,
        fillColor: fillColor,
        offset: .zero,
        child: Center(
          child: Text(
            '${widget.tile.value}',
            style: textTheme.titleLarge?.copyWith(color: textColor),
            overflow: .ellipsis,
            maxLines: 2,
          ),
        ),
      ),
    );
  }
}

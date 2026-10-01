import 'package:arcade/shared/presentation/widgets/pixel_card.dart';
import 'package:flutter/material.dart';

import '../models/cell.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;

  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onSecondaryTap;

  const CellWidget({
    super.key,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
    required this.onSecondaryTap,
  });

  Color _numberColor(int value) {
    return switch (value) {
      1 => Color(0xFF2457A6),
      2 => Color(0xFF2D7A32),
      3 => Color(0xFFC53B32),
      4 => Color(0xFF5B3B8C),
      5 => Color(0xFF8C3028),
      6 => Color(0xFF267F7F),
      7 => Color(0xFF2D2D2D),
      8 => Color(0xFF666666),
      _ => Color(0xFF2D1B1B),
    };
  }

  Widget _buildContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (!cell.isRevealed) {
      if (cell.isFlagged) {
        return Icon(Icons.flag_rounded, size: 18, color: Color(0xFF2D1B1B));
      }

      return SizedBox();
    }

    if (cell.hasMine) {
      return Icon(Icons.circle, size: 18, color: Color(0xFF2D1B1B));
    }

    if (cell.adjacentMines == 0) {
      return SizedBox();
    }

    return Text(
      '${cell.adjacentMines}',
      style: textTheme.titleMedium?.copyWith(
        color: _numberColor(cell.adjacentMines),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRevealed = cell.isRevealed;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onSecondaryTap: onSecondaryTap,
      child: PixelCard(
        borderColor: isRevealed ? Color(0xFF614E4E) : Color(0xFF2D1B1B),
        fillColor: isRevealed ? Color(0xFFD8C6B8) : Color(0xFF947676),
        offset: .zero,
        padding: .zero,
        radius: 2,
        child: Center(child: _buildContent(context)),
      ),
    );
  }
}

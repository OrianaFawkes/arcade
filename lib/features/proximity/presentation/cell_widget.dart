import 'package:arcade/features/proximity/models/cell.dart';
import 'package:arcade/shared/presentation/widgets/pixel_card.dart';
import 'package:flutter/material.dart';

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
      1 => const Color(0xFF6495ED),
      2 => const Color(0xFF4CAF50),
      3 => const Color(0xFFE57373),
      4 => const Color(0xFFB39DDB),
      5 => const Color(0xFFFF8A65),
      6 => const Color(0xFF4DB6AC),
      7 => const Color(0xFFE0E0E0),
      8 => const Color(0xFFB0BEC5),
      _ => const Color(0xFFF2D3F2),
    };
  }

  Widget _buildContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (!cell.isRevealed) {
      if (cell.isFlagged) {
        return Icon(Icons.flag_rounded, size: 18, color: Color(0xFF36343D));
      }

      return SizedBox();
    }

    if (cell.hasMine) {
      return Icon(Icons.circle, size: 18, color: Color(0xFF36343D));
    }

    if (cell.adjacentMines == 0) {
      return SizedBox();
    }

    return Text(
      '${cell.adjacentMines}',
      style: textTheme.titleMedium?.copyWith(
        color: _numberColor(cell.adjacentMines),
        fontWeight: .bold,
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
        borderColor: isRevealed ? Color(0xFF36343D) : Color(0xFF36343D),
        fillColor: isRevealed ? Color(0xFF625C6B) : Color(0xFFF2D3F2),
        offset: .zero,
        padding: .zero,
        radius: 2,
        child: Center(child: _buildContent(context)),
      ),
    );
  }
}

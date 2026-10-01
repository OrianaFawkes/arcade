import 'package:arcade/shared/presentation/widgets/pixel_card.dart';
import 'package:flutter/material.dart';

import '../models/cell.dart';
import '../models/difficulty.dart';
import 'cell_widget.dart';

class Board extends StatelessWidget {
  static const double boardSize = 320;

  final List<List<Cell>> board;
  final Difficulty difficulty;

  final void Function(int row, int column) onReveal;
  final void Function(int row, int column) onToggleFlag;

  const Board({
    super.key,
    required this.board,
    required this.difficulty,
    required this.onReveal,
    required this.onToggleFlag,
  });

  @override
  Widget build(BuildContext context) {
    final columns = difficulty.columns;

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: PixelCard(
        borderColor: Color(0xFF2D1B1B),
        fillColor: Color(0xFF614E4E),
        padding: .all(4),
        radius: 6,
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            // crossAxisSpacing: gap,
            // mainAxisSpacing: gap,
          ),
          itemCount: difficulty.rows * columns,
          itemBuilder: (context, index) {
            final row = index ~/ columns;
            final column = index % columns;

            return CellWidget(
              cell: board[row][column],
              onTap: () => onReveal(row, column),
              onLongPress: () => onToggleFlag(row, column),
              onSecondaryTap: () => onToggleFlag(row, column),
            );
          },
        ),
      ),
    );
  }
}

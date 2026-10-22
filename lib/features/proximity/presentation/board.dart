import 'package:arcade/features/proximity/models/cell.dart';
import 'package:arcade/features/proximity/models/difficulty.dart';
import 'package:arcade/features/proximity/presentation/cell_widget.dart';
import 'package:arcade/shared/presentation/widgets/pixel_card.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    final columns = difficulty.columns;

    const cellSize = 32.0;
    const boardPadding = 4.0;
    const boardBorderAllowance = 4.0;

    final boardWidth =
        columns * cellSize + boardPadding * 2 + boardBorderAllowance;
    final boardHeight =
        difficulty.rows * cellSize + boardPadding * 2 + boardBorderAllowance;

    return SingleChildScrollView(
      scrollDirection: .horizontal,
      child: SingleChildScrollView(
        scrollDirection: .vertical,
        child: SizedBox(
          width: boardWidth,
          height: boardHeight,
          child: PixelCard(
            borderColor: Color(0xFFF2D3F2),
            fillColor: Color(0xFF36343D),
            padding: .all(boardPadding),
            radius: 4,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: .zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
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
        ),
      ),
    );
  }
}

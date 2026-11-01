import 'package:arcade/features/proximity/models/cell.dart';
import 'package:arcade/features/proximity/models/difficulty.dart';
import 'package:arcade/features/proximity/presentation/widgets/prx_board_cell.dart';
import 'package:arcade/shared/presentation/widgets/pixel_card.dart';
import 'package:arcade/shared/presentation/widgets/pseudo_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:smart_padding/smart_padding.dart';

class PrxBoard extends StatefulWidget {
  final List<List<Cell>> board;

  final Difficulty difficulty;

  final void Function(int row, int column) onReveal;
  final void Function(int row, int column) onToggleFlag;

  const PrxBoard({
    super.key,
    required this.board,
    required this.difficulty,
    required this.onReveal,
    required this.onToggleFlag,
  });

  @override
  State<PrxBoard> createState() => _PrxBoardState();
}

class _PrxBoardState extends State<PrxBoard> {
  late final ScrollController _horizontalController;
  late final ScrollController _verticalController;

  @override
  void initState() {
    super.initState();

    _horizontalController = ScrollController();
    _verticalController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();

    super.dispose();
  }

  // // Color(0xFFC0ABC5),
  @override
  Widget build(BuildContext context) {
    final columns = widget.difficulty.columns;

    const cellSize = 32.0;
    const boardPadding = 4.0;

    final boardWidth = columns * cellSize + boardPadding * 2;
    final boardHeight = widget.difficulty.rows * cellSize + boardPadding * 2;

    final gridWidth = columns * cellSize;
    final gridHeight = widget.difficulty.rows * cellSize;

    return SizedBox(
      width: boardWidth,
      height: boardHeight,
      child: PixelCard(
        borderColor: Color(0xFFF2D3F2),
        fillColor: Color(0xFF36343D),
        padding: .all(boardPadding),
        radius: 4,
        child: LayoutBuilder(
          builder: (_, constraints) {
            final needsHorizontalScroll = gridWidth > constraints.maxWidth;
            final needsVerticalScroll = gridHeight > constraints.maxHeight;

            const scrollbarThickness = 2.0;

            final bottomPadding = needsVerticalScroll
                ? scrollbarThickness
                : 0.0;
            final rightPadding = needsHorizontalScroll
                ? scrollbarThickness
                : 0.0;

            return Stack(
              children: [
                SmartPadding(
                  bottom: bottomPadding,
                  right: rightPadding,
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: .horizontal,
                    child: SingleChildScrollView(
                      controller: _verticalController,
                      child: SizedBox(
                        width: gridWidth,
                        height: gridHeight,
                        child: _PrxBoardGrid(columns: columns, widget: widget),
                      ),
                    ),
                  ),
                ),
                if (needsHorizontalScroll) ...[
                  Positioned(
                    left: 0.0,
                    right: rightPadding,
                    bottom: 0.0,
                    height: scrollbarThickness,
                    child: IgnorePointer(
                      child: ClipRect(
                        child: PseudoScrollbar(
                          controller: _horizontalController,
                          direction: .horizontal,
                          trackExtent: constraints.maxWidth,
                          thickness: scrollbarThickness,
                        ),
                      ),
                    ),
                  ),
                ],
                if (needsVerticalScroll) ...[
                  Positioned(
                    top: 0.0,
                    bottom: bottomPadding,
                    right: 0.0,
                    width: scrollbarThickness,
                    child: IgnorePointer(
                      child: ClipRect(
                        child: PseudoScrollbar(
                          controller: _verticalController,
                          direction: .vertical,
                          trackExtent: constraints.maxHeight,
                          thickness: scrollbarThickness,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PrxBoardGrid extends StatelessWidget {
  final int columns;

  final PrxBoard widget;

  const _PrxBoardGrid({required this.columns, required this.widget});

  @override
  Widget build(_) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      padding: .zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
      ),
      itemCount: widget.difficulty.rows * columns,
      itemBuilder: (_, index) {
        final row = index ~/ columns;
        final column = index % columns;

        return PrxBoardCell(
          cell: widget.board[row][column],
          onTap: () => widget.onReveal(row, column),
          onLongPress: () => widget.onToggleFlag(row, column),
          onSecondaryTap: () => widget.onToggleFlag(row, column),
        );
      },
    );
  }
}

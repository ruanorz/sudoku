import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class SudokuBoard extends StatelessWidget {
  final List<List<int>> board;
  final List<List<int>> originalBoard;
  final void Function(int row, int col)? onCellTap;
  final int? selectedRow;
  final int? selectedCol;
  final Map<(int, int), Set<int>> notas;
  final Map<(int, int), GlobalKey>? cellKeys;
  final Map<(int, int), ElTooltipController>? tooltipControllers;
  final String? tooltipText;

  const SudokuBoard({
    super.key,
    required this.board,
    required this.originalBoard,
    required this.notas,
    this.onCellTap,
    this.selectedRow,
    this.selectedCol,
    this.cellKeys,
    this.tooltipControllers,
    this.tooltipText,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Column(
        children: List.generate(9, (row) {
          return Expanded(
            child: Row(
              children: List.generate(9, (col) {
                final value = board[row][col];
                final key = (row, col);
                final cellNotas = notas[key] ?? {};
                final controller = tooltipControllers?[(row, col)];

                final isSelected = selectedRow == row && selectedCol == col;
                final isSameRow = selectedRow == row;
                final isSameCol = selectedCol == col;
                final isSameBox = selectedRow != null &&
                    selectedCol != null &&
                    row ~/ 3 == selectedRow! ~/ 3 &&
                    col ~/ 3 == selectedCol! ~/ 3;

                Color bgColor = Colors.white;
                if (isSelected) {
                  bgColor = Colors.amber;
                } else if (isSameRow || isSameCol || isSameBox) {
                  bgColor = Colors.yellow[100]!;
                } else if (value != 0) {
                  bgColor = Colors.grey[200]!;
                }

                Widget content;
                if (value != 0) {
                  content = Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: originalBoard[row][col] != 0 ? Colors.black : Colors.blue,
                    ),
                  );
                } else if (cellNotas.isNotEmpty) {
                  content = GridView.count(
                    crossAxisCount: 3,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: List.generate(9, (i) {
                      final n = i + 1;
                      return Center(
                        child: Text(
                          cellNotas.contains(n) ? '$n' : '',
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }),
                  );
                } else {
                  content = const SizedBox();
                }

                return Expanded(
                      child: GestureDetector(
                        onTap: () => onCellTap?.call(row, col),
                        child: Container(
                          key: cellKeys?[(row, col)],
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: Border(
                              left: BorderSide(
                                width: col == 0 ? 2 : 0.5,
                                color: Colors.black,
                              ),
                              top: BorderSide(
                                width: row == 0 ? 2 : 0.5,
                                color: Colors.black,
                              ),
                              right: BorderSide(
                                width: (col + 1) % 3 == 0 ? 2 : 0.5,
                                color: Colors.black,
                              ),
                              bottom: BorderSide(
                                width: (row + 1) % 3 == 0 ? 2 : 0.5,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: ElTooltip(
                            controller: controller,
                            content: Text("$tooltipText"),
                            color: Colors.blue[100]!,
                            child: content,
                        ),
                      ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
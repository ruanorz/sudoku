import 'package:flutter/material.dart';
import 'package:fludoku/fludoku.dart';

class SudokuNumberPad extends StatelessWidget {
  final Board board;
  final int selectedRow;
  final int selectedCol;
  final Map<(int, int), Set<int>> notes;
  final bool isPuttingNotes;
  final void Function(int number) onNumberTap;

  const SudokuNumberPad({super.key,
    required this.board,
    required this.selectedRow,
    required this.selectedCol,
    required this.notes,
    required this.isPuttingNotes,
    required this.onNumberTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const spacing = 8.0;
    final buttonSize = (screenWidth - (spacing * 8) - 100) / 9;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(9, (index) {
          final num = index + 1;
          final posibles = board.possibleValuesAt(row: selectedRow, col: selectedCol);
          //final habilitado = posibles.contains(num);
          final habilitado = true;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: spacing / 2),
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: ElevatedButton(
                onPressed: habilitado ? () => onNumberTap(num) : null,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: habilitado ? null : Colors.grey[300],
                  foregroundColor: habilitado ? null : Colors.grey[600],
                  padding: EdgeInsets.zero,
                ),
                child: FittedBox(
                  child: Text('$num', style: const TextStyle(fontSize: 20)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fludoku/fludoku.dart';
import 'package:sudoku/widgets/sudoku_timer.dart';


class SudokuTopBarInfo extends StatelessWidget {
  final Board board;
  final int errors;

  const SudokuTopBarInfo({
    super.key,
    required this.board,
    required this.errors
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Difficulty'),
            Text('Medium ${board.dimension}x${board.dimension}'),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Errors'),
            Text('$errors/3'),
          ],
        ),
        const SudokuTimer(),
      ],
    );
  }
}
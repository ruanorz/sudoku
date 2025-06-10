import 'package:flutter/material.dart';

class SudokuComboTimer extends StatelessWidget {
  final double progress; // 0.0 a 1.0
  final int combo;

  const SudokuComboTimer({
    super.key,
    required this.progress,
    required this.combo,
  });

  @override
  Widget build(BuildContext context) {
    if (combo < 2 || progress <= 0.0) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        Text(
          'x$combo',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
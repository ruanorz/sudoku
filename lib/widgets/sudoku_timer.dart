import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sudoku_timer_provider.dart';

class SudokuTimer extends StatelessWidget {
  const SudokuTimer({super.key});

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<SudokuTimerProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Time'),
            Text(_formatTime(timer.seconds)),
          ],
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: timer.togglePause,
          icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
          tooltip: timer.isRunning ? 'Pausar' : 'Reanudar',
        ),
      ],
    );
  }
}


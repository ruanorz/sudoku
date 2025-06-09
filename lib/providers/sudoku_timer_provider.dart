import 'dart:async';
import 'package:flutter/material.dart';

import '../data/sudoku_game_state.dart';

class SudokuTimerProvider extends ChangeNotifier {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = true;

  int get seconds => _seconds;
  bool get isRunning => _isRunning;

  int _tickCounter = 0;

  void start() {
    _isRunning = true;
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_isRunning) {
        _seconds++;
        _tickCounter++;

        notifyListeners();

        if (_tickCounter >= 10) {
          _tickCounter = 0;
          // Guardar el tiempo actual en la base de datos
          final saved = await SudokuGameState.loadSudoku();
          final updated = SudokuGameState(
            currentBoard: saved.currentBoard,
            originalBoard: saved.originalBoard,
            notes: saved.notes,
            timeInSeconds: _seconds,
            isPaused: saved.isPaused,
            errors: saved.errors,
            score: saved.score,
            difficulty: saved.difficulty
          );
          await SudokuGameState.saveSudoku(updated);
        }
      }
    });
  }

  void togglePause() {
    _isRunning = !_isRunning;
    notifyListeners();
  }

  void setTimer(int seconds) {
    _seconds = seconds;
    notifyListeners();
  }

  void reset() {
    _seconds = 0;
    _isRunning = true;
    notifyListeners();
  }

  void pause() {
    _isRunning = false;
    notifyListeners();
  }

  void resume() {
    _isRunning = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

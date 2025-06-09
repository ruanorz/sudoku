import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/providers/sudoku_timer_provider.dart';

import 'app.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/sudoku_game_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SudokuGameStateAdapter());
  await Hive.openBox<SudokuGameState>('sudoku');

  runApp(
    ChangeNotifierProvider(
      create: (_) => SudokuTimerProvider()..start(),
      child: const SudokuApp(),
    ),
  );
}
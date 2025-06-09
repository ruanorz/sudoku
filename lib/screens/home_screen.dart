import 'package:fludoku/fludoku.dart';
import 'package:flutter/material.dart';
import 'package:sudoku/screens/sudoku_screen.dart';

import '../data/sudoku_game_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<List<int>>? board;
  int? time;
  String? difficulty;

  @override
  void initState() {
    super.initState();
    _loadSudoku();
  }

  void _loadSudoku() async {
    final haveSudokuInProgress = await SudokuGameState.haveSudokuInProgress();
    if (!haveSudokuInProgress) {
      setState(() {
        board = null;
        time = null;
        difficulty = null;
      });
      return;
    } else {
      final savedGame = await SudokuGameState.loadSudoku();

      setState(() {
        board = savedGame.currentBoard;
        time = savedGame.timeInSeconds;
        difficulty = savedGame.difficulty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sudoku',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              if (board != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SudokuScreen()),
                      ).then((value) {
                      _loadSudoku();
                    })
                  },
                  child: Column(children: [
                    const Text(
                      'Reanudar partida',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tiempo: ${time! ~/ 60}:${(time! % 60).toString().padLeft(2, '0')} - $difficulty',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],)
                ),

              if (board != null)
                const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _mostrarSelectorDificultad(context),
                child: const Text(
                  'Nueva partida',
                  style: TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => {
                  SudokuGameState.deleteSudoku(),
                  _loadSudoku()
                },
                child: const Text(
                  'BORRAR partida',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarSelectorDificultad(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Wrap(
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Elige dificultad', style: TextStyle(fontSize: 18)),
                ),
              ),
              ListTile(
                title: const Center(child: Text('Fácil')),
                onTap: () async {
                  await SudokuGameState.initSudoku();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SudokuScreen()),
                  ).then((value) {
                    _loadSudoku();
                  });
                },
              ),
              ListTile(
                title: const Center(child: Text('Media')),
                onTap: () async {
                  await SudokuGameState.initSudoku();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SudokuScreen()),
                  ).then((value) {
                    _loadSudoku();
                  });
                },
              ),
              ListTile(
                title: const Center(child: Text('Difícil')),
                onTap: () async {
                  await SudokuGameState.initSudoku();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SudokuScreen()),
                  ).then((value) {
                    _loadSudoku();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'dart:async';
import 'dart:math';

import 'package:animated_digit/animated_digit.dart';
import 'package:el_tooltip/el_tooltip.dart';
import 'package:fludoku/fludoku.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/widgets/sudoku_combo_timer.dart';
import '../data/models/move.dart';
import '../data/sudoku_game_state.dart';
import '../providers/sudoku_timer_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/sudoku_board.dart';
import '../widgets/sudoku_actions_bar.dart';
import '../widgets/sudoku_number_pad.dart';
import '../widgets/sudoku_score_bubble.dart';
import '../widgets/sudoku_top_bar_info.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> with TickerProviderStateMixin {
  bool isLoading = true;
  late Board board;
  late Board originalBoard;
  final List<Move> moveHistory = [];
  bool isPuttingNotes = false;
  int? selectedRow;
  int? selectedCol;
  int errors = 0;
  Map<(int, int), Set<int>> notes = {};
  int gameScore = 0;
  String? gameDifficulty;

  //combo system
  DateTime? _lastCorrectTime;
  int _combo = 1;
  double _comboTimeLeft = 0.0;
  Timer? _comboTimer;

  /*Map<(int, int), Set<int>> notes = {
    (0, 0): {1, 2, 3},
    (0, 1): {4, 5},
  };*/

  @override
  void initState() {
    super.initState();
    _loadSudoku();

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        _tooltipControllers[(row, col)] = ElTooltipController();
      }
    }
  }

  void _loadSudoku() async {
    final timerProvider = context.read<SudokuTimerProvider>();
    final savedGame = await SudokuGameState.loadSudoku();

    setState(() {
      board = Board.withValues(savedGame.currentBoard ?? []);
      originalBoard = Board.withValues(savedGame.originalBoard ?? []);
      notes = SudokuGameState.decodeNotes(savedGame.notes ?? {});
      gameScore = savedGame.score;
      errors = savedGame.errors;
      gameDifficulty = savedGame.difficulty;
      isLoading = false;
    });

    timerProvider.setTimer(savedGame.timeInSeconds);
    timerProvider.start();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final timerProvider = context.watch<SudokuTimerProvider>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, result) async {
        final newState = SudokuGameState(
          currentBoard: board.values,
          originalBoard: originalBoard.values,
          notes: SudokuGameState.encodeNotes(notes),
          timeInSeconds: context.read<SudokuTimerProvider>().seconds,
          isPaused: !context.read<SudokuTimerProvider>().isRunning,
          errors: errors,
          score: gameScore,
          difficulty: gameDifficulty
        );
        await SudokuGameState.saveSudoku(newState);

        timerProvider.pause();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: const Text('Sudoku'),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 30, // ajusta este valor al ancho de tu SudokuComboTimer
                    height: 30,
                  ),
                  AnimatedDigitWidget(
                    value: gameScore,
                    key: _scoreKey,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 30, // ajusta este valor al ancho de tu SudokuComboTimer
                    height: 30, // opcional, si el alto también influye
                    child: _combo > 1
                        ? SudokuComboTimer(
                      progress: _comboTimeLeft,
                      combo: _combo,
                    )
                        : const SizedBox.shrink(), // ocupa espacio pero no muestra nada
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Reset',
                  onPressed: () async {
                    final savedGame = await SudokuGameState.resetSudoku();
                    setState(() {
                      board = Board.withValues(savedGame.originalBoard ?? []);
                    });
                    gameScore = 0;
                    errors = 0;
                    timerProvider.reset();
                    setState(() {
                      _combo = 1;
                    });
                    _comboTimeLeft = 0.0;
                    _lastCorrectTime = null;
                    _comboTimer?.cancel();
                    notes.clear();
                    selectedRow = null;
                    selectedCol = null;
                  },
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          SudokuTopBarInfo(board: board, errors: errors),
                          const SizedBox(height: 10),
                          Center(
                            child: SizedBox(
                              width: side,
                              height: side,
                              child: SudokuBoard(
                                board: board.values,
                                originalBoard: originalBoard.values,
                                onCellTap: (row, col) {
                                  setState(() {
                                    if (selectedRow == row && selectedCol == col) {
                                      selectedRow = null;
                                      selectedCol = null;
                                    } else {
                                      selectedRow = row;
                                      selectedCol = col;
                                    }
                                  });
                                },
                                selectedRow: selectedRow,
                                selectedCol: selectedCol,
                                notas: notes,
                                cellKeys: _cellKeys,
                                tooltipControllers: _tooltipControllers,
                                tooltipText: _tooltipText,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SudokuActionsBar(
                            isPuttingNotes: isPuttingNotes,
                            onUndo: () {
                              setState(() {
                                if (moveHistory.isNotEmpty) {
                                  final lastMove = moveHistory.removeLast();
                                  final key = (lastMove.row, lastMove.col);
                                  if (isPuttingNotes) {
                                    if (notes.containsKey(key)) {
                                      notes[key]!.clear();
                                    }
                                  } else {
                                    board.setAt(
                                      row: lastMove.row,
                                      col: lastMove.col,
                                      value: lastMove.oldValue[lastMove.row][lastMove.col],
                                    );
                                    gameScore = lastMove.oldScore;
                                  }
                                  selectedRow = null;
                                  selectedCol = null;
                                }
                              });
                            },
                            onRemove: () {
                              setState(() {
                                if (selectedRow != null && selectedCol != null &&
                                    originalBoard.values[selectedRow!][selectedCol!] == 0 &&
                                    board.values[selectedRow!][selectedCol!] != 0
                                ) {
                                  final key = (selectedRow!, selectedCol!);
                                  if (isPuttingNotes) {
                                    notes.remove(key);
                                  } else {
                                    var removedBoard = board.values;
                                    removedBoard[selectedRow!][selectedCol!] = 0;
                                    board = Board.withValues(removedBoard);
                                    //board = Board.withValues(board. ?? []);
                                  }
                                  selectedRow = null;
                                  selectedCol = null;
                                }
                              });
                            },
                            onToggleNotes: () {
                              setState(() {
                                isPuttingNotes = !isPuttingNotes;
                              });
                            },
                            onHint: () {
                              var hint = getRandomHint(board);
                              print(hint);
                              var hintValue = hint.$3?.first;
                              setState(() {
                                _tooltipText = "Aquí va un $hintValue";
                              });
                              Future.delayed(const Duration(milliseconds: 1), () {
                                _tooltipControllers[(hint.$1, hint.$2)]?.show();
                              });

                            },
                          ),
                          const SizedBox(height: 20),
                          if (selectedRow != null && selectedCol != null)
                            SudokuNumberPad(
                              board: board,
                              selectedRow: selectedRow!,
                              selectedCol: selectedCol!,
                              notes: notes,
                              isPuttingNotes: isPuttingNotes,
                              onNumberTap: (num) async {
                                setState(() {
                                  final key = (selectedRow!, selectedCol!);
                                  if (isPuttingNotes) {
                                    if (notes.containsKey(key)) {
                                      if (notes[key]!.contains(num)) {
                                        notes[key]!.remove(num);
                                      } else {
                                        notes[key]!.add(num);
                                      }
                                    } else {
                                      notes[key] = {num};
                                    }
                                  } else {
                                    final oldValue = board.values;
                                    final oldScore = gameScore;
                                    final success = board.trySetAt(
                                      row: selectedRow!,
                                      col: selectedCol!,
                                      value: num,
                                    );
                                    if (!success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Invalid move!'),
                                        ),
                                      );
                                      errors++;

                                      _comboTimer?.cancel();
                                      setState(() {
                                        _comboTimeLeft = 0.0;
                                        _combo = 1;
                                      });
                                    } else {
                                      int rowTemp = selectedRow!;
                                      int colTemp = selectedCol!;

                                      final now = DateTime.now();

                                      // Si ya había un acierto anterior y fue hace menos de 3 segundos, aumenta combo
                                      if (_lastCorrectTime != null &&
                                          now.difference(_lastCorrectTime!).inSeconds <= 5) {
                                        setState(() {
                                          _combo++;
                                        });
                                      } else {
                                        // Si es el primer acierto o han pasado más de 3 segundos, empezamos en x2
                                        setState(() {
                                          _combo = 2;
                                        });
                                      }

                                      _lastCorrectTime = now;

                                      var extraPoints = 0;
                                      String? description;
                                      if (isRowComplete(board, selectedRow!)) {
                                        extraPoints = 50;
                                        description = 'Row complete!';
                                      }

                                      if (isColumnComplete(board, selectedCol!)) {
                                        extraPoints = 50;
                                        description = 'Column complete!';
                                      }

                                      if (isBlockComplete(board, selectedRow!, selectedCol!)) {
                                        extraPoints = 50;
                                        description = 'Block complete!';
                                      }

                                      final puntosGanados = (40 + extraPoints) * (_combo - 1); // Combo x2 → 40, x3 → 80, etc.

                                      Future.delayed(const Duration(milliseconds: 50), () {
                                        _animateBubbleToAppBar(rowTemp, colTemp, puntosGanados, description);
                                      });

                                      // Reiniciar temporizador del combo
                                      _comboTimer?.cancel();
                                      setState(() {
                                        _comboTimeLeft = 1.0;
                                      });

                                      _comboTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                                        setState(() {
                                          _comboTimeLeft -= 0.02;
                                          if (_comboTimeLeft <= 0) {
                                            _comboTimeLeft = 0;
                                            _combo = 2; // Reiniciamos a x2, no a x1
                                            timer.cancel();
                                          }
                                        });
                                      });

                                      moveHistory.add(Move(
                                        row: selectedRow!,
                                        col: selectedCol!,
                                        oldValue: oldValue,
                                        oldScore: oldScore,
                                      ));
                                    }
                                    //board.setAt(row: selectedRow!, col: selectedCol!, value: num);
                                    selectedRow = null;
                                    selectedCol = null;
                                  }
                                });
                                final newState = SudokuGameState(
                                  currentBoard: board.values,
                                  originalBoard: originalBoard.values,
                                  notes: SudokuGameState.encodeNotes(notes),
                                  timeInSeconds: context.read<SudokuTimerProvider>().seconds,
                                  isPaused: !context.read<SudokuTimerProvider>().isRunning,
                                  errors: errors,
                                  score: gameScore,
                                  difficulty: gameDifficulty
                                );
                                await SudokuGameState.saveSudoku(newState);
                              },
                            ),
                          const SizedBox(height: 20),
                          if (board.isSolvable)
                            CustomButton(
                              text: 'Solve',
                              onPressed: () {
                                setState(() {
                                  board = findSolutions(board).first;
                                  selectedRow = null;
                                  selectedCol = null;
                                  timerProvider.togglePause();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  final GlobalKey _scoreKey = GlobalKey();
  final Map<(int, int), GlobalKey> _cellKeys = {
    for (int r = 0; r < 9; r++)
      for (int c = 0; c < 9; c++)
        (r, c): GlobalKey()
  };
  final Map<(int, int), ElTooltipController> _tooltipControllers = {
    for (int r = 0; r < 9; r++)
      for (int c = 0; c < 9; c++)
        (r, c): ElTooltipController()
  };
  String? _tooltipText;

  void _animateBubbleToAppBar(int row, int col, int puntosGanados, String? description) {
    final overlay = Overlay.of(context);
    final fromKey = _cellKeys[(row, col)];
    final toKey = _scoreKey;

    if (fromKey?.currentContext == null || toKey.currentContext == null) {
      debugPrint("🛑 Animación cancelada: contextos no montados.");
      return;
    }

    final renderBoxFrom = fromKey!.currentContext!.findRenderObject() as RenderBox?;
    final renderBoxTo = toKey.currentContext!.findRenderObject() as RenderBox?;

    if (renderBoxFrom == null || renderBoxTo == null) return;

    final fromOffset = renderBoxFrom.localToGlobal(Offset.zero) +
        Offset(renderBoxFrom.size.width / 6, 0);
    final toOffset = renderBoxTo.localToGlobal(Offset.zero);

    // 🎯 PRIMERA ANIMACIÓN: levita un poco hacia arriba
    final levitateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final levitateAnimation = Tween<Offset>(
      begin: fromOffset,
      end: fromOffset.translate(0, -20),
    ).animate(CurvedAnimation(parent: levitateController, curve: Curves.easeOut));

    final bubble = OverlayEntry(
      builder: (_) => AnimatedBuilder(
        animation: levitateAnimation,
        builder: (_, __) => Positioned(
          top: levitateAnimation.value.dy,
          left: levitateAnimation.value.dx,
          child: SudokuScoreBubble(puntos: puntosGanados, description: description),
        ),
      ),
    );

    overlay.insert(bubble);
    levitateController.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 300)); // ⏸️ Pausita

      final flyController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );

      final flyAnimation = Tween<Offset>(
        begin: levitateAnimation.value,
        end: toOffset,
      ).animate(CurvedAnimation(parent: flyController, curve: Curves.easeInQuad));

      final flyScale = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: flyController, curve: Curves.easeInQuad));

      final animated = OverlayEntry(
        builder: (_) => AnimatedBuilder(
          animation: flyController,
          builder: (_, __) => Positioned(
            top: flyAnimation.value.dy,
            left: flyAnimation.value.dx,
            child: Transform.scale(
              scale: flyScale.value,
              child: SudokuScoreBubble(puntos: puntosGanados, description: description),
            ),
          ),
        ),
      );

      bubble.remove();
      levitateController.dispose();

      overlay.insert(animated);
      flyController.forward().whenComplete(() {
        animated.remove();
        flyController.dispose();
        setState(() => gameScore = gameScore + puntosGanados);
      });
    });
  }

  bool isRowComplete(Board board, int row) {
    return !board.values[row].contains(0);
  }

  bool isColumnComplete(Board board, int col) {
    for (int r = 0; r < board.dimension; r++) {
      if (board.values[r][col] == 0) return false;
    }
    return true;
  }

  bool isBlockComplete(Board board, int row, int col) {
    final size = board.dimension;
    final blockSize = sqrt(size).toInt();

    final blockRow = row ~/ blockSize;
    final blockCol = col ~/ blockSize;

    for (int r = 0; r < blockSize; r++) {
      for (int c = 0; c < blockSize; c++) {
        final value = board.values[blockRow * blockSize + r][blockCol * blockSize + c];
        if (value == 0) return false;
      }
    }
    return true;
  }

  /// Devuelve una pista aleatoria entre las celdas con menos números posibles.
  /// - Retorna `(row, col, Set<int>)` con la celda y sus números posibles.
  /// - Retorna `(null, null, null)` si no hay celdas vacías.
  (int?, int?, Set<int>?) getRandomHint(Board board) {
    final List<(int, int, Set<int>)> candidates = [];
    int minPossible = 10; // Inicializado con un valor mayor al máximo (9)

    // Primera pasada: encontrar el mínimo de números posibles
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board.values[row][col] == 0) {
          final possibleNumbers = board.possibleValuesAt(row: row, col: col);
          if (possibleNumbers.isEmpty) continue; // Celda sin soluciones (tablero inválido)

          if (possibleNumbers.length < minPossible) {
            minPossible = possibleNumbers.length;
            candidates.clear(); // Reiniciar la lista con el nuevo mínimo
            candidates.add((row, col, possibleNumbers));
          } else if (possibleNumbers.length == minPossible) {
            candidates.add((row, col, possibleNumbers));
          }
        }
      }
    }

    if (candidates.isEmpty) return (null, null, null);

    // Elegir una celda aleatoria entre las mejores candidatas
    final randomIndex = Random().nextInt(candidates.length);
    return candidates[randomIndex];
  }
}


// sudoku_game_state.dart
import 'package:fludoku/fludoku.dart';
import 'package:hive/hive.dart';

part 'sudoku_game_state.g.dart';

@HiveType(typeId: 0)
class SudokuGameState extends HiveObject {
  @HiveField(0)
  final List<List<int>>? currentBoard;

  @HiveField(1)
  final List<List<int>>? originalBoard;

  @HiveField(2)
  final Map<String, List<int>>? notes;

  @HiveField(3)
  final int timeInSeconds;

  @HiveField(4)
  final bool isPaused;

  @HiveField(5)
  final int errors;

  @HiveField(6)
  final int score;

  @HiveField(7)
  final String? difficulty;

  SudokuGameState({
    required this.currentBoard,
    required this.originalBoard,
    required this.notes,
    required this.timeInSeconds,
    required this.isPaused,
    required this.errors,
    required this.score,
    required this.difficulty,
  });

  factory SudokuGameState.empty() => SudokuGameState(
    currentBoard: null,
    originalBoard: null,
    notes: null,
    timeInSeconds: 0,
    isPaused: true,
    errors: 0,
    score: 0,
    difficulty: null,
  );

  static const _boxName = 'sudoku';
  static const _key = 'partida_actual';

  static Future<void> saveSudoku(SudokuGameState partida) async {
    final box = await Hive.openBox<SudokuGameState>(_boxName);
    await box.put(_key, partida);
  }

  static Future<bool> haveSudokuInProgress() async {
    final box = await Hive.openBox<SudokuGameState>(_boxName);
    return box.containsKey(_key);
  }

  static Future<SudokuGameState> loadSudoku() async {
    final box = await Hive.openBox<SudokuGameState>(_boxName);
    if (!box.containsKey(_key)) {
      await initSudoku();
    }
    return box.get(_key)!;
  }

  static Future<SudokuGameState> resetSudoku() async {
    final box = await Hive.openBox<SudokuGameState>(_boxName);

    var state = box.get(_key);
    state ??= SudokuGameState.empty();

    final board = SudokuGameState(
      currentBoard: state.originalBoard,
      originalBoard: state.originalBoard,
      notes: {},
      timeInSeconds: 0,
      isPaused: true,
      errors: 0,
      score: 0,
      difficulty: null,
    );

    await box.put(
      _key,
      board,
    );

    return board;
  }

  static Future<void> deleteSudoku() async {
    final box = await Hive.openBox<SudokuGameState>(_boxName);
    await box.delete(_key);
  }

  static Future<void> initSudoku() async {
    final box = await Hive.openBox<SudokuGameState>(_boxName);
    final board = generateSudokuPuzzle(
      level: PuzzleDifficulty.medium,
      dimension: 9,
    ).$1 as Board;

    await box.put(
      _key,
      SudokuGameState(
        currentBoard: board.values,
        originalBoard: board.values,
        notes: {},
        timeInSeconds: 0,
        isPaused: true,
        errors: 0,
        score: 0,
        difficulty: "Fácil",
      ),
    );
  }

  static Map<String, List<int>> encodeNotes(Map<(int, int), Set<int>> notas) {
    return notas.map((k, v) => MapEntry('${k.$1},${k.$2}', v.toList()));
  }

  static Map<(int, int), Set<int>> decodeNotes(Map<String, List<int>> notas) {
    return notas.map((k, v) {
      final coords = k.split(',').map(int.parse).toList();
      return MapEntry((coords[0], coords[1]), v.toSet());
    });
  }
}
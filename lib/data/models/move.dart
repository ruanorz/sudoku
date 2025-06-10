class Move {
  final int row;
  final int col;
  final List<List<int>> oldValue;
  final int oldScore;

  Move({
    required this.row,
    required this.col,
    required this.oldValue,
    required this.oldScore,
  });
}
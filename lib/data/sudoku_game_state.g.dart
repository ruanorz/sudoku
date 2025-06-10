// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudoku_game_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SudokuGameStateAdapter extends TypeAdapter<SudokuGameState> {
  @override
  final int typeId = 0;

  @override
  SudokuGameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SudokuGameState(
      currentBoard: (fields[0] as List?)
          ?.map((dynamic e) => (e as List).cast<int>())
          ?.toList(),
      originalBoard: (fields[1] as List?)
          ?.map((dynamic e) => (e as List).cast<int>())
          ?.toList(),
      notes: (fields[2] as Map?)?.map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<int>())),
      timeInSeconds: fields[3] as int,
      isPaused: fields[4] as bool,
      errors: fields[5] as int,
      score: fields[6] as int,
      difficulty: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SudokuGameState obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.currentBoard)
      ..writeByte(1)
      ..write(obj.originalBoard)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.timeInSeconds)
      ..writeByte(4)
      ..write(obj.isPaused)
      ..writeByte(5)
      ..write(obj.errors)
      ..writeByte(6)
      ..write(obj.score)
      ..writeByte(7)
      ..write(obj.difficulty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SudokuGameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

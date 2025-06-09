import 'package:flutter/material.dart';

class SudokuNotesToggle extends StatelessWidget {
  final bool isPuttingNotes;
  final VoidCallback onToggle;

  const SudokuNotesToggle({super.key,
    required this.isPuttingNotes,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Badge(
              isLabelVisible: true,
              label: isPuttingNotes ? const Text("On") : const Text("Off"),
              offset: const Offset(8, 0),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.edit, size: 32),
            ),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}
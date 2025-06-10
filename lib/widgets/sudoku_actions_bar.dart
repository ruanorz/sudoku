import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SudokuActionsBar extends StatelessWidget {
  final bool isPuttingNotes;
  final VoidCallback onRemove;
  final VoidCallback onUndo;
  final VoidCallback onToggleNotes;
  final VoidCallback onHint;

  const SudokuActionsBar({super.key,
    required this.isPuttingNotes,
    required this.onUndo,
    required this.onRemove,
    required this.onToggleNotes,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rotateLeft, size: 32),
            onPressed: onUndo,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.eraser, size: 32),
            onPressed: onRemove,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Badge(
              isLabelVisible: true,
              label: isPuttingNotes ? const Text("On") : const Text("Off"),
              offset: const Offset(8, 0),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const FaIcon(FontAwesomeIcons.pen, size: 32),
            ),
            onPressed: onToggleNotes,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Badge(
              isLabelVisible: true,
              label: const Text("1"),
              offset: const Offset(8, 0),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const FaIcon(FontAwesomeIcons.lightbulb, size: 32),
            ),
            onPressed: onHint,
          ),
        ],
      ),
    );
  }
}
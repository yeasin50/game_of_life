import 'package:flutter/material.dart';

import '../../domain/domain.dart';

class PatternSelectionView extends StatelessWidget {
  const PatternSelectionView({
    super.key,
    required this.onChanged,
    required this.selectedPattern,
  });

  final ValueChanged<CellPattern?> onChanged;

  final CellPattern? selectedPattern;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ...CellPattern.all.map(
          (e) => ActionChip(
            backgroundColor: selectedPattern?.name == e.name ? Colors.pink : null,
            label: Text(e.name),
            onPressed: () => onChanged(e),
          ),
        ),
        ActionChip(
          backgroundColor: selectedPattern == null ? Colors.pink : null,
          label: const Text("Custom"),
          onPressed: () => onChanged(null),
        ),
      ],
    );
  }
}

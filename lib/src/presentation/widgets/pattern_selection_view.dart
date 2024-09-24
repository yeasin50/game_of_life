import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../infrastructure/game_of_life_db.dart';
import 'gof_painter.dart';

import '../../domain/domain.dart';

class PatternSelectionView extends StatefulWidget {
  const PatternSelectionView({
    super.key,
    required this.onChanged,
    required this.selectedPattern,
  });

  final ValueChanged<CellPattern?> onChanged;

  final CellPattern? selectedPattern;

  @override
  State<PatternSelectionView> createState() => _PatternSelectionViewState();
}

class _PatternSelectionViewState extends State<PatternSelectionView> {
  GameStateValueNotifier<GOFState>? previewModel;

  void populateData(CellPattern e) {
    List<List<GridData>> data = [];

    for (final d in groupBy(e.data, (p0) => p0.y).entries) {
      data.add(d.value);
    }
    previewModel = GameStateValueNotifier(GOFState(data, 0));
  }

  void onChanged(CellPattern? e) {
    widget.onChanged(e);
    if (e == null) {
      previewModel = null;
    } else {
      populateData(e);
    }
  }

  @override
  void initState() {
    if (widget.selectedPattern != null) {
      populateData(widget.selectedPattern!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            ...CellPattern.all.map(
              (e) => ActionChip(
                backgroundColor: widget.selectedPattern?.name == e.name ? Colors.pink : null,
                label: Text(e.name),
                onPressed: () => onChanged(e),
              ),
            ),
            ActionChip(
              backgroundColor: widget.selectedPattern == null ? Colors.pink : null,
              label: const Text("Custom"),
              onPressed: () => onChanged(null),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: previewModel != null
              ? Center(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: GOFPainter(previewModel!),
                  ),
                )
              : const Placeholder(),
        )
      ],
    );
  }
}

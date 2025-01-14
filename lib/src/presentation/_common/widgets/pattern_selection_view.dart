import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../domain/domain.dart';
import '../../../infrastructure/infrastructure.dart';
import 'gof_painter.dart';

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

  List<CellPattern> get patterns => patternRepo.patterns;

  @override
  Widget build(BuildContext context) {
    debugPrint("rebuilding $this");
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            ...patterns.map(
              (e) => ActionChip(
                key: ValueKey(e),
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
        AspectRatio(
          aspectRatio: 1,
          child: previewModel != null
              ? CustomPaint(
                  painter: GOFPainter(previewModel!),
                )
              : const Text(
                  "Continue ....",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32),
                ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/domain.dart';
import '../../../infrastructure/infrastructure.dart';
import 'input_field_view.dart';

class GameTileConfigView extends StatefulWidget {
  const GameTileConfigView({
    super.key,
    required this.selectedPattern,
  });
  final CellPattern? selectedPattern;

  @override
  State<GameTileConfigView> createState() => _GameTileConfigViewState();
}

class _GameTileConfigViewState extends State<GameTileConfigView> {
  late final TextEditingController dimensionController;
  late final TextEditingController nbColumnController;
  late final TextEditingController nbRowController;
  late final TextEditingController animationDelayController;

  int get getNBRow => int.tryParse(nbRowController.text.trim()) ?? 50;
  int get getNBColumn => int.tryParse(nbColumnController.text.trim()) ?? 50;
  int get getDimension => int.tryParse(dimensionController.text.trim()) ?? 100;

  Duration get generationGap => Duration(milliseconds: int.tryParse(animationDelayController.text.trim()) ?? 0);

  int get recommendedIsolateCounter => (getNBRow * getNBColumn * gameConfig.paintClarity) ~/ 2500;

  @override
  void initState() {
    super.initState();
    dimensionController = TextEditingController.fromValue(TextEditingValue(text: gameConfig.dimension.toString()));
    nbColumnController = TextEditingController.fromValue(TextEditingValue(text: gameConfig.numberOfCol.toString()));
    nbRowController = TextEditingController.fromValue(TextEditingValue(text: gameConfig.numberOfRows.toString()));
    animationDelayController = TextEditingController.fromValue(
      TextEditingValue(text: gameConfig.generationGap.inMilliseconds.toString()),
    );

    dimensionController.addListener(() => gameConfig.dimension = getDimension);
    nbColumnController.addListener(() => gameConfig.numberOfCol = getNBColumn);
    nbRowController.addListener(() => gameConfig.numberOfRows = getNBRow);
    animationDelayController.addListener(() => gameConfig.generationGap = generationGap);
  }

  @override
  void dispose() {
    dimensionController.dispose();
    nbColumnController.dispose();
    nbRowController.dispose();
    super.dispose();
  }

  final renderMode = GamePlaySimulateType.values
      .map(
        (e) => ButtonSegment(
          value: e,
          label: Text(e.name),
        ),
      )
      .toList();

  late GamePlaySimulateType selectedRender = gameConfig.simulateType;

  void onSelectionChanged(Set<GamePlaySimulateType> p1) {
    selectedRender = p1.first;
    gameConfig.simulateType = p1.first;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<GamePlaySimulateType>(
          onSelectionChanged: onSelectionChanged,
          segments: renderMode,
          selected: {selectedRender},
          showSelectedIcon: false,
        ),
        const SizedBox(height: 24),
        if (selectedRender.isShader) ...[
          InputField(
            type: InputFiledType.dimension,
            minValue: widget.selectedPattern?.minSpace.$2 ?? 3,
            controller: dimensionController,
          ),
        ] else ...[
          InputField(
            type: InputFiledType.cols,
            minValue: widget.selectedPattern?.minSpace.$2 ?? 3,
            controller: nbColumnController,
          ),
          const SizedBox(height: 24),
          InputField(
            minValue: widget.selectedPattern?.minSpace.$1 ?? 3,
            type: InputFiledType.rows,
            controller: nbRowController,
          ),
          const SizedBox(height: 24),
          InputField(
            type: InputFiledType.animDelay,
            controller: animationDelayController,
            minValue: -1,
          ),
        ],
        const SizedBox(height: 24),
        if (selectedRender == GamePlaySimulateType.image) ...[
          const Text("⚠ Pixel clarity for large model"),
          Slider(
            value: gameConfig.paintClarity,
            min: 1,
            max: 15,
            divisions: 30,
            onChanged: (v) {
              gameConfig.paintClarity = v;
              setState(() {});
            },
          ),
        ],
        const SizedBox(height: 24),
        SwitchListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: gameConfig.clipOnBorder,
          dense: true,
          title: const Text("Clip on border"),
          onChanged: widget.selectedPattern == null
              ? (value) async {
                  gameConfig.clipOnBorder = value;
                  setState(() {});
                }
              : null,
        ),
      ],
    );
  }
}

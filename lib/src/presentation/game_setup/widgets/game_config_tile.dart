import 'package:flutter/material.dart';
import 'package:game_of_life/src/infrastructure/game_provider.dart';

import '../../../domain/domain.dart';
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
  late final TextEditingController nbColumnController;
  late final TextEditingController nbRowController;
  late final TextEditingController animationDelayController;

  int get getNBRow => int.tryParse(nbRowController.text.trim()) ?? 50;
  int get getNBColumn => int.tryParse(nbColumnController.text.trim()) ?? 50;
  Duration get generationGap => Duration(milliseconds: int.tryParse(animationDelayController.text.trim()) ?? 0);

  int get recommendedIsolateCounter => (getNBRow * getNBColumn * gameConfig.paintClarity) ~/ 2500;

  @override
  void initState() {
    super.initState();
    nbColumnController = TextEditingController.fromValue(TextEditingValue(text: gameConfig.numberOfCol.toString()));
    nbRowController = TextEditingController.fromValue(TextEditingValue(text: gameConfig.numberOfRows.toString()));
    animationDelayController = TextEditingController.fromValue(//
        TextEditingValue(text: gameConfig.generationGap.inMilliseconds.toString()));

    nbColumnController.addListener(() => gameConfig.numberOfCol = getNBColumn);
    nbRowController.addListener(() => gameConfig.numberOfRows = getNBRow);
    animationDelayController.addListener(() => gameConfig.generationGap = generationGap);
  }

  @override
  void dispose() {
    nbColumnController.dispose();
    nbRowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const SizedBox(height: 24),
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
        const SizedBox(height: 24),
        Text("Use Isolate recommended: $recommendedIsolateCounter "),
        Slider(
          value: gameConfig.isolateCounter,
          min: 1,
          max: 15,
          divisions: 15,
          onChanged: (v) {
            gameConfig.isolateCounter = v;
            setState(() {});
          },
        ),
        SwitchListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: gameConfig.clipOnBorder,
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

import 'package:flutter/material.dart';
import 'widgets/pattern_selection_view.dart';

import '../domain/cell_pattern.dart';
import '../domain/domain.dart';
import '../infrastructure/game_provider.dart';
import 'setup_overview_page.dart';

/// - decide number of Rows and Columns
/// - decide generation delay
/// -
class GameBoardSetupPage extends StatefulWidget {
  const GameBoardSetupPage({super.key});

  @override
  State<GameBoardSetupPage> createState() => _GameBoardSetupPageState();
}

class _GameBoardSetupPageState extends State<GameBoardSetupPage> with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(vsync: this, duration: Durations.medium1);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  CellPattern? selectedPattern;

  void onPatternSelected(CellPattern? value) async {
    selectedPattern = value;
    setState(() {});
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Conway's Game of Life",
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    "https://github.com/yeasin50/game_of_life",
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    height: 300,
                    child: AnimatedSwitcher(
                      duration: Durations.medium3,
                      child: currentIndex == 1
                          ? GameTileConfigView(selectedPattern: selectedPattern)
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PatternSelectionView(
                                  onChanged: onPatternSelected,
                                  selectedPattern: selectedPattern,
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: Placeholder(),
                                )
                              ],
                            ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 48),
                      Stack(
                        children: [
                          AnimatedAlign(
                            duration: Durations.short3,
                            alignment: currentIndex == 0 ? Alignment.center : Alignment.centerLeft,
                            child: IconButton.outlined(
                              onPressed: () {
                                controller.reverse();
                                currentIndex = 0;
                                setState(() {});
                              },
                              icon: const Icon(Icons.arrow_back_ios_new),
                            ),
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (currentIndex == 0) {
                                  currentIndex = 1;
                                  controller.forward();
                                  setState(() {});
                                } else if (currentIndex == 1) {
                                  Navigator.of(context).push(SetUpOverviewPage.route());
                                } else {
                                  throw UnimplementedError();
                                }
                              },
                              child: Text(currentIndex == 0 ? "Continue" : 'Start Game'),
                            ),
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    nbColumnController = TextEditingController.fromValue(TextEditingValue(text: gameConfig.numberOfCol.toString()));
    nbRowController = TextEditingController.fromValue(TextEditingValue(text: gameConfig.numberOfRows.toString()));
    animationDelayController = TextEditingController.fromValue(//
        TextEditingValue(text: gameConfig.generationGap.inMilliseconds.toString()));
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
      children: [
        _InputField(
          type: InputFiledType.cols,
          controller: nbColumnController,
        ),
        const SizedBox(height: 24),
        _InputField(
          type: InputFiledType.rows,
          controller: nbRowController,
        ),
        const SizedBox(height: 24),
        _InputField(
          type: InputFiledType.animDelay,
          controller: animationDelayController,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: gameConfig.clipOnBorder,
          title: const Text("Clip on border"),
          onChanged: (value) async {
            gameConfig.clipOnBorder = value;
            setState(() {});
          },
        ),
      ],
    );
  }
}

enum InputFiledType {
  rows,
  cols,
  animDelay;
}

extension InputFiledTypeExt on InputFiledType {
  String get label => switch (this) {
        InputFiledType.rows => 'Nb of Rows',
        InputFiledType.cols => 'Nb of Columns',
        InputFiledType.animDelay => 'anim delay (in ms)',
      };
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.type,
    required this.controller,
  });

  final InputFiledType type;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: type.label,
        border: const OutlineInputBorder(),
      ),
      autovalidateMode: AutovalidateMode.always,
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required field';
        int number = int.tryParse(value) ?? 0;
        if (number <= 0) return 'Value must be greater than 0';
        return null;
      },
    );
  }
}

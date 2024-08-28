import 'package:flutter/material.dart';

import '../domain/domain.dart';
import '../infrastructure/game_provider.dart';
import 'gof_life_page.dart';
import 'widgets/two_dimensional_custom_paint_gridview.dart';

class SetUpOverviewPage extends StatefulWidget {
  const SetUpOverviewPage._();

  static MaterialPageRoute route() {
    return MaterialPageRoute(
      builder: (context) => const SetUpOverviewPage._(),
    );
  }

  @override
  State<SetUpOverviewPage> createState() => _SetUpOverviewPageState();
}

class _SetUpOverviewPageState extends State<SetUpOverviewPage> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    gameEngine.init(config: gameConfig).then((value) {
      isLoading = false;
      setState(() {});
    });
  }

  void navToGameBoard() async {
    if (context.mounted) {
      await Navigator.of(context).push(GOFPage.route());
      gameEngine.stopPeriodicGeneration();
      setState(() {});
    }
  }

  final patterns = [
    FiveCellPattern(),
    GliderPattern(),
  ];

  CellPattern? selectedPattern;

  void onPatternSelected(CellPattern? value) {
//     final currentData = _tempGameState?.data ?? [];
//     if (value == null || currentData.isEmpty) return;
//
//     (int y, int x) midPosition = (currentData.length ~/ 2, currentData[0].length ~/ 2);
//
//     final cellData = value.data(midPosition.$1, midPosition.$2);
//     for (final cd in cellData) {
//       currentData[cd.y][cd.x] = cd;
//     }
//     _tempGameState = GOFState(currentData, 0);
//     selectedPattern = value;
//     setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Initial life cell")),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ValueListenableBuilder(
                    valueListenable: gameEngine.stateNotifier,
                    builder: (context, value, child) => Material(
                      shape: const StadiumBorder(),
                      color: Colors.deepPurpleAccent.withAlpha(20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Gen: ${value.generation} [${value.data.length}x${value.data[0].length}]"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<CellPattern>(
                    value: selectedPattern,
                    items: patterns
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name),
                            ))
                        .toList(),
                    onChanged: onPatternSelected,
                    selectedItemBuilder: (context) => patterns
                        .map((e) => Text(
                              e.name,
                              style: const TextStyle(color: Colors.white),
                            ))
                        .toList(),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => navToGameBoard(),
                    child: const Text("Start"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.redAccent.withAlpha(100),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                       gameEngine.killCells();
                    },
                    child: const Text("clear"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading ? Container() : const TwoDimensionalCustomPaintGridView(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:game_of_life/src/infrastructure/game_of_life_db.dart';

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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      fixedSize: const Size(150, 50),
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => navToGameBoard(),
                    child: const Text("Start"),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      fixedSize: const Size(100, 50),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      throw UnimplementedError();
                    },
                    child: const Text("clear"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: gameProvider.engine.gofStateNotifier,
                builder: (context, value, child) => Container(
                  color: Colors.red,
                  child: isLoading
                      ? Container()
                      : TwoDimensionalCustomPaintGridView(
                          state: value,
                          onGridDataChanged: (p0) {
                            gameEngine.gofStateNotifier.update(GOFState(p0, 0));
                            setState(() {});
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

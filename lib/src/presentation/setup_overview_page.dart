import 'package:flutter/material.dart';

import '../domain/domain.dart';
import '../infrastructure/game_provider.dart';
import '../infrastructure/infrastructure.dart';
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
  @override
  void initState() {
    gameEngine.init();
    super.initState();
  }

  void navToGameBoard() async {
    if (context.mounted) {
      await Navigator.of(context).push(GOFPage.route());
      gameEngine.stopPeriodicGeneration();
    }
  }

  final patterns = [
    FiveCellPattern(),
    GliderPattern(),
  ];

  CellPattern? selectedPattern;

  void onPatternSelected(CellPattern? value) {
    final currentData = gameEngine.gofState.data;
    if (value == null || currentData.isEmpty) return;

    (int y, int x) midPosition = (currentData.length ~/ 2, currentData[0].length ~/ 2);

    final cellData = value.data(midPosition.$1, midPosition.$2);
    for (final cd in cellData) {
      currentData[cd.y][cd.x] = cd;
    }
    gameEngine.replaceData(currentData);
    selectedPattern = value;
    setState(() {});
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
                    onPressed: navToGameBoard,
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
              child: Container(
                color: Colors.red,
                child: StreamBuilder<GOFState>(
                    stream: gameEngine.dataStream,
                    initialData: GOFState.empty(),
                    builder: (context, snapshot) {
                      final List<List<GridData>> data = [...snapshot.data?.data ?? []];
                      if (data.isEmpty) return const SizedBox.shrink();

                      return TwoDimensionalCustomPaintGridView(
                        initialData: data,
                        onGridDataChanged: (data) {
                          gameEngine.replaceData(data);
                        },
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

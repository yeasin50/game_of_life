import 'package:flutter/material.dart';
import 'package:game_of_life/src/infrastructure/game_provider.dart';

import '../domain/domain.dart';
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
  List<List<GridData>> data = [];

  @override
  void initState() {
    super.initState();
    //todo: should be on isolate or use the engine
    for (int y = 0; y < gameConfig.numberOfRows; y++) {
      final rows = <GridData>[];
      for (int x = 0; x < gameConfig.numberOfRows; x++) {
        final item = GridData(x: x, y: y, life: 0);
        rows.add(item);
      }
      data.add(rows);
    }
  }

  void navToGameBoard() {
    // Navigator.of(context).push(GOFPage.route());
  }

  void clear() {
    data = [];
    setState(() {});
  }

  final patterns = [
    FiveCellPattern(),
    GliderPattern(),
  ];

  CellPattern? selectedPattern;

  (int y, int x) get midPosition => (data.length ~/ 2, data[0].length ~/ 2);

  void onPatternSelected(CellPattern? value) {
    if (value == null) return;
    final cellData = value.data(midPosition.$1, midPosition.$2);
    for (final cd in cellData) {
      data[cd.y][cd.x] = cd;
    }
    selectedPattern = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Expanded(
            //   child: TwoDimensionalCustomPaintGridView(
            //     key: ValueKey("${data.hashCode} $selectedPattern"), //🤣
            //     gridSize: (gameConfig., widget.numberOfCol),
            //     onGridDataChanged: (p0) => data = p0,
            //   ),
            // ),
            Column(
              mainAxisSize: MainAxisSize.min,
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
                  onPressed: clear,
                  child: const Text("clear"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

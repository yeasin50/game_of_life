import 'package:flutter/material.dart';

import '../domain/domain.dart';
import 'gof_life_page.dart';
import 'widgets/two_dimensional_custom_paint_gridview.dart';

class SetUpOverviewPage extends StatefulWidget {
  const SetUpOverviewPage._({
    required this.numberOfRows,
    required this.numberOfCol,
    required this.generationGap,
  });

  const SetUpOverviewPage.test({
    this.numberOfRows = 50,
    this.numberOfCol = 50,
    this.generationGap = const Duration(milliseconds: 250),
  });

  final int numberOfRows;
  final int numberOfCol;
  final Duration generationGap;

  static MaterialPageRoute route({
    required int numberOfRows,
    required int numberOfCol,
    required Duration generationGap,
  }) {
    return MaterialPageRoute(
      builder: (context) => SetUpOverviewPage._(
        numberOfRows: numberOfRows,
        numberOfCol: numberOfCol,
        generationGap: generationGap,
      ),
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
    for (int y = 0; y < widget.numberOfRows; y++) {
      final rows = <GridData>[];
      for (int x = 0; x < widget.numberOfCol; x++) {
        final item = GridData(x: x, y: y, life: 0);
        rows.add(item);
      }
      data.add(rows);
    }
  }

  void navToGameBoard() {
    final engine = GameOfLifeEngine()
      ..init(
        numberOfCol: widget.numberOfCol,
        numberOfRows: widget.numberOfRows,
        generationGap: widget.generationGap,
        initData: data,
      );

    debugPrint("init data length ${data.length * data[0].length}");
    Navigator.of(context).push(GOFPage.route(engine: engine));
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
      print(cd);
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
            Expanded(
              child: TwoDimensionalCustomPaintGridView(
                key: ValueKey("${data.hashCode} $selectedPattern"), //🤣
                gridSize: (widget.numberOfRows, widget.numberOfCol),
                onGridDataChanged: (p0) => data = p0,
              ),
            ),
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

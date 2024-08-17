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
    this.numberOfRows = 150,
    this.numberOfCol = 150,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TwoDimensionalCustomPaintGridView(
                key: ValueKey(data.hashCode), //🤣
                gridSize: (widget.numberOfRows, widget.numberOfCol),
                onGridDataChanged: (p0) => data = p0,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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

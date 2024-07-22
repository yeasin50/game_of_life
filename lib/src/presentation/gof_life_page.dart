import 'package:flutter/material.dart';
import 'package:so_help/src/domain/game_of_life_engine.dart';

import '../domain/grid_data.dart';
import 'widgets/grid_item_view.dart';

class GOFPage extends StatefulWidget {
  const GOFPage({
    super.key,
    required this.engine,
  });

  final GameOfLifeEngine engine;

  @override
  State<GOFPage> createState() => _GOFPageState();
}

class _GOFPageState extends State<GOFPage> {
  int crossAxisCount = 0;
  int mainAxisCount = 0;
  double maxItemSize = 0;
  List<GridData> data = [];

  bool isReady = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  void initData() {
    widget.engine.init(
      size: MediaQuery.sizeOf(context),
    );
    crossAxisCount = widget.engine.nbOfCols;
    mainAxisCount = widget.engine.nbOfRows;
    maxItemSize = widget.engine.maxItemSize;
    data = widget.engine.data;
    isReady = true;
    setState(() {});
  }

  void next() {
    widget.engine.next();
    data = widget.engine.data;
    print("updated");
    setState(() {});
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: next,
            child: const Icon(Icons.next_plan),
          ),
          FloatingActionButton(
            child: const Icon(Icons.restore),
            onPressed: () {
              initData();
            },
          ),
        ],
      ),
      body: Center(
        child: isReady == false
            ? const Text("xxx")
            : Wrap(
                children: data
                    .map((e) => SizedBox(
                          height: maxItemSize,
                          width: maxItemSize,
                          child: GridItemView(
                            data: e,
                          ),
                        ))
                    .toList()),
      ),
    );
  }
}

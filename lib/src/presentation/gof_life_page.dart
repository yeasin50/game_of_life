import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/game_of_life_engine.dart';
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
  ///
  final generationDelay = Durations.short1;

  int crossAxisCount = 0;
  int mainAxisCount = 0;
  double maxItemSize = 0;
  List<List<GridData>> data = [];

  bool isReady = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  void initData() {
    _timer?.cancel();
    widget.engine.init(
      size: MediaQuery.sizeOf(context),
      itemSize: 50,
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
    setState(() {});
  }

  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = null;

    _timer = Timer.periodic(generationDelay, (t) {
      next();
    });
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.engine.dispose();
    super.dispose();
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: start,
            child: const Icon(Icons.start),
          ),
          FloatingActionButton(
            onPressed: pause,
            child: const Icon(Icons.stop),
          ),
          FloatingActionButton(
            onPressed: next,
            child: const Icon(Icons.next_plan),
          ),
          FloatingActionButton(
            onPressed: initData,
            child: const Icon(Icons.restore),
          ),
        ],
      ),
      body: Center(
        child: isReady == false
            ? const CircularProgressIndicator()
            : Wrap(
                children: [
                  for (final x in data)
                    for (final e in x)
                      SizedBox(
                        height: maxItemSize,
                        width: maxItemSize,
                        child: GridItemView(
                          data: e,
                        ),
                      )
                ],
              ),
      ),
    );
  }
}

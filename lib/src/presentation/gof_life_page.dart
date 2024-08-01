import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:game_of_life/src/presentation/widgets/gof_painter.dart';

import '../domain/game_of_life_engine.dart';
import '../domain/grid_data.dart';

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
    widget.engine.init(numberOfCol: 250, numberOfRows: 150).then((_) {
      data = widget.engine.data;
      isReady = true;
      debugPrint("total grid ${widget.engine.totalCell}");
      setState(() {});
    });
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
      backgroundColor: Colors.black,
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: isReady == false
                    ? const CircularProgressIndicator()
                    : CustomPaint(
                        painter: GOFPainter(data),
                        size: Size.infinite,
                      ),
              ),
            ),
          ),
          Column(
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
        ],
      ),
    );
  }
}

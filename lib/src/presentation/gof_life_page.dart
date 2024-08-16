import 'package:flutter/material.dart';
import 'package:game_of_life/src/presentation/widgets/gof_painter.dart';

import '../domain/game_of_life_engine.dart';

class GOFPage extends StatelessWidget {
  const GOFPage._(this.engine);

  final GameOfLifeEngine engine;

  static MaterialPageRoute route({required GameOfLifeEngine engine}) {
    return MaterialPageRoute(builder: (context) => GOFPage._(engine));
  }

  //
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: engine,
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: engine.isReady == false
                      ? const CircularProgressIndicator()
                      : CustomPaint(
                          painter: GOFPainter(engine.data),
                          size: Size.infinite,
                        ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () => engine.startPeriodicGeneration(),
                  child: const Icon(Icons.start),
                ),
                FloatingActionButton(
                  onPressed: () => engine.stopPeriodicGeneration(),
                  child: const Icon(Icons.stop),
                ),
                FloatingActionButton(
                  onPressed: () => engine.nextGeneration(),
                  child: const Icon(Icons.next_plan),
                ),
                FloatingActionButton(
                  onPressed: () => engine.clear(),
                  child: const Icon(Icons.exit_to_app_sharp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

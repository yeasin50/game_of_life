import 'package:flutter/material.dart';
import 'widgets/gof_painter.dart';

import '../domain/game_of_life_engine.dart';

class GOFPage extends StatelessWidget {
  const GOFPage._(this.engine);

  final GameOfLifeEngine engine;

  static MaterialPageRoute route({required GameOfLifeEngine engine}) {
    return MaterialPageRoute(builder: (context) => GOFPage._(engine));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: engine,
      builder: (context, child) => Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: engine.isReady == false
                      ? const CircularProgressIndicator()
                      : InteractiveViewer(
                          minScale: 1,
                          maxScale: 100.0,
                          child: CustomPaint(
                            painter: GOFPainter(engine.data, true),
                            size: Size.infinite,
                          ),
                        ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: engine.isActive ? Colors.red : Colors.green,
                  ),
                  onPressed: () => engine.isActive ? engine.stopPeriodicGeneration() : engine.startPeriodicGeneration(),
                  child: engine.isActive ? const Text("Stop") : const Text("Simulate"),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => engine.nextGeneration(),
                  child: const Text("Next Generation"),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    engine.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Exit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

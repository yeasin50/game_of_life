import 'package:flutter/material.dart';

import '../infrastructure/game_provider.dart';
import 'widgets/gof_painter.dart';

class GOFPage extends StatelessWidget {
  const GOFPage._() : super(key: const ValueKey('GOFPage simulation page'));

  static MaterialPageRoute route() {
    return MaterialPageRoute(builder: (context) => const GOFPage._());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game of Life')),
      body: Column(
        children: [
          const ActionButtons(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 100.0,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: GOFPainter(
                        context.gameEngine.stateNotifier,
                        true,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtons extends StatefulWidget {
  const ActionButtons({super.key, this.showGenerationOnPlay});

  final ValueChanged? showGenerationOnPlay;
  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool isPlaying = false;

  void onPlayPause() {
    isPlaying = !isPlaying;
    setState(() {});

    if (isPlaying) {
      gameEngine.startPeriodicGeneration();
    } else {
      gameEngine.stopPeriodicGeneration();
    }
  }

  void onNextGen() async {
    await gameEngine.nextGeneration();
  }

  bool showGeneration = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: isPlaying ? Colors.red : Colors.green),
          onPressed: onPlayPause,
          child: isPlaying ? const Text("Stop") : const Text("Simulate"),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: onNextGen,
          child: const Text("Next Generation "),
        ),
        const SizedBox(width: 16.0),
        ValueListenableBuilder(
          valueListenable: gameEngine.stateNotifier,
          builder: (context, value, child) => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: showGeneration ? Colors.blue.withAlpha(70) : Colors.transparent,
            ),
            onPressed: () {
              showGeneration = !showGeneration;
              widget.showGenerationOnPlay?.call(showGeneration);
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Gen: ${value.generation} [${value.data.length}x${value.data[0].length}]"),
            ),
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../infrastructure/game_of_life_engine.dart';
import '../infrastructure/game_provider.dart';
import 'widgets/gof_painter.dart';

class GOFPage extends StatefulWidget {
  const GOFPage._();

  static MaterialPageRoute route() {
    return MaterialPageRoute(builder: (context) => const GOFPage._());
  }

  @override
  State<GOFPage> createState() => _GOFPageState();
}

class _GOFPageState extends State<GOFPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GOFState>(
        stream: gameState,
        initialData: gameEngine.gofState,
        builder: (context, snapshot) {
          final state = snapshot.data!;
          if (snapshot.data!.isLoading) return const Center(child: CircularProgressIndicator());
          return Scaffold(
            appBar: AppBar(),
            body: Column(
              children: [
                const ActionButtons(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: state.data.isEmpty
                          ? const CircularProgressIndicator()
                          : InteractiveViewer(
                              minScale: 1,
                              maxScale: 100.0,
                              child: CustomPaint(
                                painter: GOFPainter(state.data, true),
                                size: Size.infinite,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class ActionButtons extends StatefulWidget {
  const ActionButtons({super.key});

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

  void onExit() {
    gameEngine.stopPeriodicGeneration();
    Navigator.of(context).pop();
  }

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
          child: const Text("Next Generation"),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: onExit,
          child: const Text("Exit"),
        ),
      ],
    );
  }
}

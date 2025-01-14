import 'package:flutter/material.dart';

import '../../../infrastructure/game_provider.dart';

class SimulationActionButtons extends StatefulWidget {
  const SimulationActionButtons({super.key, this.showGenerationOnPlay});

  final ValueChanged? showGenerationOnPlay;
  @override
  State<SimulationActionButtons> createState() =>
      _SimulationActionButtonsState();
}

class _SimulationActionButtonsState extends State<SimulationActionButtons> {
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

  bool showGeneration = false;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        IconButton.outlined(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: isPlaying ? Colors.red : Colors.green),
          onPressed: onPlayPause,
          child: isPlaying ? const Text("Stop") : const Text("Simulate"),
        ),
        ElevatedButton(
          onPressed: onNextGen,
          child: const Text("Next Generation "),
        ),
        ValueListenableBuilder(
          valueListenable: gameEngine.stateNotifier,
          builder: (context, value, child) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionChip(
                shape: const CircleBorder(),
                backgroundColor: showGeneration
                    ? Colors.deepPurpleAccent
                    : Colors.transparent,
                onPressed: () {
                  showGeneration = !showGeneration;
                  gameEngine.updateState(
                      value.copyWith(colorizeGrid: showGeneration));
                  setState(() {});
                },
                label: Icon(!showGeneration
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
              ),
              Text(
                "Gen: ${value.generation} [${value.data.length}x${value.data[0].length}]",
              )
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../infrastructure/game_provider.dart';
import '../../infrastructure/widget_to_image.dart';
import 'game_play_action_view.dart';

class GOFPage extends StatelessWidget {
  const GOFPage._() : super(key: const ValueKey('GOFPage simulation page'));

  static MaterialPageRoute route() {
    return MaterialPageRoute(builder: (context) => const GOFPage._());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game of Life'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: SimulationActionButtons(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24, bottom: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / context.gameState.data.first.length;
                  final itemHeight = constraints.maxHeight / context.gameState.data.length;
                  final itemSize = itemHeight < itemWidth ? itemHeight : itemWidth;

                  final (paintWidth, paintHeight) = (
                    context.gameState.data.first.length * itemSize,
                    context.gameState.data.length * itemSize,
                  );
                  return InteractiveViewer(
                    minScale: 1,
                    maxScale: 100.0,
                    child: Center(
                      child: PaintWidgetBuilder(
                        size: Size(paintWidth, paintHeight) * context.gameConfig.paintClarity,
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PaintWidgetBuilder extends StatefulWidget {
  const PaintWidgetBuilder({super.key, required this.size});

  final Size size;

  @override
  State<PaintWidgetBuilder> createState() => _PaintWidgetBuilderState();
}

class _PaintWidgetBuilderState extends State<PaintWidgetBuilder> with GameOfLifeSimulationMixin {
  Widget? child;

  void refreshPaint() async {
    child = await buildImage(context);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    gameEngine.stateNotifier.removeListener(refreshPaint);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return child == null ? const CircularProgressIndicator() : child!;
  }
}

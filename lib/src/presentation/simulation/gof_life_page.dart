import 'package:flutter/material.dart';

import '../../domain/domain.dart';
import '../../infrastructure/game_provider.dart';
import '../_common/widgets/gof_painter.dart';
import '../_common/widgets/gof_painter_v2.dart';
import 'widgets/game_play_action_view.dart';

/// Non -shader game play page
class GOFPage extends StatefulWidget {
  const GOFPage._() : super(key: const ValueKey('GOFPage simulation page'));

  static MaterialPageRoute route() {
    return MaterialPageRoute(
      builder: (context) => const GOFPage._(),
    );
  }

  @override
  State<GOFPage> createState() => _GOFPageState();
}

class _GOFPageState extends State<GOFPage> {
  @override
  void initState() {
    super.initState();
    gameEngine.nextGeneration();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth /
                      context.gameState.data.first.length;
                  final itemHeight =
                      constraints.maxHeight / context.gameState.data.length;
                  final itemSize =
                      itemHeight < itemWidth ? itemHeight : itemWidth;

                  final (paintWidth, paintHeight) = (
                    context.gameState.data.first.length * itemSize,
                    context.gameState.data.length * itemSize,
                  );

                  final canvasSize = Size(paintWidth, paintHeight) *
                      context.gameConfig.paintClarity;

                  context.gameEngine.setCanvas(context, canvasSize);
                  context.gameConfig.gridSize = itemSize;

                  return InteractiveViewer(
                    minScale: 1,
                    maxScale: 100.0,
                    child: Center(
                      child: ListenableBuilder(
                        listenable: context.gameEngine.stateNotifier,
                        builder: (context, child) {
                          final stateR = context.gameState;

                          return SizedBox.fromSize(
                            key: const ValueKey("gameOfLife_canvas"),
                            size: canvasSize,
                            child: context.gameConfig.simulateType.isRealTime ==
                                        false &&
                                    stateR.canvas == null &&
                                    stateR.rawImageData == null
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : RepaintBoundary(
                                    child: switch (
                                        context.gameConfig.simulateType) {
                                    GamePlaySimulateType.shader =>
                                      const Text("use ShaderGamePlayPage"),
                                    GamePlaySimulateType.realtime =>
                                      CustomPaint(
                                        key: const ValueKey(
                                            "gameOfLife_realtime"),
                                        size: Size(paintWidth, paintHeight),
                                        painter: GOFPainter(
                                          context.gameEngine.stateNotifier,
                                          showBorder: false,
                                        ),
                                      ),
                                    GamePlaySimulateType.canvas => CustomPaint(
                                        key:
                                            const ValueKey("gameOfLife_canvas"),
                                        size: Size(paintWidth, paintHeight),
                                        painter: GOFPainterV2(
                                          context.gameEngine.stateNotifier,
                                          showBorder: false,
                                        ),
                                      ),
                                    GamePlaySimulateType.image => RawImage(
                                        height: canvasSize.height,
                                        width: canvasSize.width,
                                        image: stateR.rawImageData,
                                      ),
                                  }),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: SimulationActionButtons(),
          ),
        ],
      ),
    );
  }
}

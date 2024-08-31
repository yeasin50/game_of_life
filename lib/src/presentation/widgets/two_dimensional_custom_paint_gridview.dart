import 'package:flutter/material.dart';
import 'package:game_of_life/src/infrastructure/game_provider.dart';
import 'dart:math' as math;
import 'gof_painter.dart';

class TwoDimensionalCustomPaintGridView extends StatelessWidget {
  const TwoDimensionalCustomPaintGridView({
    super.key,
  });

  void onTapDown(BuildContext context, TapDownDetails details) {
    // Calculate the local position relative to the CustomPaint
    final localPosition = details.localPosition;
    final state = context.gameEngine.gofState;
    final data = [...state.data];

    final itemWidth =
        data[0].isNotEmpty ? context.size!.width / data[0].length : 0.0; // Handle potential division by zero
    final itemHeight = data.isNotEmpty ? context.size!.height / data.length : 0.0;
    final itemSize = math.min(itemWidth, itemHeight);

    final tappedX = (localPosition.dx / itemSize).floor();
    final tappedY = (localPosition.dy / itemSize).floor();
    debugPrint('$tappedX, $tappedY');
    if (tappedX >= 0 && tappedX < data[0].length && tappedY >= 0 && tappedY < data.length) {
      bool isDead = data[tappedY][tappedX].life == 0.0;
      data[tappedY][tappedX] = data[tappedY][tappedX].copyWith(
        life: isDead ? 1.0 : 0.0,
        generation: isDead ? 1 : 0,
      );

      context.gameEngine.updateState(state.copyWith(data: data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 100.0,
      child: GestureDetector(
        onTapDown: (tapDownDetails) => onTapDown(context, tapDownDetails),
        child: RepaintBoundary(
          child: CustomPaint(
            key: const ValueKey("simulation user painter"),
            size: Size.infinite,
            painter: GOFPainter(context.gameEngine.stateNotifier),
          ),
        ),
      ),
    );
  }
}

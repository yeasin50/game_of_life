import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/domain.dart';
import '../../infrastructure/infrastructure.dart';
import 'gof_painter.dart';

class TwoDimensionalCustomPaintGridView extends StatelessWidget {
  const TwoDimensionalCustomPaintGridView({
    super.key,
    required this.state,
    required this.onGridDataChanged,
  });

  final ValueNotifier<GOFState> state;
  final Function(List<List<GridData>>) onGridDataChanged;

  void onTapDown(BuildContext context, TapDownDetails details) {
    // Calculate the local position relative to the CustomPaint
    final localPosition = details.localPosition;

    final data = [...state.value.data];

    final itemWidth =
        data[0].isNotEmpty ? context.size!.width / data[0].length : 0.0; // Handle potential division by zero
    final itemHeight = data.isNotEmpty ? context.size!.height / data.length : 0.0;
    final itemSize = math.min(itemWidth, itemHeight);

    final tappedX = (localPosition.dx / itemSize).floor();
    final tappedY = (localPosition.dy / itemSize).floor();
    debugPrint('$tappedX, $tappedY');
    if (tappedX >= 0 && tappedX < data[0].length && tappedY >= 0 && tappedY < data.length) {
      data[tappedY][tappedX] = data[tappedY][tappedX].copyWith(
        life: data[tappedY][tappedX].life == 0.0 ? 1.0 : 0.0,
      );

      onGridDataChanged(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 100.0,
      child: GestureDetector(
        onTapDown: (tapDownDetails) => onTapDown(context, tapDownDetails),
        child: CustomPaint(
          size: Size.infinite,
          painter: GOFPainter(state),
        ),
      ),
    );
  }
}

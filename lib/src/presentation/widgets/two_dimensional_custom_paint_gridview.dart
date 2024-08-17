import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/domain.dart';
import 'gof_painter.dart';

class TwoDimensionalCustomPaintGridView extends StatefulWidget {
  const TwoDimensionalCustomPaintGridView({
    super.key,
    required this.gridSize,
    required this.onGridDataChanged,
  });

  final (int xIndex, int yIndex) gridSize;
  final Function(List<List<GridData>>) onGridDataChanged;

  @override
  State<TwoDimensionalCustomPaintGridView> createState() => _TwoDimensionalCustomPaintGridViewState();
}

class _TwoDimensionalCustomPaintGridViewState extends State<TwoDimensionalCustomPaintGridView> {
  List<List<GridData>> data = [];

  @override
  void initState() {
    super.initState();
    for (int y = 0; y < widget.gridSize.$2; y++) {
      final rows = <GridData>[];
      for (int x = 0; x < widget.gridSize.$1; x++) {
        final item = GridData(x: x, y: y, life: 0);
        rows.add(item);
      }
      data.add(rows);
    }
  }

  void onTapDown(TapDownDetails details) {
    // Calculate the local position relative to the CustomPaint
    final localPosition = details.localPosition;

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

      widget.onGridDataChanged(data);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 100.0,
      child: GestureDetector(
        onTapDown: onTapDown,
        child: CustomPaint(
          size: Size.infinite,
          painter: GOFPainter(data),
        ),
      ),
    );
  }
}

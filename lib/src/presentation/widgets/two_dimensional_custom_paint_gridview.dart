import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/domain.dart';

class TwoDimensionalCustomPaintGridView extends StatefulWidget {
  const TwoDimensionalCustomPaintGridView({
    super.key,
    required this.gridSize,
  });

  final (int xIndex, int yIndex) gridSize;

  @override
  State<TwoDimensionalCustomPaintGridView> createState() => _TwoDimensionalCustomPaintGridViewState();
}

class _TwoDimensionalCustomPaintGridViewState extends State<TwoDimensionalCustomPaintGridView> {
  List<List<GridData>> data = [];

  @override
  void initState() {
    super.initState();
    for (int y = 0; y < 105; y++) {
      final rows = <GridData>[];
      for (int x = 0; x < 105; x++) {
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
          painter: _GOFPainter(data),
        ),
      ),
    );
  }
}

class _GOFPainter extends CustomPainter {
  const _GOFPainter(this.data);

  final List<List<GridData>> data;

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = size.width / data[0].length;
    final itemHeight = size.height / data.length;
    final itemSize = itemHeight < itemWidth ? itemHeight : itemWidth;
    for (int y = 0; y < data.length; y++) {
      for (int x = 0; x < data[y].length; x++) {
        final currentItem = data[y][x];
        final rect = Rect.fromLTWH(
          x * itemSize,
          y * itemSize,
          itemSize - 1,
          itemSize - 1,
        );
        canvas.drawRect(
          rect,
          Paint()..color = currentItem.isAlive ? Colors.white : Colors.black,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GOFPainter oldDelegate) {
    return listEquals(oldDelegate.data, data);
  }
}

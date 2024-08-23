import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../infrastructure/infrastructure.dart';
import '../utils/grid_data_extension.dart';

class GOFPainter extends CustomPainter {
  const GOFPainter(this.state, [this.useColorizeGeneration = false]) : super(repaint: state);

  final ValueNotifier<GOFState> state;
  final bool useColorizeGeneration;

  @override
  void paint(Canvas canvas, Size size) {
    final data = state.value.data;
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
          Paint()
            ..color = currentItem.isAlive
                ? useColorizeGeneration
                    ? currentItem.color
                    : Colors.white
                : Colors.black,
        );

        //add text
        if (useColorizeGeneration && currentItem.isAlive) {
          final textSpan = TextSpan(
            text: currentItem.generation.toString(),
            style: TextStyle(color: Colors.black, fontSize: math.min(itemSize / 2, 10)),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              x * itemSize + (itemSize - textPainter.width) / 2,
              y * itemSize + (itemSize - textPainter.height) / 2,
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant GOFPainter oldDelegate) {
    return false;
  }
}

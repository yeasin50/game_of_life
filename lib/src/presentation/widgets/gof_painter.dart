import 'package:flutter/material.dart';
import 'package:game_of_life/src/presentation/utils/grid_data_extension.dart';
import 'dart:math' as math;
import '../../infrastructure/infrastructure.dart';

class GOFPainter extends CustomPainter {
  const GOFPainter(this.notifier) : super(repaint: notifier);

  final GameStateValueNotifier<GOFState> notifier;

  @override
  void paint(Canvas canvas, Size size) {
    final data = notifier.value.data;
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
                ? notifier.value.colorizeGrid
                    ? currentItem.color
                    : Colors.white
                : Colors.black,
        );

        //add text
        if (notifier.value.colorizeGrid && currentItem.isAlive) {
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
  bool shouldRepaint(covariant GOFPainter oldDelegate) => false;
}

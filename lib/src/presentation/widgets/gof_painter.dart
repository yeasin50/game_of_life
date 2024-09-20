import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../infrastructure/infrastructure.dart';
import '../utils/grid_data_extension.dart';

class GOFPainter extends CustomPainter {
  const GOFPainter(
    this.notifier, {
    this.showBorder = false,
  }) : super(repaint: notifier);

  final GameStateValueNotifier<GOFState> notifier;
  final bool showBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final data = notifier.value.data;
    final itemWidth = size.width / data[0].length;
    final itemHeight = size.height / data.length;
    final itemSize = itemHeight < itemWidth ? itemHeight : itemWidth;

    final dividerGap = (itemSize * .1);

    for (int y = 0; y < data.length; y++) {
      for (int x = 0; x < data[y].length; x++) {
        final currentItem = data[y][x];
        final rect = Rect.fromLTWH(
          x * itemSize,
          y * itemSize,
          itemSize - dividerGap,
          itemSize - dividerGap,
        );
        canvas.drawRect(
          rect,
          Paint()
            ..color = currentItem.isAlive
                ? notifier.value.colorizeGrid
                    ? currentItem.color
                    : const Color(0xFF39ff14)
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

    if (showBorder) {
      canvas.drawRect(
        Rect.fromLTRB(0, 0, itemSize * data.first.length, itemSize * data.length),
        Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = .5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GOFPainter oldDelegate) => false;
}

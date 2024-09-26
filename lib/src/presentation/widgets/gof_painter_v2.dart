import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../infrastructure/infrastructure.dart';

class GOFPainterV2 extends CustomPainter {
  const GOFPainterV2(
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

    for (int y = 0; y < data.length; y++) {
      for (int x = 0; x < data[y].length; x++) {
        final currentItem = data[y][x];

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

    final canvasData = notifier.value.canvas!;
    print(canvasData.toString());
    canvas.drawAtlas(
      canvasData.image!, canvasData.transform, canvasData.rect, canvasData.colors, //
      BlendMode.dstATop, null, Paint(),
    );

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
  bool shouldRepaint(covariant GOFPainterV2 oldDelegate) => false;
}

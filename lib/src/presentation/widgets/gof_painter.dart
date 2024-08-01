import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/grid_data.dart';

class GOFPainter extends CustomPainter {
  const GOFPainter(this.data);

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
          itemSize,
          itemSize,
        );
        canvas.drawRect(
          rect,
          Paint()..color = currentItem.color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GOFPainter oldDelegate) {
    return listEquals(oldDelegate.data, data);
  }
}

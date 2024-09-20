import 'package:flutter/material.dart';

class GuideLinePainter extends CustomPainter {
  const GuideLinePainter({
    required this.separator,
    required this.itemSize,
  });
  final int separator;
  final double itemSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (separator > 1) {
      final linePainter = Paint()
        ..color = const Color.fromARGB(255, 122, 144, 154)
        ..strokeWidth = .2;
      final dividerGap = (itemSize * .1);
      for (int y = separator; y < size.width; y += separator) {
        final x = itemSize * y.toDouble() - dividerGap;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          linePainter,
        );
      }

      for (int y = separator; y < size.height; y += separator) {
        final x = itemSize * y.toDouble() - .5;
        canvas.drawLine(
          Offset(0, x),
          Offset(size.width, x),
          linePainter,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GuideLinePainter oldDelegate) {
    return oldDelegate.separator != separator;
  }
}

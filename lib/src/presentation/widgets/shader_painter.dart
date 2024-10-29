import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GameOfLifeShaderPainter extends CustomPainter {
  GameOfLifeShaderPainter(
    this.program,
    this.gridTexture, {
    required this.playing,
    required this.numberOfCols,
    required this.numberOfRows,
  });

  final int numberOfCols, numberOfRows;
  final ui.FragmentProgram program;
  final ui.Image gridTexture;
  final bool playing;

  @override
  void paint(Canvas canvas, Size size) {
    double gridSize = math.min(size.width / numberOfCols, size.height / numberOfRows);

    final shader = program.fragmentShader()
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setImageSampler(0, gridTexture)
      ..setFloat(2, playing ? 1.0 : 0.0)
      ..setFloat(3, gridSize);

    Paint paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

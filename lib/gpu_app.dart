import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

// NOTE: We made this earlier while setting up shader bundle imports!
import 'shaders.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GPU Triangle Example',
      home: CustomPaint(
        painter: TrianglePainter(),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Attempt to access `gpu.gpuContext`.
    // If Flutter GPU isn't supported, an exception will be thrown.
    print('Default color format: ' + gpu.gpuContext.defaultColorFormat.toString());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'dart:ui';

import 'package:flutter/material.dart';

class ShaderTestApp extends StatefulWidget {
  const ShaderTestApp({super.key});

  @override
  State<ShaderTestApp> createState() => _ShaderTestAppState();
}

class _ShaderTestAppState extends State<ShaderTestApp> {
  late FragmentProgram fragmentProgram;

  Future<FragmentProgram> loadShader() async {
    fragmentProgram = await FragmentProgram.fromAsset("assets/shader/game_of_life.frag");

    return fragmentProgram;
  }

  late final Future<FragmentProgram> loadShaderFuture = loadShader();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FragmentProgram>(
      future: loadShaderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              snapshot.error.toString(),
            ),
          );
        }
        if (snapshot.data == null) {
          return const Material(child: Center(child: CircularProgressIndicator()));
        }

        return MaterialApp(
          home: ShaderGridPlay(
            fragmentProgram: snapshot.requireData,
          ),
        );
      },
    );
  }
}

class ShaderGridPlay extends StatefulWidget {
  const ShaderGridPlay({
    super.key,
    required this.fragmentProgram,
  });
  final FragmentProgram fragmentProgram;

  @override
  State<ShaderGridPlay> createState() => _ShaderGridPlayState();
}

class _ShaderGridPlayState extends State<ShaderGridPlay> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GofShaderPaint(
        shader: widget.fragmentProgram.fragmentShader(),
        color: const Color.fromARGB(255, 84, 84, 84),
      ),
    );
  }
}

class GofShaderPaint extends CustomPainter {
  const GofShaderPaint({
    required this.color,
    required this.shader,
  });

  final Color color;
  final FragmentShader shader;

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    shader.setFloat(2, color.red.toDouble() / 255);
    shader.setFloat(3, color.green.toDouble() / 255);
    shader.setFloat(4, color.blue.toDouble() / 255);
    shader.setFloat(5, color.alpha.toDouble() / 255);

    double itemSize = .10;
    shader.setFloat(6, itemSize);
    shader.setFloat(7, itemSize);

    Color liveColor = Colors.green;
    Color deadColor = Colors.transparent;

    for (int i = 8; i < 8 + (100 * 3); i += 3) {
      if (i.isEven) {
        shader.setFloat(i, deadColor.red.toDouble() / 255);
        shader.setFloat(i + 1, deadColor.green.toDouble() / 255);
        shader.setFloat(i + 2, deadColor.blue.toDouble() / 255);
      } else {
        shader.setFloat(i, liveColor.red.toDouble() / 255);
        shader.setFloat(i + 1, liveColor.green.toDouble() / 255);
        shader.setFloat(i + 2, liveColor.blue.toDouble() / 255);
      }
    }
    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant GofShaderPaint oldDelegate) {
    return color != oldDelegate.color;
  }
}

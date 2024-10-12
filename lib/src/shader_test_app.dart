import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:game_of_life/src/domain/cell_pattern.dart';

class ShaderTestApp extends StatefulWidget {
  const ShaderTestApp({super.key});

  @override
  State<ShaderTestApp> createState() => _ShaderTestAppState();
}

class _ShaderTestAppState extends State<ShaderTestApp> {
  late FragmentProgram fragmentProgram;

  Future<FragmentProgram> loadShader() async {
    fragmentProgram = await FragmentProgram.fromAsset("assets/shader/game_of_life_simulate.frag");

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
            child: SingleChildScrollView(
              child: Text(
                snapshot.error.toString(),
              ),
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
  ui.Image? gridTexture;
  ui.Image? nextGridTexture;
  final Size gridSize = Size(400, 400); // Size of your grid

  @override
  void initState() {
    super.initState();
    initD();
  }

  void initD() async {
    gridTexture = await makeImage();
    setState(() {});
  }

  Future<ui.Image> makeImage() async {
    const width = 30;
    const height = 30;
    const bytesPerPixel = 4;
    final buffer = Uint8List(width * height * bytesPerPixel);

    final pattern = FiveCellPattern();
    final (startY, startX) = ((height / 2) - pattern.minSpace.$1, (width / 2) - pattern.minSpace.$2);
    final (endY, endX) = (startY + pattern.minSpace.$1 - 1, startX + pattern.minSpace.$2 - 1);

    final patternDigits = pattern.pattern;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final offset = ((y * width) + x) * bytesPerPixel;

        bool isLiveCell = () {
          bool isInBound = y >= startY && y < endY && x >= startX && x < endX;
          if (!isInBound) return false;

          final dy = y - startY.toInt();
          final dx = x - startX.toInt();

          return patternDigits[dy][dx] > .5;
        }();

        if (isLiveCell) {
          buffer[offset] = 0; // Red channel
          buffer[offset + 1] = 0; // Green channel
          buffer[offset + 2] = 0; // Blue channel
          buffer[offset + 3] = 255; // Alpha (fully opaque)
        } else {
          // Set this cell to white
          buffer[offset] = 255; // Red channel
          buffer[offset + 1] = 255; // Green channel
          buffer[offset + 2] = 255; // Blue channel
          buffer[offset + 3] = 255; // Alpha (fully opaque)
        }
      }
    }
    final immutable = await ui.ImmutableBuffer.fromUint8List(buffer);
    final descriptor = ui.ImageDescriptor.raw(
      immutable,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec(
      targetWidth: width,
      targetHeight: height,
    );
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    return gridTexture != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.purple.withOpacity(.3),
                  width: gridSize.width,
                  height: gridSize.height,
                  child: InteractiveViewer(
                    maxScale: 100,
                    child: CustomPaint(
                      painter: GameOfLifePainter(widget.fragmentProgram, gridTexture!),
                      child: SizedBox(width: gridSize.width, height: gridSize.height),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.cyanAccent.withOpacity(.3),
                  child: RawImage(
                    image: gridTexture,
                  ),
                ),
              )
            ],
          )
        : Container(); // Show a loader while the texture is being created
  }
}

class GameOfLifePainter extends CustomPainter {
  final ui.FragmentProgram program;
  final ui.Image gridTexture;

  GameOfLifePainter(this.program, this.gridTexture);

  @override
  void paint(Canvas canvas, Size size) {
    // Configure shader uniforms and the texture sampler
    final shader = program.fragmentShader()
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setImageSampler(0, gridTexture); // Use the current grid as input

    Paint paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

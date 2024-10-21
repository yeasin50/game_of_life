import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:game_of_life/src/domain/cell_pattern.dart';

import 'image_buffer.dart';

final Size canvasSize = Size(400, 400);
int numberOfRows = 10;
int numberOfCols = 10;

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

  bool play = false;

  @override
  void initState() {
    super.initState();
    initD();
  }

  void initD() async {
    gridTexture = await createFrameBuffer(300, 300);
    setState(() {});
  }

  GlobalKey _globalKey = GlobalKey();

  void onChanged(value) async {
    //FIXME: notworking
    RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    print('Captured Image Size: ${image.width} x ${image.height}');
    gridTexture = image;
    play = !play;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return gridTexture != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                child: CheckboxListTile(
                  value: play,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: onChanged,
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.purple.withOpacity(.3),
                  child: InteractiveViewer(
                    maxScale: 100,
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: CustomPaint(
                        painter: GameOfLifePainter(widget.fragmentProgram, gridTexture!, playing: play),
                        child: SizedBox.fromSize(
                          size: canvasSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.cyanAccent.withOpacity(.3),
                  width: canvasSize.width,
                  height: canvasSize.height,
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
  final bool playing;

  GameOfLifePainter(this.program, this.gridTexture, {required this.playing});

  @override
  void paint(Canvas canvas, Size size) {
    double gridSize = min(size.width / numberOfCols, size.height / numberOfRows);

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

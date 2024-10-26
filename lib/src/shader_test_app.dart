import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'image_buffer.dart';

final Size canvasSize = Size(400.0, 400);
int numberOfRows = 50;
int numberOfCols = 50;

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
    createBuffer();
  }

  void createBuffer() async {
    gridTexture = await createFrameBuffer(canvasSize.width.toInt(), canvasSize.height.toInt(),
        rows: numberOfRows, cols: numberOfCols);
    setState(() {});
  }

  final GlobalKey _globalKey = GlobalKey();

  void onChanged(value) async {
    play = !play;

    setState(() {});
  }

  Timer? timer;

  void startTimer() {
    stopTimer();
    timer = Timer.periodic(
      Durations.medium1,
      (timer) async {
        RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 2.0);
        gridTexture = image;
        setState(() {});
      },
    );
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  void onPressed() {
    timer?.isActive == true ? stopTimer() : startTimer();
    setState(() {});
  }

  String get label => timer?.isActive == true ? "Stop" : "start";

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
                  child: InteractiveViewer(
                    maxScale: 100,
                    clipBehavior: Clip.none,
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: CustomPaint(
                        painter: GameOfLifePainter(widget.fragmentProgram, gridTexture!, playing: play),
                        child: SizedBox(
                          width: canvasSize.width.toDouble(),
                          height: canvasSize.height.toDouble(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Material(
                  child: ElevatedButton.icon(onPressed: onPressed, label: Text(label)),
                ),
              ),
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

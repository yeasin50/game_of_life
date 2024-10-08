import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:game_of_life/src/domain/cell_pattern.dart';

import 'domain/domain.dart';

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
  final Size gridSize = Size(300, 300); // Size of your grid

  @override
  void initState() {
    super.initState();
    initD();
  }

  void initD() async {
    await _createInitialGridTexture();
    _updateGrid();
  }

  Future<void> _createInitialGridTexture() async {
    // Create initial grid with active cells
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.black;
    canvas.drawRect(Offset.zero & gridSize, paint);

    // Initialize some active cells as white (alive)
    paint.color = Colors.white;

    List<Offset> activeCells = [];
    final pattern = LightWeightSpaceShip();
    final data = pattern.pattern;

    for (int y = 0; y < data.length; y++) {
      for (int x = 0; x < data[y].length; x++) {
        if (data[y][x] > 0) {
          activeCells.add(Offset(y.toDouble(), x.toDouble()));
        }
      }
    }

    final (shiftY, shiftX) = (
      (gridSize.height / 2) - (pattern.minSpace.$1), //
      (gridSize.width / 2) - (pattern.minSpace.$2)
    );

    double cellSize = 10;

    for (final cell in activeCells) {
      canvas.drawRect(
          Rect.fromLTWH(
            (cell.dx * cellSize) + shiftX,
            (cell.dy * cellSize) + shiftY,
            cellSize,
            cellSize,
          ),
          paint);
    }

    final picture = recorder.endRecording();
    gridTexture = await picture.toImage(gridSize.width.toInt(), gridSize.height.toInt());
    setState(() {});
  }

  Future<void> _updateGrid() async {
    if (gridTexture == null) return;

    // Create a new picture recorder to render the next generation
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    // Use the fragment shader to draw the next generation
    final shader = widget.fragmentProgram.fragmentShader()
      ..setFloat(0, gridSize.width)
      ..setFloat(1, gridSize.height)
      ..setImageSampler(0, gridTexture!); // Current grid as input

    paint.shader = shader;
    canvas.drawRect(Offset.zero & gridSize, paint);

    // Capture the result into an image (next generation)
    final picture = recorder.endRecording();
    nextGridTexture = await picture.toImage(gridSize.width.toInt(), gridSize.height.toInt());

    // Swap textures: current texture becomes the next grid
    gridTexture = nextGridTexture;
    setState(() {});
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
                  child: CustomPaint(
                    painter: GameOfLifePainter(widget.fragmentProgram, gridTexture!),
                    child: SizedBox(width: gridSize.width, height: gridSize.height),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.cyanAccent.withOpacity(.3),
                  width: gridSize.width,
                  height: gridSize.height,
                  child: InteractiveViewer(
                    maxScale: 100,
                    child: RawImage(
                      image: gridTexture,
                    ),
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

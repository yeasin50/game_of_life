import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../domain/cell_pattern.dart';
import '../../domain/domain.dart';
import '../../infrastructure/game_provider.dart';
import '../../infrastructure/utils/image_buffer.dart';
import '../_common/widgets/shader_painter.dart';

/// to render in shader[]
/// [data] is the passed down pattern from setup page
///
class ShaderGamePlayPage extends StatefulWidget {
  const ShaderGamePlayPage._(this.pattern);
  final ShaderCellPattern pattern;

  static MaterialPageRoute route({
    required ShaderCellPattern pattern,
  }) {
    return MaterialPageRoute(
        builder: (context) => ShaderGamePlayPage._(pattern));
  }

  @override
  State<ShaderGamePlayPage> createState() => _ShaderGamePlayPageState();
}

class _ShaderGamePlayPageState extends State<ShaderGamePlayPage> {
  bool isPlaying = false;

  final GlobalKey _globalKey = GlobalKey();
  ui.Image? gridTexture;
  Timer? timer;

  void startTimer() {
    stopTimer();
    timer = Timer.periodic(
      Durations.short1,
      (timer) async {
        RenderRepaintBoundary boundary = _globalKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 2.0);
        gridTexture = image;
        _generationCounter++;
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

  late final config = gameConfig;

  ui.FragmentProgram? fragmentProgram;
  Future<void> initShader() async {
    fragmentProgram = await ui.FragmentProgram.fromAsset(
        "assets/shader/game_of_life_simulate.frag");
    gridTexture = await cellPatternToImage(
      pattern: widget.pattern,
      gridDimension: config.dimension,
    );
    setState(() {});
  }

  int _generationCounter = 0;
  String get genString => "Gen: $_generationCounter";
  @override
  void initState() {
    super.initState();
    _generationCounter = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initShader();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.outlined(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          const SizedBox(width: 48),
          ElevatedButton.icon(
            icon:
                Icon(timer?.isActive == true ? Icons.pause : Icons.play_arrow),
            onPressed: onPressed,
            label: Text(label),
          ),
          const SizedBox(width: 48), //😂 lazy
          Text(genString)
        ],
      ),
      body: Center(
        child: gridTexture != null
            ? AspectRatio(
                aspectRatio: 1,
                child: InteractiveViewer(
                  maxScale: 100,
                  clipBehavior: Clip.none,
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: CustomPaint(
                        painter: GameOfLifeShaderPainter(
                          fragmentProgram!,
                          gridTexture!,
                          numberOfCols: config.dimension,
                          numberOfRows: config.dimension,
                          playing: isPlaying,
                        ),
                        size: Size.fromRadius(5 * config.dimension.toDouble())),
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

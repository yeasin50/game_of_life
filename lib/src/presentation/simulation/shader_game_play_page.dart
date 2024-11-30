import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:game_of_life/src/infrastructure/game_provider.dart';

import '../../domain/cell_pattern.dart';
import '../../domain/domain.dart';
import '../../infrastructure/utils/image_buffer.dart';
import '../widgets/shader_painter.dart';

/// to render in shader[]
/// [data] is the passed down pattern from setup page
///
class ShaderGamePlayPage extends StatefulWidget {
  const ShaderGamePlayPage._(this.pattern);
  final ShaderCellPattern pattern;

  static MaterialPageRoute route({
    required ShaderCellPattern pattern,
  }) {
    return MaterialPageRoute(builder: (context) => ShaderGamePlayPage._(pattern));
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

  ///FIXME: Sometimes/+ doesnt work in large (1k) canvas
  /// - I having doubt how should I handle it,
  /// - should I increase the sie based on canvas?
  /// -
  late final config = gameConfig;

  ui.FragmentProgram? fragmentProgram;
  Future<void> initShader() async {
    fragmentProgram = await ui.FragmentProgram.fromAsset("assets/shader/game_of_life_simulate.frag");
    gridTexture = await cellPatternToImage(
      pattern: widget.pattern,
      // what will be the perfect *
      width: config.dimension * 44,
      height: config.dimension * 44,
      rows: config.dimension,
      cols: config.dimension,
      gridDimension: config.dimension,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(onPressed: onPressed, child: Text(label)),
      body: Container(
        alignment: Alignment.center,
        color: Colors.red,
        child: Center(
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
      ),
    );
  }
}

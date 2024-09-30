import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../domain/domain.dart';
import '../presentation/utils/grid_data_extension.dart';
import '../presentation/widgets/gof_painter.dart';
import 'infrastructure.dart';

class GameOfLifeSimulationCanvas {
  Size? _canvasSize;
  late BuildContext _context; // how can I skip it

  void setCanvas(BuildContext context, Size size) {
    _context = context;
    _canvasSize = size;
  }

  void resetCanvas() {
    _image = null;
    _rect = null;
    _transforms = null;
    _canvasSize = null;
  }

  Future<ui.Image> buildImage(GameStateValueNotifier<GOFState> notifier, GameConfig config) async {
    if (_canvasSize == null) {
      throw Exception("Canvas size must be initialized before loading images");
    }
    ui.Image? image = await _createImageFromWidget(
      _context,
      RepaintBoundary(
        child: CustomPaint(
            painter: GOFPainter(
              notifier,
              showBorder: config.clipOnBorder,
            ),
            size: _canvasSize!),
      ),
    );

    return image!;
  }

  ui.Image? _image;
  List<Rect>? _rect;
  List<ui.RSTransform>? _transforms;

  /// get data from [ canvas.drawRawAtlas]
  Future<CanvasData> rawAtlasData(List<List<GridData>> data, double gridSize, {bool colorize = false}) async {
    _rect ??= () {
      final dividerGap = (gridSize * .1);
      final itemSize = ui.Offset.zero & Size.square(gridSize - dividerGap);
      return List.filled(data.length * data.first.length, itemSize); //Don't needed isolate for filled
    }();

    _transforms ??= await compute(_getTransforms, [data.length, data.first.length, gridSize]);

    _image ??= await () async {
      final recorder = ui.PictureRecorder();
      late final canvas = ui.Canvas(recorder);
      const ShapeDecoration(
        color: Colors.green,
        shape: RoundedRectangleBorder(),
      )
          .createBoxPainter(() {}) //
          .paint(canvas, ui.Offset.zero, ImageConfiguration(size: Size.square(gridSize)));

      return await recorder.endRecording().toImage(gridSize.ceil(), gridSize.ceil());
    }();

    final colors = await compute(_getColors, [data, colorize]);
    return CanvasData(
      rect: _rect!,
      colors: colors,
      transform: _transforms!,
      image: _image,
    );
  }
}

Future<List<Color>> _getColors(List args) async {
  List<List<GridData>> data = args.first;
  final bool colorize = args.last;
  List<Color> colors = [];
  for (int y = 0; y < data.length; y++) {
    for (int x = 0; x < data.first.length; x++) {
      colors.add(data[y][x].isAlive
          ? colorize
              ? data[y][x].color
              : const Color(0xFF39ff14)
          : Colors.black);
    }
  }
  return colors;
}

Future<List<RSTransform>> _getTransforms(List args) async {
  // [gridSize, data, colorize]
  final int yLength = args.first;
  final int xLength = args[1];
  final double gridSize = args[2];
  var result = <ui.RSTransform>[];
  for (int y = 0; y < yLength; y++) {
    for (int x = 0; x < xLength; x++) {
      result.add(ui.RSTransform(1.0, 0, x * gridSize, y * gridSize));
    }
  }
  return result;
}

Future<ui.Image?> _createImageFromWidget(
  BuildContext context,
  Widget widget, {
  Size? logicalSize,
  Size? imageSize,
}) async {
  final repaintBoundary = RenderRepaintBoundary();

  logicalSize ??= View.of(context).physicalSize / View.of(context).devicePixelRatio;
  imageSize ??= View.of(context).physicalSize;

  assert(logicalSize.aspectRatio == imageSize.aspectRatio, 'logicalSize and imageSize must not be the same');

  final renderView = RenderView(
    child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints(minWidth: logicalSize.width, minHeight: logicalSize.height),
      physicalConstraints: BoxConstraints(minWidth: logicalSize.width, minHeight: logicalSize.height),
      devicePixelRatio: 1,
    ),
    view: View.of(context),
  );

  final pipelineOwner = PipelineOwner();
  final buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      )).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);

  buildOwner
    ..buildScope(rootElement)
    ..finalizeTree();

  pipelineOwner
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();

  final image = await repaintBoundary.toImage(pixelRatio: imageSize.width / logicalSize.width);

  return image;
}

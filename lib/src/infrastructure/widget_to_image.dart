import 'dart:isolate';
import 'dart:ui' as ui;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:game_of_life/src/infrastructure/infrastructure.dart';
import 'package:game_of_life/src/presentation/widgets/pattern_selection_view.dart';

import '../domain/domain.dart';
import '../presentation/widgets/gof_painter.dart';

class GameOfLifeSimulationCanvas {
  Size? _canvasSize;
  late BuildContext _context; // how can I skip it

  void setCanvas(BuildContext context, Size size) {
    _context = context;
    _canvasSize = size;
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
  Future<CanvasData> rawAtlasData(List<List<GridData>> data, double gridSize) async {
    _rect ??= List.filled(data.length * data.first.length, ui.Offset.zero & Size.square(gridSize));

    _transforms ??= await Isolate.run(() {
      var result = <ui.RSTransform>[];
      for (int y = 0; y < data.length; y++) {
        for (int x = 0; x < data.first.length; x++) {
          result.add(ui.RSTransform(1.0, 0, x * gridSize, y * gridSize));
        }
      }
      return result;
    });

    final colors = await Isolate.run(
      () {
        List<Color> result = [];
        for (int y = 0; y < data.length; y++) {
          for (int x = 0; x < data.first.length; x++) {
            result.add(data[y][x].life > .5 ? Colors.green : Colors.black);
          }
        }
        return result;
      },
    );

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

    return CanvasData(
      rect: _rect!,
      colors: colors,
      transform: _transforms!,
      image: _image,
    );
  }
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

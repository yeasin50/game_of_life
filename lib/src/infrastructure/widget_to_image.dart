import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:game_of_life/src/infrastructure/game_provider.dart';
import 'package:game_of_life/src/infrastructure/infrastructure.dart';

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

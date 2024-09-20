import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:game_of_life/src/infrastructure/game_provider.dart';

import '../presentation/widgets/gof_painter.dart';

mixin GameOfLifeSimulationMixin {
  Size? _canvasSize;
  void init(Size size) {
    _canvasSize = size;
  }

  Future<Widget> buildImage(BuildContext context) async {
    if (_canvasSize == null) {
      throw Exception("Canvas size must be initialized before loading images");
    }
    ui.Image? image = await createImageFromWidget(
      context,
      RepaintBoundary(
        child: CustomPaint(
            painter: GOFPainter(
              context.gameEngine.stateNotifier,
              showBorder: context.gameConfig.clipOnBorder,
            ),
            size: _canvasSize!),
      ),
    );

    return RawImage(image: image);
  }
}

Future<ui.Image?> createImageFromWidget(
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
  // final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return image;
}

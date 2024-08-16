import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import '../domain/domain.dart';
import 'gof_life_page.dart';

class SetUpOverviewPage extends StatefulWidget {
  const SetUpOverviewPage._({
    required this.numberOfRows,
    required this.numberOfCol,
    required this.generationGap,
  });

  const SetUpOverviewPage.test({
    this.numberOfRows = 50,
    this.numberOfCol = 50,
    this.generationGap = const Duration(milliseconds: 250),
  });

  final int numberOfRows;
  final int numberOfCol;
  final Duration generationGap;

  static MaterialPageRoute route({
    required int numberOfRows,
    required int numberOfCol,
    required Duration generationGap,
  }) {
    return MaterialPageRoute(
      builder: (context) => SetUpOverviewPage._(
        numberOfRows: numberOfRows,
        numberOfCol: numberOfCol,
        generationGap: generationGap,
      ),
    );
  }

  @override
  State<SetUpOverviewPage> createState() => _SetUpOverviewPageState();
}

class _SetUpOverviewPageState extends State<SetUpOverviewPage> {
  void navToGameBoard() {
    final engine = GameOfLifeEngine()
      ..init(
        numberOfCol: widget.numberOfCol,
        numberOfRows: widget.numberOfRows,
        generationGap: widget.generationGap,
      );

    Navigator.of(context).push(GOFPage.route(engine: engine));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TwoDimensionalGridView(
          diagonalDragBehavior: DiagonalDragBehavior.free,
          cacheExtent: 500,
          delegate: TwoDimensionalChildBuilderDelegate(
            maxXIndex: 30,
            maxYIndex: 30,
            builder: (context, vicinity) {
              return Container(
                height: 200,
                width: 200,
                color: Colors.primaries[(vicinity.xIndex + vicinity.yIndex) % Colors.primaries.length],
                alignment: Alignment.center,
                child: Text(
                  vicinity.toString(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class TwoDimensionalGridView extends TwoDimensionalScrollView {
  const TwoDimensionalGridView({
    super.key,
    required super.delegate,
    super.primary,
    super.mainAxis = Axis.vertical,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalGridViewPort(
      verticalOffset: verticalOffset,
      verticalAxisDirection: AxisDirection.down,
      horizontalAxisDirection: AxisDirection.right,
      horizontalOffset: horizontalOffset,
      delegate: delegate,
      mainAxis: mainAxis,
    );
  }
}

class TwoDimensionalGridViewPort extends TwoDimensionalViewport {
  const TwoDimensionalGridViewPort({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.delegate,
    required super.mainAxis,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTreeViewPostT(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      delegate: delegate,
      mainAxis: mainAxis,
      childManager: context as TwoDimensionalChildManager,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderTwoDimensionalViewport renderObject) {
    super.updateRenderObject(context, renderObject);
  }
}

class RenderTreeViewPostT extends RenderTwoDimensionalViewport {
  RenderTreeViewPostT({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.delegate,
    required super.mainAxis,
    required super.childManager,
  });

  @override
  void layoutChildSequence() async{
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;

    final viewPortWidth = viewportDimension.width + cacheExtent;
    final viewPortHeight = viewportDimension.height + cacheExtent;

    final TwoDimensionalChildBuilderDelegate builderDelegate = delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColIndex = builderDelegate.maxXIndex!;

    final int leadingColumn = math.max((horizontalPixels / 200).floor(), 0);
    final int leadingRow = math.max((verticalPixels / 200).floor(), 0);

    final int trailingColumn = math.min((horizontalPixels + viewPortWidth / 200).ceil(), maxColIndex);
    final int trailingRow = math.min((verticalPixels + viewPortHeight / 200).ceil(), maxRowIndex);

    double xLayoutOffset = (leadingColumn * 200) - horizontalPixels;
    for (int x = leadingColumn; x < trailingColumn; x++) {
      double yLayoutOffset = (leadingRow * 200) - verticalPixels;
      for (int y = leadingRow; y < trailingRow; y++) {
        final ChildVicinity childVicinity = ChildVicinity(xIndex: x, yIndex: y);
        final RenderBox child = buildOrObtainChildFor(childVicinity)!;
        child.layout(constraints.loosen());

        parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);

        yLayoutOffset += 200;
      }
      xLayoutOffset += 200;
    }

    final double verticalExtent = 200 * (maxRowIndex * 1.0);
    verticalOffset.applyContentDimensions(0, (verticalExtent - viewportDimension.height).clamp(0, double.infinity));

    final double horizontalExtent = 200 * (maxColIndex * 1);
    horizontalOffset.applyContentDimensions(0, (horizontalExtent - viewportDimension.width).clamp(0, double.infinity));
  }
}

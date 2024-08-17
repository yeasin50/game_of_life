import 'package:flutter/material.dart';

import '../domain/domain.dart';
import 'gof_life_page.dart';
import 'widgets/two_dimensional_custom_paint_gridview.dart';

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
        child: TwoDimensionalCustomPaintGridView(
          gridSize: (widget.numberOfRows, widget.numberOfCol),
        ),
      ),
    );
  }
}

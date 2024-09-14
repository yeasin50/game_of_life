import 'package:flutter/material.dart';
import '../domain/cell_pattern.dart';
import '../infrastructure/game_config.dart';

import '../infrastructure/game_provider.dart';
import 'gof_life_page.dart';
import 'widgets/export_dialog.dart';
import 'widgets/two_dimensional_custom_paint_gridview.dart';

/// select initial pattern to show
class SetUpOverviewPage extends StatefulWidget {
  const SetUpOverviewPage._(
    this.config,
    this.pattern,
  );

  final GameConfig config;
  final CellPattern? pattern;

  static MaterialPageRoute route({
    required GameConfig config,
    CellPattern? selectedPattern,
  }) {
    return MaterialPageRoute(
      builder: (context) => SetUpOverviewPage._(config, selectedPattern),
    );
  }

  @override
  State<SetUpOverviewPage> createState() => _SetUpOverviewPageState();
}

class _SetUpOverviewPageState extends State<SetUpOverviewPage> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    gameEngine.init(config: gameConfig).then((value) {
      if (widget.pattern != null) gameEngine.addPattern(widget.pattern!);

      isLoading = false;

      setState(() {});
    });
  }

  void navToGameBoard() async {
    if (context.mounted) {
      await Navigator.of(context).push(GOFPage.route());
      gameEngine.stopPeriodicGeneration();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Draw Living Cell"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  Wrap(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => navToGameBoard(),
                        child: const Text("Start"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.redAccent.withAlpha(100),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Text("Clear"),
                      ),
                      const SizedBox(width: 16),
                      const ExportGameData(),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Container()
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TwoDimensionalCustomPaintGridView(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
